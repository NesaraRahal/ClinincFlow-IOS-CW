import SwiftUI
import Combine

struct NotificationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var hapticsManager: HapticsManager
    @EnvironmentObject var notificationManager: NotificationManager
    
    @State private var selectedNotification: NotificationItem? = nil
    @State private var showDetail = false
    
    var body: some View {
        NavigationStack {
            Group {
                if notificationManager.notifications.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "bell.slash.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary.opacity(0.5))
                        
                        Text("No Notifications")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("You're all caught up!\nWe'll notify you when something happens.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            // Unread Section
                            let unreadNotifications = notificationManager.notifications.filter { !$0.isRead }
                            if !unreadNotifications.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("New")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 4)
                                    
                                    ForEach(unreadNotifications) { notification in
                                        NotificationCard(notification: notification)
                                            .onTapGesture {
                                                hapticsManager.playTapSound()
                                                notificationManager.markAsRead(notification.id)
                                                selectedNotification = notification
                                                showDetail = true
                                            }
                                    }
                                }
                                .padding(.bottom, 8)
                            }
                            
                            // Read Section
                            let readNotifications = notificationManager.notifications.filter { $0.isRead }
                            if !readNotifications.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Earlier")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 4)
                                    
                                    ForEach(readNotifications) { notification in
                                        NotificationCard(notification: notification)
                                            .onTapGesture {
                                                hapticsManager.playTapSound()
                                                selectedNotification = notification
                                                showDetail = true
                                            }
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .padding(.bottom, 40)
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        hapticsManager.playTapSound()
                        notificationManager.markAllAsRead()
                    }) {
                        Text("Mark all read")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "16A34A"))
                    }
                    .disabled(notificationManager.unreadCount == 0)
                    .opacity(notificationManager.unreadCount == 0 ? 0.5 : 1)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.secondary, Color(.systemGray5))
                    }
                }
            }
            .onAppear {
                notificationManager.updateNotificationTimes()
                let unreadCount = notificationManager.unreadCount
                hapticsManager.speak("Notifications. You have \(unreadCount) unread notification\(unreadCount == 1 ? "" : "s").")
            }
        }
        .sheet(isPresented: $showDetail) {
            if let notification = selectedNotification {
                NotificationDetailView(notification: notification)
            }
        }
    }
}

// MARK: - Notification Detail View
struct NotificationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let notification: NotificationItem
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(notification.type.color.opacity(0.15))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: notification.type.icon)
                            .font(.system(size: 36))
                            .foregroundColor(notification.type.color)
                    }
                    .padding(.top, 20)
                    
                    // Title
                    Text(notification.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    // Time
                    Text(notification.time)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    // Full Message
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Details")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(notification.message)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                    
                    Spacer(minLength: 40)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.secondary, Color(.systemGray5))
                    }
                }
            }
        }
    }
}

// MARK: - Notification Card
struct NotificationCard: View {
    let notification: NotificationItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(notification.type.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: notification.type.icon)
                    .font(.system(size: 18))
                    .foregroundColor(notification.type.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(notification.title)
                        .font(.system(size: 15, weight: notification.isRead ? .medium : .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if !notification.isRead {
                        Circle()
                            .fill(Color(hex: "16A34A"))
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text(notification.message)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(notification.time)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(.systemGray3))
            }
        }
        .padding(16)
        .background(notification.isRead ? Color(.systemBackground) : Color(hex: "16A34A").opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            if !notification.isRead {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "16A34A").opacity(0.15), lineWidth: 1)
            }
        }
    }
}

#Preview {
    NotificationView()
        .environmentObject(HapticsManager())
        .environmentObject(NotificationManager())
}
