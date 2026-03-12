//
//  ClinicFlowApp.swift
//  ClinicFlow
//
//  Created by COBSCCOMP242P-052 on 2026-02-23.
//

import SwiftUI
import Combine

@main
struct ClinicFlowApp: App {
    @StateObject private var appearanceManager = AppearanceManager()
    @StateObject private var profileManager = UserProfileManager()
    @StateObject private var hapticsManager = HapticsManager()
    @StateObject private var visitsManager = VisitsManager()
    @StateObject private var familyManager = FamilyMembersManager()
    @StateObject private var activeProfileManager = ActiveProfileManager()
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appearanceManager)
                .environmentObject(profileManager)
                .environmentObject(hapticsManager)
                .environmentObject(visitsManager)
                .environmentObject(familyManager)
                .environmentObject(activeProfileManager)
                .environmentObject(notificationManager)
                .preferredColorScheme(appearanceManager.colorScheme)
        }
    }
}
