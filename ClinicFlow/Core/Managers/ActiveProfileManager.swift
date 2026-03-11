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
    
    
    
    /// Check if a given profile is the active one
    func isActive(_ profile: ActiveProfile) -> Bool {
        activeProfile == profile
    }
    
}
