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
    @State private var showMapView = false
    @State private var showFamilyMembers = false
    @State private var showDoctorDetail = false
    @State private var showDoctorList = false
    @State private var selectedDoctor: SpecialistDoctor? = nil
    
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
                    
                    // Profile Button (YouTube-style switcher)
                    ActiveProfileButton(size: 42) {
                        hapticsManager.playTapSound()
                        showProfileSwitcher = true
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .background(Color(.systemBackground))
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 16)
                    
                    // MARK: - Empty State Illustration
                    VStack(spacing: 32) {
                        // Animated Illustration
                        ZStack {
                            // Outer pulse ring
                            Circle()
                                .stroke(Color(hex: "16A34A").opacity(0.15), lineWidth: 2)
                                .frame(width: 180, height: 180)
                            
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
                                    .shadow(color: Color(hex: "16A34A").opacity(0.3), radius: 16, y: 8)
                                
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Text Content
                        VStack(spacing: 12) {
                            Text("No Appointments Yet")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Start your healthcare journey by booking\nyour first appointment with us")
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
                    
                    // MARK: - Quick Tips Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "F59E0B"))
                            
                            Text("Quick Tips")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 36)
                        
                        HStack(spacing: 12) {
                            QuickTipCard(
                                icon: "clock.fill",
                                iconColor: Color(hex: "3B82F6"),
                                title: "Quick Check-in",
                                subtitle: "Walk-in anytime"
                            ) {
                                hapticsManager.playTapSound()
                                showServiceSelection = true
                            }
                            
                            QuickTipCard(
                                icon: "mappin.circle.fill",
                                iconColor: Color(hex: "EF4444"),
                                title: "Indoor Map",
                                subtitle: "Find your way"
                            ) {
                                hapticsManager.playTapSound()
                                showMapView = true
                            }
                            
                            QuickTipCard(
                                icon: "person.2.fill",
                                iconColor: Color(hex: "8B5CF6"),
                                title: "Family Care",
                                subtitle: "Book for others"
                            ) {
                                hapticsManager.playTapSound()
                                showFamilyMembers = true
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // MARK: - Featured Specialists
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "F59E0B"))
                            
                            Text("Featured Specialists")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(action: {
                                hapticsManager.playTapSound()
                                showDoctorList = true
                            }) {
                                Text("See All")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: "16A34A"))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 36)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                FeaturedDoctorCard(
                                    doctor: sampleDoctors[0],
                                    action: {
                                        hapticsManager.playTapSound()
                                        selectedDoctor = sampleDoctors[0]
                                        showDoctorDetail = true
                                    }
                                )
                                
                                FeaturedDoctorCard(
                                    doctor: sampleDoctors[1],
                                    action: {
                                        hapticsManager.playTapSound()
                                        selectedDoctor = sampleDoctors[1]
                                        showDoctorDetail = true
                                    }
                                )
                                
                                FeaturedDoctorCard(
                                    doctor: sampleDoctors[6],
                                    action: {
                                        hapticsManager.playTapSound()
                                        selectedDoctor = sampleDoctors[6]
                                        showDoctorDetail = true
                                    }
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 60)
                }
            }
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
                HomeView(onAppointmentBooked: { data in
                    // First dismiss the sheet, then trigger the callback
                    showServiceSelection = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onAppointmentBooked?(data)
                    }
                })
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
        .sheet(isPresented: $showMapView) {
            NavigationStack {
                MapTabView(initialOriginID: nil, initialDestinationID: nil)
            }
        }
        .sheet(isPresented: $showFamilyMembers) {
            NavigationStack {
                FamilyMembersView()
            }
        }
        .sheet(item: $selectedDoctor) { doctor in
            NavigationStack {
                SpecialistDoctorDetailView(doctor: doctor, onAppointmentBooked: { data in
                    selectedDoctor = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onAppointmentBooked?(data)
                    }
                })
            }
        }
        .sheet(isPresented: $showDoctorList) {
            NavigationStack {
                DoctorListView(onAppointmentBooked: { data in
                    showDoctorList = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onAppointmentBooked?(data)
                    }
                })
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
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(iconColor)
                }
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray5), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Featured Doctor Card
struct FeaturedDoctorCard: View {
    let doctor: SpecialistDoctor
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                // Doctor Image with Overlay
                ZStack(alignment: .bottom) {
                    ZStack(alignment: .topTrailing) {
                        if let uiImage = UIImage(named: doctor.imageName) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 280, height: 200)
                                .clipped()
                        } else {
                            Rectangle()
                                .fill(LinearGradient(
                                    colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 280, height: 200)
                                .overlay(
                                    Image(systemName: "stethoscope")
                                        .font(.system(size: 60, weight: .light))
                                        .foregroundColor(.white.opacity(0.3))
                                )
                        }
                        
                        // Availability Badge
                        if doctor.isAvailable {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color(hex: "10B981"))
                                    .frame(width: 6, height: 6)
                                
                                Text("Available Today")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                                    )
                            )
                            .padding(12)
                        }
                    }
                    
                    // Gradient Overlay at bottom for better text readability
                    LinearGradient(
                        colors: [Color.black.opacity(0), Color.black.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 80)
                }
                
                // Doctor Info
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(doctor.name)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "cross.case.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "16A34A"))
                            
                            Text(doctor.specialty)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "16A34A"))
                                .lineLimit(1)
                        }
                    }
                    
                    // Qualification
                    Text(doctor.qualification)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Divider()
                        .padding(.vertical, 2)
                    
                    HStack(spacing: 16) {
                        // Rating
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "F59E0B"))
                            
                            Text(String(format: "%.1f", doctor.rating))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("(\(doctor.reviewCount))")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Experience
                        HStack(spacing: 4) {
                            Image(systemName: "briefcase.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            
                            Text("\(doctor.experience) yrs")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Fee Badge
                    HStack {
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Text("Fee:")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text(doctor.consultationFee)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(hex: "16A34A"))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color(hex: "16A34A").opacity(0.1))
                        .clipShape(Capsule())
                        
                        Spacer()
                    }
                }
                .padding(18)
            }
            .frame(width: 280)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.1), radius: 16, x: 0, y: 6)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.systemGray5), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Service Feature Row
struct ServiceFeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    EmptyHomeView()
        .environmentObject(UserProfileManager())
        .environmentObject(HapticsManager())
        .environmentObject(ActiveProfileManager())
        .environmentObject(FamilyMembersManager())
}
