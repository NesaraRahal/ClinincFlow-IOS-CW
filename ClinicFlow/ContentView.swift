//
//  ContentView.swift
//  ClinicFlow
//
//  Created by COBSCCOMP242P-052 on 2026-02-23.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var showProfileSwitcher = false
    
    init() {
        // Check if user should stay signed in
        let staySignedIn = UserDefaults.standard.bool(forKey: "staySignedIn")
        _isLoggedIn = State(initialValue: staySignedIn)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoggedIn {
                    MainTabView(isLoggedIn: $isLoggedIn)
                        .transition(.move(edge: .trailing))
                } else {
                    LoginView(isLoggedIn: $isLoggedIn, showProfileSwitcher: $showProfileSwitcher)
                        .transition(.move(edge: .leading))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isLoggedIn)
            .sheet(isPresented: $showProfileSwitcher) {
                NavigationStack {
                    ProfileSwitcherView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserProfileManager())
        .environmentObject(AppearanceManager())
        .environmentObject(VisitsManager())
        .environmentObject(FamilyMembersManager())
        .environmentObject(HapticsManager())
        .environmentObject(ActiveProfileManager())
}
