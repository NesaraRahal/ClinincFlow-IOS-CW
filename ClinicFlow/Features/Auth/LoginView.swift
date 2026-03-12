//
//  LoginView.swift
//  ClinicFlow
//
//  Created by COBSCCOMP242P-052 on 2026-02-23.
//

import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @Binding var showProfileSwitcher: Bool
    @State private var phoneNumber: String = ""
    @FocusState private var isPhoneFieldFocused: Bool
    @State private var pulseAnimation = false
    @State private var showOTPView = false
    @State private var staySignedIn = false
    @State private var isFirstTimeUser = true
    @State private var showPhoneError = false
    @State private var showAppleSignIn = false
    @State private var showGoogleSignIn = false
    @State private var appearAnimation = false
    
    var isPhoneValid: Bool {
        !phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty && phoneNumber.count >= 10
    }
    
    private let greenPrimary = Color(hex: "16A34A")
    private let greenLight = Color(hex: "22C55E")
    
    var body: some View {
        ZStack {
            // Rich layered background
            Color(hex: "F0FDF4").ignoresSafeArea()
            
            // Decorative gradient blobs
            GeometryReader { geo in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "BBF7D0").opacity(0.7), Color.clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 180
                        )
                    )
                    .frame(width: 360, height: 360)
                    .offset(x: -60, y: -80)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "DCFCE7").opacity(0.6), Color.clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 160
                        )
                    )
                    .frame(width: 300, height: 300)
                    .offset(x: geo.size.width - 120, y: geo.size.height - 280)
            }
            .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                Spacer()
                    .frame(minHeight: 20, maxHeight: 80)
                
                // MARK: - Hero Logo
                VStack(spacing: 20) {
                    ZStack {
                        // Outer pulse ring
                        Circle()
                            .stroke(greenPrimary.opacity(0.15), lineWidth: 2)
                            .frame(width: 120, height: 120)
                            .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                            .opacity(pulseAnimation ? 0 : 0.7)
                        
                        // Inner soft glow
                        Circle()
                            .fill(greenPrimary.opacity(0.08))
                            .frame(width: 110, height: 110)
                        
                        // Main icon circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [greenPrimary, greenLight],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 90, height: 90)
                            .shadow(color: greenPrimary.opacity(0.35), radius: 20, x: 0, y: 10)
                        
                        // Heart + Cross icon
                        ZStack {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.white.opacity(0.85))
                                .offset(y: -2)
                            
                            Image(systemName: "cross.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .offset(y: 7)
                        }
                    }
                    .scaleEffect(appearAnimation ? 1.0 : 0.5)
                    .opacity(appearAnimation ? 1 : 0)
                    .onAppear {
                        withAnimation(.spring(response: 0.7, dampingFraction: 0.65)) {
                            appearAnimation = true
                        }
                        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false)) {
                            pulseAnimation = true
                        }
                    }
                    
                    // Title group
                    VStack(spacing: 6) {
                        Text("Welcome to")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 10)
                            .animation(.easeOut(duration: 0.5).delay(0.2), value: appearAnimation)
                        
                        Text("ClinicFlow")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [greenPrimary, greenLight],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 10)
                            .animation(.easeOut(duration: 0.5).delay(0.3), value: appearAnimation)
                        
                        Text("Your Health Journey, Simplified.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary.opacity(0.8))
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 10)
                            .animation(.easeOut(duration: 0.5).delay(0.4), value: appearAnimation)
                    }
                }
                .padding(.bottom, 40)
                
                // MARK: - Phone Input
                VStack(spacing: 14) {
                    HStack(spacing: 14) {
                        // Phone icon
                        ZStack {
                            Circle()
                                .fill(greenPrimary.opacity(0.12))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "phone.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(greenPrimary)
                        }
                        
                        TextField("Enter your mobile number", text: $phoneNumber)
                            .keyboardType(.phonePad)
                            .focused($isPhoneFieldFocused)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .onChange(of: phoneNumber) { _, _ in
                                showPhoneError = false
                            }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                showPhoneError
                                    ? Color.red.opacity(0.5)
                                    : (isPhoneFieldFocused ? greenPrimary.opacity(0.5) : Color(.systemGray5).opacity(0.8)),
                                lineWidth: (showPhoneError || isPhoneFieldFocused) ? 1.5 : 1
                            )
                    }
                    .shadow(
                        color: showPhoneError
                            ? Color.red.opacity(0.08)
                            : (isPhoneFieldFocused ? greenPrimary.opacity(0.1) : Color.black.opacity(0.04)),
                        radius: isPhoneFieldFocused ? 12 : 6,
                        x: 0,
                        y: 4
                    )
                    .animation(.spring(response: 0.3), value: isPhoneFieldFocused)
                    .animation(.spring(response: 0.3), value: showPhoneError)
                    
                    // Error message
                    if showPhoneError {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                            
                            Text("Please enter a valid phone number")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 4)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 16)
                
                // MARK: - Continue Button
                Button(action: {
                    if isPhoneValid {
                        isPhoneFieldFocused = false
                        showOTPView = true
                    } else {
                        withAnimation(.spring(response: 0.3)) {
                            showPhoneError = true
                        }
                    }
                }) {
                    HStack(spacing: 10) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .bold))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        Group {
                            if isPhoneValid {
                                LinearGradient(
                                    colors: [greenPrimary, greenLight],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            } else {
                                LinearGradient(
                                    colors: [Color(.systemGray4), Color(.systemGray3).opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(
                        color: isPhoneValid ? greenPrimary.opacity(0.35) : Color.clear,
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                    .animation(.spring(response: 0.4), value: isPhoneValid)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 24)
                
                // MARK: - Divider
                HStack(spacing: 16) {
                    Rectangle()
                        .fill(Color(.systemGray4).opacity(0.4))
                        .frame(height: 0.5)
                    
                    Text("or")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.7))
                    
                    Rectangle()
                        .fill(Color(.systemGray4).opacity(0.4))
                        .frame(height: 0.5)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 20)
                
                // MARK: - Social Sign-In Buttons (stacked)
                VStack(spacing: 12) {
                    Button(action: {
                        showAppleSignIn = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Sign in with Apple")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(.systemGray4).opacity(0.5), lineWidth: 1)
                        }
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
                    }
                    
                    Button(action: {
                        showGoogleSignIn = true
                    }) {
                        HStack(spacing: 12) {
                            // Google "G" with brand colors
                            Text("G")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "4285F4"), Color(hex: "EA4335"), Color(hex: "FBBC05"), Color(hex: "34A853")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("Sign in with Google")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(.systemGray4).opacity(0.5), lineWidth: 1)
                        }
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
                    }
                }
                .padding(.horizontal, 28)
                
                Spacer()
                    .frame(minHeight: 16, maxHeight: 40)
                
                // MARK: - Privacy Notice
                Text("By continuing, you agree to our **Terms** and **Privacy Policy**")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 24)
            }
        }
        .navigationDestination(isPresented: $showOTPView) {
            OTPVerificationView(
                isLoggedIn: $isLoggedIn,
                showProfileSwitcher: $showProfileSwitcher,
                staySignedIn: $staySignedIn,
                phoneNumber: phoneNumber,
                isFirstTimeUser: isFirstTimeUser
            )
        }
        .sheet(isPresented: $showAppleSignIn) {
            AppleSignInView(isLoggedIn: $isLoggedIn, showProfileSwitcher: $showProfileSwitcher, staySignedIn: $staySignedIn)
        }
        .sheet(isPresented: $showGoogleSignIn) {
            GoogleSignInView(isLoggedIn: $isLoggedIn, showProfileSwitcher: $showProfileSwitcher, staySignedIn: $staySignedIn)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// Color extension to support hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false), showProfileSwitcher: .constant(false))
}
