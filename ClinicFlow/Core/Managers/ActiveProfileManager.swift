//
//  ActiveProfileManager.swift
//  ClinicFlow
//
//  Created by COBSCCOMP242P-052 on 2026-02-27.
//

import SwiftUI
import Combine

// MARK: - Active Profile (who is currently using the app — like YouTube profile switch)
enum ActiveProfile: Equatable {
    case myself
    case familyMember(id: UUID)
    
    var isSelf: Bool {
        if case .myself = self { return true }
        return false
    }
    
    var familyMemberID: UUID? {
        if case .familyMember(let id) = self { return id }
        return nil
    }
    
    /// The patientName string used in AppointmentData / Visit
    func patientName(profileManager: UserProfileManager, familyManager: FamilyMembersManager) -> String {
        switch self {
        case .myself:
            return "Self"
        case .familyMember(let id):
            return familyManager.member(byID: id)?.fullName ?? "Self"
        }
    }
    
    /// Display name for the switcher
    func displayName(profileManager: UserProfileManager, familyManager: FamilyMembersManager) -> String {
        switch self {
        case .myself:
            let name = profileManager.profile.fullName
            return name.isEmpty ? "Myself" : name
        case .familyMember(let id):
            return familyManager.member(byID: id)?.fullName ?? "Unknown"
        }
    }
    
    /// Initials for avatar fallback
    func initials(profileManager: UserProfileManager, familyManager: FamilyMembersManager) -> String {
        switch self {
        case .myself:
            return profileManager.profile.initials
        case .familyMember(let id):
            return familyManager.member(byID: id)?.initials ?? "?"
        }
    }
}

// MARK: - Active Profile Manager
class ActiveProfileManager: ObservableObject {
    @Published var activeProfile: ActiveProfile = .myself
    
    /// Switch to self
    func switchToSelf() {
        withAnimation(.spring(response: 0.3)) {
            activeProfile = .myself
        }
    }
    
    /// Switch to a family member
    func switchToMember(_ member: FamilyMember) {
        withAnimation(.spring(response: 0.3)) {
            activeProfile = .familyMember(id: member.id)
        }
    }
    
    /// Check if a given profile is the active one
    func isActive(_ profile: ActiveProfile) -> Bool {
        activeProfile == profile
    }
    
    /// Check if a given family member is the active profile
    func isMemberActive(_ member: FamilyMember) -> Bool {
        if case .familyMember(let id) = activeProfile {
            return id == member.id
        }
        return false
    }
}
