//
//  AppleSignInView.swift
//  ClinicFlow
//
//  Created by COBSCCOMP242P-052 on 2026-03-01.
//

import SwiftUI

struct AppleSignInView: View {
    @Binding var isLoggedIn: Bool
    @Binding var showProfileSwitcher: Bool
    @Binding var staySignedIn: Bool
    @Environment(\.dismiss) var dismiss
    @State private var isAuthenticating = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Apple Logo
                    ZStack {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 100, height: 100)
                            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                        
                        Image(systemName: "apple.logo")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    // Title & Description
                    VStack(spacing: 12) {
                        Text("Sign in with Apple")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Fast, easy and secure")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Info Cards
                    VStack(spacing: 16) {
                        SignInInfoCard(
                            icon: "checkmark.shield.fill",
                            title: "Private & Secure",
                            description: "Your information is protected with industry-leading security"
                        )
                        
                        SignInInfoCard(
                            icon: "bolt.fill",
                            title: "Quick Setup",
                            description: "Sign in with Face ID or Touch ID"
                        )
                        
                        SignInInfoCard(
                            icon: "lock.fill",
                            title: "Privacy First",
                            description: "Apple doesn't track your activity"
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Stay Signed In
                    Button(action: {
                        staySignedIn.toggle()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: staySignedIn ? "checkmark.square.fill" : "square")
                                .font(.system(size: 22))
                                .foregroundColor(staySignedIn ? Color.black : .secondary)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Stay Signed In")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text("Don't ask again on this device")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 24)
                    
                    // Sign In Button
                    Button(action: authenticateWithApple) {
                        HStack(spacing: 10) {
                            if isAuthenticating {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "apple.logo")
                                    .font(.system(size: 18, weight: .semibold))
                                
                                Text("Continue with Apple")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
                    }
                    .disabled(isAuthenticating)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                    
                    // Cancel Button
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.secondary)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
    }
    
    private func authenticateWithApple() {
        isAuthenticating = true
        
        // Simulate Apple Sign In
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isAuthenticating = false
            
            // Save stay signed in preference
            UserDefaults.standard.set(staySignedIn, forKey: "staySignedIn")
            
            // Dismiss sheet
            // Set logged in state immediately for smooth transition
            withAnimation(.spring()) {
                isLoggedIn = true
            }
            
            // Dismiss after state change
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                dismiss()
            }
        }
    }
}

// MARK: - Sign In Info Card
struct SignInInfoCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.08))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    AppleSignInView(isLoggedIn: .constant(false), showProfileSwitcher: .constant(false), staySignedIn: .constant(false))
}
