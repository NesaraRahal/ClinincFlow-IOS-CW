//
//  LoginView.swift
//  ClinicFlow
//
//  Created by COBSCCOMP24.2P-053 on 2026-03-03.
//

import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var phoneNumber: String = ""
    @FocusState private var isPhoneFieldFocused: Bool
    @State private var pulseAnimation = false
    @State private var showOTPView = false
    @State private var showPhoneError = false

    var isPhoneValid: Bool {
        !phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty && phoneNumber.count >= 10
    }

    var body: some View {
        ZStack {
            // Background — fixed light gradient
            LinearGradient(
                colors: [
                    Color(hex: "F0FDF4"),
                    Color(hex: "DCFCE7"),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // MARK: - Hero Section
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .stroke(Color(hex: "16A34A").opacity(0.2), lineWidth: 2)
                            .frame(width: 100, height: 100)
                            .scaleEffect(pulseAnimation ? 1.15 : 1.0)
                            .opacity(pulseAnimation ? 0 : 0.6)

                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .shadow(color: Color(hex: "16A34A").opacity(0.25), radius: 15, x: 0, y: 8)

                        ZStack {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                                .offset(y: -2)

                            Image(systemName: "cross.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .offset(y: 6)
                        }
                    }
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: false)) {
                            pulseAnimation = true
                        }
                    }

                    VStack(spacing: 6) {
                        Text("ClinicFlow")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        Text("Your health journey, simplified")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: "6B7280"))
                    }
                }
                .padding(.bottom, 36)

                // MARK: - Login Form
                VStack(spacing: 16) {
                    // Phone Input
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Phone Number")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "111827"))

                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "16A34A").opacity(0.1))
                                    .frame(width: 40, height: 40)

                                Image(systemName: "phone.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "16A34A"))
                            }

                            TextField("Enter your phone number", text: $phoneNumber)
                                .keyboardType(.phonePad)
                                .focused($isPhoneFieldFocused)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "111827"))
                                .tint(Color(hex: "16A34A"))
                                .onChange(of: phoneNumber) { _, _ in
                                    showPhoneError = false
                                }
                        }
                        .padding(14)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    showPhoneError
                                        ? Color.red.opacity(0.6)
                                        : (isPhoneFieldFocused ? Color(hex: "16A34A").opacity(0.4) : Color(hex: "E5E7EB")),
                                    lineWidth: showPhoneError ? 2 : (isPhoneFieldFocused ? 2 : 1)
                                )
                        }
                        .shadow(
                            color: showPhoneError
                                ? Color.red.opacity(0.15)
                                : (isPhoneFieldFocused ? Color(hex: "16A34A").opacity(0.12) : Color.black.opacity(0.03)),
                            radius: 8, x: 0, y: 3
                        )
                        .animation(.spring(response: 0.3), value: isPhoneFieldFocused)
                        .animation(.spring(response: 0.3), value: showPhoneError)

                        if showPhoneError {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)

                                Text("Please enter a valid phone number")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.red)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }

                    // Continue Button
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
                        HStack(spacing: 8) {
                            Text("Continue")
                                .font(.system(size: 16, weight: .semibold))

                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 16))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            isPhoneValid
                                ? LinearGradient(
                                    colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                : LinearGradient(
                                    colors: [Color(hex: "D1D5DB"), Color(hex: "D1D5DB")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(
                            color: isPhoneValid ? Color(hex: "16A34A").opacity(0.3) : Color.clear,
                            radius: 10, x: 0, y: 5
                        )
                        .animation(.spring(response: 0.3), value: isPhoneValid)
                    }
                }
                .padding(20)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 6)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                // Divider
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(Color(hex: "E5E7EB"))
                        .frame(height: 1)

                    Text("or")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "9CA3AF"))

                    Rectangle()
                        .fill(Color(hex: "E5E7EB"))
                        .frame(height: 1)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                // Social Buttons
                HStack(spacing: 12) {
                    Button(action: {}) {
                        HStack(spacing: 10) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "111827"))
                            Text("Apple")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(hex: "111827"))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(hex: "E5E7EB"), lineWidth: 1)
                        }
                        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
                    }

                    Button(action: {}) {
                        HStack(spacing: 10) {
                            Text("G")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(hex: "4285F4"))
                            Text("Google")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(hex: "111827"))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(hex: "E5E7EB"), lineWidth: 1)
                        }
                        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                // Privacy Notice
                Text("By continuing, you agree to our **Terms** and **Privacy Policy**")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "9CA3AF"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 28)
            }
        }
        .environment(\.colorScheme, .light)
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}
