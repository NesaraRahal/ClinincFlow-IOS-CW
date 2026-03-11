//
//  SettingsView.swift
//  ClinicFlow
//

import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @Binding var isLoggedIn: Bool
    @EnvironmentObject var hapticsManager: HapticsManager
    @EnvironmentObject var profileManager: UserProfileManager
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    @State private var showProfileView = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationStack {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Settings")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Manage your preferences")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Profile Section
                    SettingsSection(title: "Account") {
                        SettingsRow(icon: "person.fill", iconColor: Color(hex: "16A34A"), title: "My Profile", subtitle: profileManager.profile.fullName) {
                            showProfileView = true
                        }
                    }
                    
                    // General Section
                    SettingsSection(title: "General") {
                        SettingsRow(icon: "bell.fill", iconColor: .orange, title: "Notifications", subtitle: "Manage alerts") { }
                        
                        SettingsRow(icon: "lock.fill", iconColor: .blue, title: "Privacy", subtitle: "Data & permissions") { }
                        
                        SettingsRow(icon: "questionmark.circle.fill", iconColor: .purple, title: "Help & Support", subtitle: "FAQs & contact") { }
                        
                        NavigationLink {
                            AccessibilitySettingsView()
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.blue.opacity(0.12))
                                        .frame(width: 36, height: 36)
                                    
                                    Image(systemName: "accessibility")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.blue)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Accessibility")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    Text("Haptics, sounds & screen reader")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(.systemGray3))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // About Section
                    SettingsSection(title: "About") {
                        SettingsRow(icon: "info.circle.fill", iconColor: .gray, title: "App Version", subtitle: "1.0.0") { }
                        
                        SettingsRow(icon: "doc.text.fill", iconColor: .gray, title: "Terms of Service", subtitle: "") { }
                    }
                    
                    // Logout Button
                    Button(action: {
                        hapticsManager.playErrorSound()
                        showLogoutAlert = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 16))
                            
                            Text("Log Out")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    Spacer(minLength: 100)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .alert("Log Out?", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                UserDefaults.standard.set(false, forKey: "staySignedIn")
                withAnimation(.easeInOut(duration: 0.35)) {
                    isLoggedIn = false
                }
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        .sheet(isPresented: $showProfileView) {
            NavigationStack {
                ProfileView()
            }
        }
        .onAppear {
            hapticsManager.speak("Settings screen")
        }
        } // NavigationStack
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary)
                .tracking(0.5)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                    
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(.systemGray3))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView(isLoggedIn: .constant(true))
        .environmentObject(HapticsManager())
        .environmentObject(UserProfileManager())
        .environmentObject(AppearanceManager())
}
