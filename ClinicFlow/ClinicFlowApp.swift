//
//  ClinicFlowApp.swift
//  ClinicFlow
//
//  Created by COBSCCOMP242P-052 on 2026-02-23.
//

import SwiftUI

@main
struct ClinicFlowApp: App {
    @StateObject private var hapticsManager = HapticsManager()
    @StateObject private var profileManager = UserProfileManager()
    @StateObject private var activeProfileManager = ActiveProfileManager()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var familyManager = FamilyMembersManager()
    @StateObject private var visitsManager = VisitsManager()
    @StateObject private var appearanceManager = AppearanceManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(hapticsManager)
                .environmentObject(profileManager)
                .environmentObject(activeProfileManager)
                .environmentObject(notificationManager)
                .environmentObject(familyManager)
                .environmentObject(visitsManager)
                .environmentObject(appearanceManager)
        }
    }
}
