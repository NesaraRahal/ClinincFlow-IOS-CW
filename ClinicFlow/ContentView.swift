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
        Group {
            if isLoggedIn {
                HomeView(isLoggedIn: $isLoggedIn, showProfileSwitcher: $showProfileSwitcher)
                    .transition(.move(edge: .trailing))
            } else {
                NavigationStack {
                    LoginView(isLoggedIn: $isLoggedIn, showProfileSwitcher: $showProfileSwitcher)
                }
                .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: isLoggedIn)
    }
}


