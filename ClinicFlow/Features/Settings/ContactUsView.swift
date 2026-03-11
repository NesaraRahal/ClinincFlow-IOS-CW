import SwiftUI

// MARK: - Contact Us View
struct ContactUsView: View {
    var body: some View {
        List {
            Section {
                ContactMethodRow(
                    icon: "phone.fill",
                    iconColor: .green,
                    title: "Call Us",
                    subtitle: "+94 11 234 5678",
                    actionIcon: "phone.arrow.up.right.fill"
                )
                
                ContactMethodRow(
                    icon: "envelope.fill",
                    iconColor: .blue,
                    title: "Email",
                    subtitle: "support@clinicflow.com",
                    actionIcon: "arrow.up.right"
                )
                
                ContactMethodRow(
                    icon: "bubble.left.and.bubble.right.fill",
                    iconColor: Color(hex: "16A34A"),
                    title: "Live Chat",
                    subtitle: "Available 9 AM - 6 PM",
                    actionIcon: "arrow.up.right"
                )
            } header: {
                Text("Get in Touch")
            } footer: {
                Text("Our support team typically responds within 24 hours")
            }
            
            Section("Visit Us") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                        
                        Text("ClinicFlow Health Center")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Text("123 Medical Street, Colombo 07\nSri Lanka")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .padding(.leading, 32)
                }
                .padding(.vertical, 8)
            }
            
            Section("Office Hours") {
                HStack {
                    Text("Monday - Friday")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("8:00 AM - 8:00 PM")
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text("Saturday")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("8:00 AM - 4:00 PM")
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text("Sunday")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Closed")
                        .foregroundColor(.red)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Contact Us")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Contact Method Row
struct ContactMethodRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let actionIcon: String
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: actionIcon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            .padding(.vertical, 6)
        }
    }
}

#Preview {
    NavigationStack {
        ContactUsView()
    }
}
