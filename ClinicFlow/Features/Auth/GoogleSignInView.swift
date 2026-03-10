//
//  GoogleSignInView.swift
//  ClinicFlow
//
//  Created by COBSCCOMP242P-052 on 2026-03-01.
//

import SwiftUI

struct GoogleSignInView: View {
    @Binding var isLoggedIn: Bool
    @Binding var showProfileSwitcher: Bool
    @Binding var staySignedIn: Bool
    @Environment(\.dismiss) var dismiss
    @State private var isAuthenticating = false
    @State private var email = ""
    @FocusState private var isEmailFocused: Bool
    
    var isEmailValid: Bool {
        email.contains("@") && email.contains(".")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Google Logo
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 100, height: 100)
                                    .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                                
                                Text("G")
                                    .font(.system(size: 56, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "4285F4"),
                                                Color(hex: "34A853"),
                                                Color(hex: "FBBC05"),
                                                Color(hex: "EA4335")
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            .padding(.top, 40)
                            
                            VStack(spacing: 8) {
                                Text("Sign in")
                                    .font(.system(size: 24, weight: .regular))
                                    .foregroundColor(.primary)
                                
                                Text("to continue to ClinicFlow")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.bottom, 16)
                        
                        // Email Input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Email")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            TextField("Enter your email", text: $email)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .focused($isEmailFocused)
                                .font(.system(size: 16))
                                .padding(16)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            isEmailFocused ? Color(hex: "4285F4").opacity(0.5) : Color.clear,
                                            lineWidth: 2
                                        )
                                }
                        }
                        .padding(.horizontal, 24)
                        
                        // Info Box
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "4285F4"))
                            
                            Text("Google will share your name, email address, and profile picture with ClinicFlow")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .background(Color(hex: "4285F4").opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 24)
                        
                        // Stay Signed In
                        Button(action: {
                            staySignedIn.toggle()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: staySignedIn ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 22))
                                    .foregroundColor(staySignedIn ? Color(hex: "4285F4") : .secondary)
                                
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
                        
                        Spacer()
                            .frame(height: 40)
                        
                        // Buttons
                        VStack(spacing: 12) {
                            // Sign In Button
                            Button(action: authenticateWithGoogle) {
                                HStack(spacing: 10) {
                                    if isAuthenticating {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Continue")
                                            .font(.system(size: 17, weight: .semibold))
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    isEmailValid
                                        ? Color(hex: "4285F4")
                                        : Color(.systemGray4)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(
                                    color: isEmailValid ? Color(hex: "4285F4").opacity(0.3) : Color.clear,
                                    radius: 12,
                                    x: 0,
                                    y: 6
                                )
                            }
                            .disabled(!isEmailValid || isAuthenticating)
                            
                            // Cancel Button
                            Button(action: { dismiss() }) {
                                Text("Cancel")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    }
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
    
    private func authenticateWithGoogle() {
        guard isEmailValid else { return }
        
        isAuthenticating = true
        isEmailFocused = false
        
        // Simulate Google Sign In
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

#Preview {
    GoogleSignInView(isLoggedIn: .constant(false), showProfileSwitcher: .constant(false), staySignedIn: .constant(false))
}
