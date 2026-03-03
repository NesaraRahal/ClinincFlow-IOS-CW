//
//  ContentView.swift
//  ClinicFlow
//
//  Created by COBSCCOMP24.2P-053 on 2026-03-03.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    
    init() {
        // Check if user should stay signed in
        let staySignedIn = UserDefaults.standard.bool(forKey: "staySignedIn")
        _isLoggedIn = State(initialValue: staySignedIn)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                LoginView(isLoggedIn: $isLoggedIn)
                    .transition(.move(edge: .leading))
            }
            .animation(.easeInOut(duration: 0.3), value: isLoggedIn)
        }
    }
}


