//
//  ProfileSwitcherView.swift
//  ClinicFlow
//
//  Created by COBSCCOMP242P-052 on 2026-02-27.
//

import SwiftUI

// MARK: - Profile Switcher (YouTube-style account switch)
struct ProfileSwitcherView: View {
    @EnvironmentObject var activeProfileManager: ActiveProfileManager
    @EnvironmentObject var profileManager: UserProfileManager
    @EnvironmentObject var familyManager: FamilyMembersManager
    @EnvironmentObject var hapticsManager: HapticsManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)
            
            // Title
            HStack {
                Text("Switch Profile")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.secondary, Color(.systemGray5))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            // Current Profile Banner
            currentProfileBanner
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            
            Divider()
                .padding(.horizontal, 20)
            
            // Profiles List
            ScrollView(showsIndicators: false) {
                VStack(spacing: 4) {
                    // Self
                    profileRow(
                        name: profileManager.profile.fullName.isEmpty ? "Myself" : profileManager.profile.fullName,
                        subtitle: "Primary Account • \(profileManager.profile.patientID)",
                        image: profileManager.profileImage,
                        initials: profileManager.profile.initials,
                        color: Color(hex: "16A34A"),
                        isSelected: activeProfileManager.activeProfile.isSelf
                    ) {
                        hapticsManager.playTapSound()
                        activeProfileManager.switchToSelf()
                        dismiss()
                    }
                    
                    // Family Members
                    if !familyManager.members.isEmpty {
                        HStack {
                            Text("FAMILY MEMBERS")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                                .tracking(0.5)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 4)
                        
                        ForEach(familyManager.members) { member in
                            profileRow(
                                name: member.fullName,
                                subtitle: "\(member.relationship) • \(member.age) yrs",
                                image: familyManager.loadProfileImage(for: member.id),
                                initials: member.initials,
                                color: member.iconColor,
                                isSelected: activeProfileManager.isMemberActive(member)
                            ) {
                                hapticsManager.playTapSound()
                                activeProfileManager.switchToMember(member)
                                dismiss()
                            }
                        }
                    }
                    
                    // Manage Family
                    NavigationLink {
                        FamilyMembersView()
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray5))
                                    .frame(width: 48, height: 48)
                                
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 18))
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("Manage Family Members")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(.systemGray3))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                }
                .padding(.vertical, 12)
            }
        }
        .background(Color(.systemGroupedBackground))
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
    
    // MARK: - Current Profile Banner
    private var currentProfileBanner: some View {
        let name = activeProfileManager.activeProfile.displayName(
            profileManager: profileManager,
            familyManager: familyManager
        )
        let isSelf = activeProfileManager.activeProfile.isSelf
        
        return HStack(spacing: 14) {
            // Active avatar
            activeProfileAvatar(size: 44)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Currently viewing as")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Active badge
            Text(isSelf ? "YOU" : "FAMILY")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(isSelf ? Color(hex: "16A34A") : Color.orange)
                .clipShape(Capsule())
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Profile Row
    private func profileRow(
        name: String,
        subtitle: String,
        image: UIImage?,
        initials: String,
        color: Color,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Avatar
                ZStack {
                    if let img = image {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                        
                        Text(initials)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // Selected ring
                    if isSelected {
                        Circle()
                            .stroke(Color(hex: "16A34A"), lineWidth: 2.5)
                            .frame(width: 52, height: 52)
                    }
                }
                .frame(width: 52, height: 52)
                
                // Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "16A34A"))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(isSelected ? Color(hex: "16A34A").opacity(0.06) : Color.clear)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Active Profile Avatar
    func activeProfileAvatar(size: CGFloat) -> some View {
        Group {
            switch activeProfileManager.activeProfile {
            case .myself:
                if let img = profileManager.profileImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
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
                        .frame(width: size, height: size)
                        .overlay {
                            Text(profileManager.profile.initials.prefix(1))
                                .font(.system(size: size * 0.38, weight: .bold))
                                .foregroundColor(.white)
                        }
                }
                
            case .familyMember(let id):
                if let member = familyManager.member(byID: id),
                   let img = familyManager.loadProfileImage(for: id) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
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
                        .frame(width: size, height: size)
                        .overlay {
                            Text(member.initials.prefix(1))
                                .font(.system(size: size * 0.38, weight: .bold))
                                .foregroundColor(.white)
                        }
                } else {
                    Circle()
                        .fill(Color(.systemGray4))
                        .frame(width: size, height: size)
                        .overlay {
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                        }
                }
            }
        }
    }
}

// MARK: - Reusable Active Profile Avatar Button (for headers)
struct ActiveProfileButton: View {
    let size: CGFloat
    let action: () -> Void
    @EnvironmentObject var activeProfileManager: ActiveProfileManager
    @EnvironmentObject var profileManager: UserProfileManager
    @EnvironmentObject var familyManager: FamilyMembersManager
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomTrailing) {
                // Avatar
                avatarView
                
                // Small indicator ring for family member
                if !activeProfileManager.activeProfile.isSelf {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: size * 0.28, height: size * 0.28)
                        .overlay {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: size * 0.13, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .offset(x: 2, y: 2)
                }
            }
        }
        .frame(width: size, height: size)
    }
    
    @ViewBuilder
    private var avatarView: some View {
        switch activeProfileManager.activeProfile {
        case .myself:
            if let img = profileManager.profileImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
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
                    .frame(width: size, height: size)
                    .overlay {
                        Text(profileManager.profile.initials.prefix(1))
                            .font(.system(size: size * 0.38, weight: .bold))
                            .foregroundColor(.white)
                    }
            }
            
        case .familyMember(let id):
            if let _ = familyManager.member(byID: id),
               let img = familyManager.loadProfileImage(for: id) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
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
                    .frame(width: size, height: size)
                    .overlay {
                        Text(member.initials.prefix(1))
                            .font(.system(size: size * 0.38, weight: .bold))
                            .foregroundColor(.white)
                    }
            } else {
                Circle()
                    .fill(Color(.systemGray4))
                    .frame(width: size, height: size)
                    .overlay {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                    }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileSwitcherView()
    }
    .environmentObject(ActiveProfileManager())
    .environmentObject(UserProfileManager())
    .environmentObject(FamilyMembersManager())
    .environmentObject(HapticsManager())
}
