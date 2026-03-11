import SwiftUI

// MARK: - Empty Home View
// Shown when user has no active appointments
struct EmptyHomeView: View {
    @EnvironmentObject var profileManager: UserProfileManager
    @EnvironmentObject var hapticsManager: HapticsManager
    @EnvironmentObject var activeProfileManager: ActiveProfileManager
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var showServiceSelection = false
    @State private var showNotifications = false
    @State private var showProfileSwitcher = false
    @State private var showProfileSetupPrompt = false
    @State private var showProfileView = false
    
    // Callback when appointment is booked — passes appointment data
    var onAppointmentBooked: ((AppointmentData) -> Void)? = nil
    
    var unreadNotificationCount: Int {
        notificationManager.unreadCount
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Custom Header
            HStack {
                // Logo
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "cross.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text("ClinicFlow")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Notification & Profile Icons
                HStack(spacing: 12) {
                    // Notification Button
                    Button(action: {
                        hapticsManager.playTapSound()
                        showNotifications = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 42, height: 42)
                            
                            Image(systemName: "bell.fill")
                                .font(.system(size: 17))
                                .foregroundColor(.primary)
                        }
                        .overlay(alignment: .topTrailing) {
                            if unreadNotificationCount > 0 {
                                ZStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 18, height: 18)
                                    
                                    Text("\(unreadNotificationCount)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .offset(x: 4, y: -4)
                            }
                        }
                    }
                    .frame(width: 42, height: 42)
                    
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 16)
            
            Spacer()
            
            // MARK: - Empty State Content
            VStack(spacing: 32) {
                // Illustration
                ZStack {
                    Circle()
                        .fill(Color(hex: "16A34A").opacity(0.08))
                        .frame(width: 160, height: 160)
                    
                    Circle()
                        .fill(Color(hex: "16A34A").opacity(0.12))
                        .frame(width: 120, height: 120)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 72, height: 72)
                        
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                
                // Text Content
                VStack(spacing: 12) {
                    Text("No Appointments Yet")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Book your first appointment and\nwe'll take care of the rest")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                
                // Book Appointment Button
                Button(action: {
                    hapticsManager.playNavigationSound()
                    showServiceSelection = true
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("Book Appointment")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color(hex: "16A34A").opacity(0.3), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)
            }
            .padding(.bottom, 60)
            
            Spacer()
            
       
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            let name = profileManager.profile.fullName.isEmpty ? "" : ", \(profileManager.profile.fullName)"
            hapticsManager.speak("Home screen\(name). No active appointments. Tap Book Appointment to schedule a visit.")
            
            // Show profile setup prompt if this is first login and profile not completed
            if !profileManager.hasCompletedSetup {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showProfileSetupPrompt = true
                }
            }
        }
        .alert("Complete Your Profile", isPresented: $showProfileSetupPrompt) {
            Button("Not Now", role: .cancel) { }
            Button("Complete Profile") {
                showProfileView = true
            }
        } message: {
            Text("Complete your personal details to get a better experience and faster bookings.")
        }
        .sheet(isPresented: $showServiceSelection) {
            NavigationStack {
                HomeView(onAppointmentBooked: onAppointmentBooked)
            }
        }
        .sheet(isPresented: $showNotifications) {
            NotificationView()
        }
        .sheet(isPresented: $showProfileSwitcher) {
            NavigationStack {
                ProfileSwitcherView()
            }
        }
        .sheet(isPresented: $showProfileView) {
            NavigationStack {
                ProfileView()
            }
        }
    }
}

// MARK: - Quick Tip Card
struct QuickTipCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
            }
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    EmptyHomeView()
        .environmentObject(UserProfileManager())
        .environmentObject(HapticsManager())
        .environmentObject(ActiveProfileManager())
}
