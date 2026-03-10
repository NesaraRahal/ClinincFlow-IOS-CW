//
//  OTPVerificationView.swift
//  ClinicFlow
//
//  Created by COBSCCOMP242P-052 on 2026-03-01.
//

import SwiftUI
import Combine

struct OTPVerificationView: View {
    @Binding var isLoggedIn: Bool
    @Binding var showProfileSwitcher: Bool
    @Binding var staySignedIn: Bool
    let phoneNumber: String
    let isFirstTimeUser: Bool
    
    @State private var otpDigits: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedField: Int?
    @State private var isVerifying = false
    @State private var timeRemaining = 60
    @State private var canResend = false
    @Environment(\.dismiss) var dismiss
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var otpCode: String {
        otpDigits.joined()
    }
    
    var isOTPComplete: Bool {
        otpCode.count == 6 && otpCode.allSatisfy { $0.isNumber }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
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
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(width: 40, height: 40)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Icon
                        ZStack {
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
                            
                            Image(systemName: "message.fill")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        
                        // Title & Description
                        VStack(spacing: 12) {
                            Text("Verify Phone Number")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Enter the 6-digit code sent to")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                            
                            Text(phoneNumber)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        
                        // OTP Input Fields
                        HStack(spacing: 12) {
                            ForEach(0..<6, id: \.self) { index in
                                OTPDigitField(
                                    digit: $otpDigits[index],
                                    isFocused: focusedField == index,
                                    onCommit: {
                                        if !otpDigits[index].isEmpty && index < 5 {
                                            focusedField = index + 1
                                        } else if isOTPComplete {
                                            verifyOTP()
                                        }
                                    },
                                    onDelete: {
                                        if otpDigits[index].isEmpty && index > 0 {
                                            focusedField = index - 1
                                        }
                                    }
                                )
                                .focused($focusedField, equals: index)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Timer & Resend
                        VStack(spacing: 12) {
                            if !canResend {
                                HStack(spacing: 6) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                    
                                    Text("Resend code in \(timeRemaining)s")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                Button(action: resendOTP) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 14, weight: .semibold))
                                        
                                        Text("Resend Code")
                                            .font(.system(size: 15, weight: .semibold))
                                    }
                                    .foregroundColor(Color(hex: "16A34A"))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color(hex: "16A34A").opacity(0.1))
                                    .clipShape(Capsule())
                                }
                            }
                        }
                        
                        // Stay Signed In (only for first-time users)
                        if isFirstTimeUser {
                            VStack(spacing: 16) {
                                Divider()
                                    .padding(.horizontal, 24)
                                
                                Button(action: {
                                    staySignedIn.toggle()
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: staySignedIn ? "checkmark.square.fill" : "square")
                                            .font(.system(size: 22))
                                            .foregroundColor(staySignedIn ? Color(hex: "16A34A") : .secondary)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Stay Signed In")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.primary)
                                            
                                            Text("You won't need to sign in again on this device")
                                                .font(.system(size: 13))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(16)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                staySignedIn ? Color(hex: "16A34A").opacity(0.3) : Color(.systemGray5),
                                                lineWidth: staySignedIn ? 2 : 1
                                            )
                                    }
                                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        
                        // Verify Button
                        Button(action: verifyOTP) {
                            HStack(spacing: 8) {
                                if isVerifying {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Verify & Continue")
                                        .font(.system(size: 16, weight: .semibold))
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                isOTPComplete
                                    ? LinearGradient(
                                        colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    : LinearGradient(
                                        colors: [Color(.systemGray4), Color(.systemGray4)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(
                                color: isOTPComplete ? Color(hex: "16A34A").opacity(0.3) : Color.clear,
                                radius: 10,
                                x: 0,
                                y: 5
                            )
                        }
                        .disabled(!isOTPComplete || isVerifying)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Auto-focus first field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = 0
            }
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                canResend = true
            }
        }
    }
    
    private func verifyOTP() {
        guard isOTPComplete else { return }
        
        isVerifying = true
        focusedField = nil
        
        // Simulate OTP verification
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isVerifying = false
            
            // Save stay signed in preference
            if isFirstTimeUser {
                UserDefaults.standard.set(staySignedIn, forKey: "staySignedIn")
            }
            
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
    
    private func resendOTP() {
        // Reset timer
        timeRemaining = 60
        canResend = false
        
        // Clear OTP fields
        otpDigits = Array(repeating: "", count: 6)
        focusedField = 0
        
        // TODO: Implement actual OTP resend logic
        print("Resending OTP to \(phoneNumber)")
    }
}

// MARK: - OTP Digit Field
struct OTPDigitField: View {
    @Binding var digit: String
    let isFocused: Bool
    let onCommit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
            
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isFocused
                        ? Color(hex: "16A34A")
                        : (digit.isEmpty ? Color(.systemGray5) : Color(hex: "16A34A").opacity(0.3)),
                    lineWidth: isFocused ? 2 : 1
                )
            
            // Digit text
            Text(digit)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            // Hidden TextField
            TextField("", text: $digit)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .multilineTextAlignment(.center)
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .onChange(of: digit) { oldValue, newValue in
                    // Only allow single digit
                    if newValue.count > 1 {
                        digit = String(newValue.suffix(1))
                    }
                    
                    // Filter to only numbers
                    digit = digit.filter { $0.isNumber }
                    
                    if !digit.isEmpty {
                        onCommit()
                    }
                }
                .onKeyPress(.delete) {
                    if digit.isEmpty {
                        onDelete()
                    } else {
                        digit = ""
                    }
                    return .handled
                }
        }
        .frame(width: 48, height: 56)
        .shadow(
            color: isFocused ? Color(hex: "16A34A").opacity(0.15) : Color.black.opacity(0.03),
            radius: isFocused ? 8 : 4,
            x: 0,
            y: 2
        )
        .animation(.spring(response: 0.3), value: isFocused)
    }
}

#Preview {
    OTPVerificationView(
        isLoggedIn: .constant(false),
        showProfileSwitcher: .constant(false),
        staySignedIn: .constant(false),
        phoneNumber: "+1 234 567 8900",
        isFirstTimeUser: true
    )
}
