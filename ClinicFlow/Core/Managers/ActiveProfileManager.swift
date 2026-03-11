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
    
    /// Check if a specific family member is active
    func isMemberActive(_ member: FamilyMember) -> Bool {
        if case .familyMember(let id) = activeProfile {
            return id == member.id
        }
        return false
    }
}

// MARK: - ActiveProfile Display Helpers
extension ActiveProfile {
    /// Get the patient name for the current active profile
    func patientName(profileManager: UserProfileManager, familyManager: FamilyMembersManager) -> String {
        switch self {
        case .myself:
            return profileManager.profile.fullName.isEmpty ? "Self" : profileManager.profile.fullName
        case .familyMember(let id):
            return familyManager.member(byID: id)?.fullName ?? "Family Member"
        }
    }
    
    /// Get display name (alias for patientName)
    func displayName(profileManager: UserProfileManager, familyManager: FamilyMembersManager) -> String {
        patientName(profileManager: profileManager, familyManager: familyManager)
    }
}
