//
//  NotificationView.swift
//  ClinicFlow
//

import SwiftUI

// MARK: - Notification View
struct NotificationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var hapticsManager: HapticsManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if notificationManager.notifications.isEmpty {
                    // Empty State
                    Spacer()
                    
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "bell.slash")
                                .font(.system(size: 32))
                                .foregroundColor(Color(.systemGray3))
                        }
                        
                        Text("No Notifications")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("You're all caught up!")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                } else {
                    // Notifications List
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 8) {
                            ForEach(notificationManager.notifications) { notification in
                                NotificationRow(notification: notification)
                                    .onTapGesture {
                                        notificationManager.markAsRead(notification.id)
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 32)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "16A34A"))
                }
                
                if !notificationManager.notifications.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Mark All Read") {
                            notificationManager.markAllAsRead()
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
        .onAppear {
            hapticsManager.speak("Notifications. \(notificationManager.unreadCount) unread.")
        }
    }
}

// MARK: - Notification Row
struct NotificationRow: View {
    let notification: NotificationItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(notification.type.color.opacity(0.12))
                    .frame(width: 42, height: 42)
                
                Image(systemName: notification.type.icon)
                    .font(.system(size: 17))
                    .foregroundColor(notification.type.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.system(size: 15, weight: notification.isRead ? .medium : .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(notification.time)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Text(notification.message)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
        }
        .padding(14)
        .background(notification.isRead ? Color(.systemBackground) : Color(hex: "16A34A").opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(notification.isRead ? Color.clear : Color(hex: "16A34A").opacity(0.15), lineWidth: 1)
        )
    }
}

#Preview {
    NotificationView()
        .environmentObject(NotificationManager())
        .environmentObject(HapticsManager())
}
