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
    @State private var continueToBookingAfterProfileSave = false
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

    private var isProfileComplete: Bool {
        let p = profileManager.profile
        return !p.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !p.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !p.phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !p.dateOfBirth.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !p.gender.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !p.bloodType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !p.address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !p.emergencyContact.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 8)
                    
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
                            if isProfileComplete {
                                showServiceSelection = true
                            } else {
                                showProfileSetupPrompt = true
                            }
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
                    
                    // MARK: - Get Started Checklist
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "checklist")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "16A34A"))
                            
                            Text("Before booking")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)

                            Spacer()

                            Text("3 steps")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(hex: "16A34A"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color(hex: "16A34A").opacity(0.1))
                                .clipShape(Capsule())
                        }

                        Text("Quick setup for a smoother first visit")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 0) {
                            FirstBookingChecklistRow(
                                number: "1",
                                title: isProfileComplete ? "Profile is ready" : "Complete your profile",
                                subtitle: isProfileComplete ? "Details saved" : "Add remaining details"
                            )
                            
                            Divider()
                                .padding(.leading, 42)
                            
                            FirstBookingChecklistRow(
                                number: "2",
                                title: "Choose a service",
                                subtitle: "OPD, Lab, Pharmacy, Specialist"
                            )
                            
                            Divider()
                                .padding(.leading, 42)
                            
                            FirstBookingChecklistRow(
                                number: "3",
                                title: "Confirm and get token",
                                subtitle: "See room + queue instantly"
                            )
                        }
                        .padding(16)
                        .background(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(.systemGray5), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    // MARK: - Explore & Personalise
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("While you're here…")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("A few things to make your first visit smooth")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        
                        // Full-width profile banner
                        Button(action: {
                            hapticsManager.playTapSound()
                            showProfileView = true
                        }) {
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 5) {
                                        Image(systemName: isProfileComplete ? "checkmark.circle.fill" : "pencil.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(isProfileComplete ? Color(hex: "16A34A") : Color(hex: "F59E0B"))
                                        
                                        Text(isProfileComplete ? "All good!" : "Action needed")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(isProfileComplete ? Color(hex: "16A34A") : Color(hex: "F59E0B"))
                                    }
                                    
                                    Text(isProfileComplete ? "You're all set 👋" : "Complete your profile")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.primary)
                                    
                                    Text(isProfileComplete
                                         ? "Your details are saved — check-in will be a breeze."
                                         : "Some details are missing. Fill them now to continue booking.")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                Image(systemName: isProfileComplete ? "person.crop.circle.badge.checkmark" : "person.crop.circle.badge.plus")
                                    .font(.system(size: 48))
                                    .foregroundColor(Color(hex: "16A34A").opacity(0.2))
                            }
                            .padding(18)
                            .frame(minHeight: 132, alignment: .leading)
                            .background(Color(hex: "16A34A").opacity(0.07))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color(hex: "16A34A").opacity(0.18), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 20)
                        
                        // Two compact shortcut tiles
                        HStack(spacing: 12) {
                            Button(action: {
                                hapticsManager.playTapSound()
                                showFamilyMembers = true
                            }) {
                                VStack(alignment: .leading, spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "7C3AED").opacity(0.12))
                                            .frame(width: 44, height: 44)
                                        Image(systemName: "person.2.fill")
                                            .font(.system(size: 19))
                                            .foregroundColor(Color(hex: "7C3AED"))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Family")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.primary)
                                        
                                        Text("Book for your family too")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: 144, alignment: .topLeading)
                                .background(Color(hex: "7C3AED").opacity(0.07))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color(hex: "7C3AED").opacity(0.18), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                hapticsManager.playTapSound()
                                showMapView = true
                            }) {
                                VStack(alignment: .leading, spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "EF4444").opacity(0.12))
                                            .frame(width: 44, height: 44)
                                        Image(systemName: "mappin.and.ellipse")
                                            .font(.system(size: 19))
                                            .foregroundColor(Color(hex: "EF4444"))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Explore")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.primary)
                                        
                                        Text("Navigate the clinic indoors")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: 144, alignment: .topLeading)
                                .background(Color(hex: "EF4444").opacity(0.07))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color(hex: "EF4444").opacity(0.18), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                            }
                            .buttonStyle(PlainButtonStyle())
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
                        .padding(.top, 32)
                        
                        
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
                            .padding(.bottom, 28)
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
        }
        .alert("Complete Your Profile", isPresented: $showProfileSetupPrompt) {
            Button("Not Now", role: .cancel) { }
            Button("Complete Profile") {
                continueToBookingAfterProfileSave = true
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
        .sheet(isPresented: $showProfileView, onDismiss: {
            if continueToBookingAfterProfileSave {
                continueToBookingAfterProfileSave = false
            }
        }) {
            NavigationStack {
                ProfileView(
                    startInEditMode: continueToBookingAfterProfileSave,
                    onProfileSaved: {
                        if continueToBookingAfterProfileSave {
                            continueToBookingAfterProfileSave = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                showServiceSelection = true
                            }
                        }
                    }
                )
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

// MARK: - First Booking Checklist Row
struct FirstBookingChecklistRow: View {
    let number: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "16A34A").opacity(0.12))
                    .frame(width: 28, height: 28)
                
                Text(number)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "16A34A"))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Featured Doctor Card
struct FeaturedDoctorCard: View {
    let doctor: SpecialistDoctor
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Doctor Image with Heart Icon
                ZStack(alignment: .topTrailing) {
                    if let uiImage = UIImage(named: doctor.imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 300, height: 300)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 300, height: 300)
                            .overlay(
                                Image(systemName: "stethoscope")
                                    .font(.system(size: 70, weight: .light))
                                    .foregroundColor(.white.opacity(0.3))
                            )
                    }
                    
                    // Heart/Favorite Button (Airbnb style)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "heart")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .padding(16)
                }
                .clipShape(RoundedRectangle(cornerRadius: 32))
                
                // Doctor Info Below Image
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(doctor.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // Availability Badge
                        if doctor.isAvailable {
                            HStack(spacing: 3) {
                                Circle()
                                    .fill(Color(hex: "10B981"))
                                    .frame(width: 6, height: 6)
                                
                                Text("Available")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(hex: "10B981"))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "10B981").opacity(0.1))
                            .clipShape(Capsule())
                        }
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "cross.case.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text(doctor.specialty)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: 8) {
                        // Rating
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.primary)
                            
                            Text(String(format: "%.1f", doctor.rating))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("\(doctor.reviewCount) reviews")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Fee
                        Text(doctor.consultationFee)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(width: 300)
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
        .environmentObject(NotificationManager())
}
