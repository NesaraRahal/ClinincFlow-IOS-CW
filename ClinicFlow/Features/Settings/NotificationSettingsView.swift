import SwiftUI

// MARK: - Notification Settings View
struct NotificationSettingsView: View {
    @State private var pushNotifications = true
    @State private var appointmentReminders = true
    @State private var queueUpdates = true
    @State private var promotionalMessages = false
    @State private var emailNotifications = true
    @State private var smsNotifications = true
    
    var body: some View {
        List {
            Section {
                Toggle(isOn: $pushNotifications) {
                    SettingsToggleLabel(
                        icon: "bell.badge.fill",
                        iconColor: .red,
                        title: "Push Notifications"
                    )
                }
                .tint(Color(hex: "16A34A"))
            } footer: {
                Text("Enable to receive notifications on your device")
            }
            
            Section("Notification Types") {
                Toggle(isOn: $appointmentReminders) {
                    SettingsToggleLabel(
                        icon: "calendar.badge.clock",
                        iconColor: .blue,
                        title: "Appointment Reminders"
                    )
                }
                .tint(Color(hex: "16A34A"))
                
                Toggle(isOn: $queueUpdates) {
                    SettingsToggleLabel(
                        icon: "person.2.fill",
                        iconColor: .green,
                        title: "Queue Updates"
                    )
                }
                .tint(Color(hex: "16A34A"))
                
                Toggle(isOn: $promotionalMessages) {
                    SettingsToggleLabel(
                        icon: "megaphone.fill",
                        iconColor: .orange,
                        title: "Promotional Messages"
                    )
                }
                .tint(Color(hex: "16A34A"))
            }
            
            Section("Other Channels") {
                Toggle(isOn: $emailNotifications) {
                    SettingsToggleLabel(
                        icon: "envelope.fill",
                        iconColor: .blue,
                        title: "Email Notifications"
                    )
                }
                .tint(Color(hex: "16A34A"))
                
                Toggle(isOn: $smsNotifications) {
                    SettingsToggleLabel(
                        icon: "message.fill",
                        iconColor: .green,
                        title: "SMS Notifications"
                    )
                }
                .tint(Color(hex: "16A34A"))
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Settings Toggle Label
struct SettingsToggleLabel: View {
    let icon: String
    let iconColor: Color
    let title: String
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)
            }
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
}
