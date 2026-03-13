import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @Binding var isLoggedIn: Bool
    @EnvironmentObject var profileManager: UserProfileManager
    @EnvironmentObject var hapticsManager: HapticsManager
    @EnvironmentObject var activeProfileManager: ActiveProfileManager
    @EnvironmentObject var familyManager: FamilyMembersManager
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var showSignOutAlert = false
    @State private var showNotifications = false
    @State private var showProfileSwitcher = false

    var unreadNotificationCount: Int {
        notificationManager.unreadCount
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Custom Header
                HStack {
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

                    HStack(spacing: 12) {
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

                        ActiveProfileButton(size: 42) {
                            hapticsManager.playTapSound()
                            showProfileSwitcher = true
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .background(Color(.systemGroupedBackground))

                List {
                // Profile Section
                Section {
                    NavigationLink {
                        ProfileView()
                    } label: {
                        HStack(spacing: 16) {
                            ZStack {
                                if activeProfileManager.activeProfile.isSelf {
                                    // Main user avatar
                                    if let img = profileManager.profileImage {
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                    } else {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 60, height: 60)
                                        
                                        Text(profileManager.profile.initials)
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                } else if let id = activeProfileManager.activeProfile.familyMemberID {
                                    // Family member avatar
                                    if let img = familyManager.loadProfileImage(for: id) {
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                    } else if let member = familyManager.member(byID: id) {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [member.iconColor, member.iconColor.opacity(0.6)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 60, height: 60)
                                        
                                        Text(member.initials)
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(activeProfileManager.activeProfile.displayName(
                                    profileManager: profileManager,
                                    familyManager: familyManager
                                ))
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                if activeProfileManager.activeProfile.isSelf {
                                    Text("Patient ID: \(profileManager.profile.patientID)")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondary)
                                } else if let id = activeProfileManager.activeProfile.familyMemberID,
                                          let member = familyManager.member(byID: id) {
                                    Text("\(member.relationship) • \(member.age) yrs")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // Family Members Section
                Section {
                    NavigationLink {
                        FamilyMembersView()
                    } label: {
                        SettingsRow(
                            icon: "person.2.fill",
                            iconColor: Color(hex: "16A34A"),
                            title: "Family Members",
                            subtitle: "Manage family profiles"
                        )
                    }
                } header: {
                    Text("Family")
                } footer: {
                    Text("Add family members to book appointments on their behalf")
                }
                
                // Preferences Section
                Section("Preferences") {
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        SettingsRow(icon: "bell.fill", iconColor: .red, title: "Notifications")
                    }
                    
                    NavigationLink {
                        LanguageSettingsView()
                    } label: {
                        SettingsRow(icon: "globe", iconColor: .blue, title: "Language")
                    }
                }
                
                // Accessibility Section
                Section("Accessibility") {
                    NavigationLink {
                        AccessibilitySettingsView()
                    } label: {
                        SettingsRow(
                            icon: "accessibility",
                            iconColor: .indigo,
                            title: "Accessibility",
                            subtitle: "Haptics, sounds, dynamic type & screen reader"
                        )
                    }
                }
                
                // Support Section
                Section("Support") {
                    NavigationLink {
                        HelpCenterView()
                    } label: {
                        SettingsRow(icon: "questionmark.circle.fill", iconColor: .green, title: "Help Center")
                    }
                    
                    NavigationLink {
                        ContactUsView()
                    } label: {
                        SettingsRow(icon: "envelope.fill", iconColor: .orange, title: "Contact Us")
                    }
                    
                    NavigationLink {
                        TermsPrivacyView()
                    } label: {
                        SettingsRow(icon: "doc.text.fill", iconColor: .gray, title: "Terms & Privacy")
                    }
                }
                
                // Account Section
                Section("Account") {
                    Button(action: {
                        showSignOutAlert = true
                    }) {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red.opacity(0.15))
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 15))
                                    .foregroundColor(.red)
                            }
                            
                            Text("Sign Out")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // App Info
                Section {
                    HStack {
                        Text("Version")
                            .foregroundColor(.primary)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                } footer: {
                    Text("ClinicFlow © 2026")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 80)
                }
            }
            .listStyle(.insetGrouped)
            } // end VStack
            .toolbar(.hidden, for: .navigationBar)
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        // Clear stay signed in preference
                        UserDefaults.standard.set(false, forKey: "staySignedIn")
                        isLoggedIn = false
                    }
                }
            } message: {
                Text("Are you sure you want to sign out? You will need to log in again to access your appointments.")
            }
            .onAppear {
                hapticsManager.speak("Settings. Manage your preferences, accessibility, and account.")
            }
        .sheet(isPresented: $showNotifications) {
            NotificationView()
        }
        .sheet(isPresented: $showProfileSwitcher) {
            NavigationStack {
                ProfileSwitcherView()
            }
        }
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var subtitle: String? = nil
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView(isLoggedIn: .constant(true))
        .environmentObject(UserProfileManager())
        .environmentObject(HapticsManager())
        .environmentObject(FamilyMembersManager())
        .environmentObject(ActiveProfileManager())
}
