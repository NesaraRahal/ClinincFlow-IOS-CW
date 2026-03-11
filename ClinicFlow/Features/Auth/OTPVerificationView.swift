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
    @State private var appearAnimation = false
    @State private var shakeOffset: CGFloat = 0
    @Environment(\.dismiss) var dismiss
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private let greenPrimary = Color(hex: "16A34A")
    private let greenLight = Color(hex: "22C55E")
    
    var otpCode: String {
        otpDigits.joined()
    }
    
    var isOTPComplete: Bool {
        otpCode.count == 6 && otpCode.allSatisfy { $0.isNumber }
    }
    
    var body: some View {
        ZStack {
            // Layered background
            Color(hex: "F0FDF4").ignoresSafeArea()
            
            // Decorative blobs
            GeometryReader { geo in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "BBF7D0").opacity(0.5), Color.clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 140
                        )
                    )
                    .frame(width: 280, height: 280)
                    .offset(x: geo.size.width - 80, y: -60)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "DCFCE7").opacity(0.4), Color.clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .offset(x: -40, y: geo.size.height - 200)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Back Button
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 44, height: 44)
                                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 3)
                            
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Spacer()
                    
                    // Step indicator
                    HStack(spacing: 6) {
                        Capsule()
                            .fill(greenPrimary.opacity(0.3))
                            .frame(width: 20, height: 4)
                        Capsule()
                            .fill(greenPrimary)
                            .frame(width: 20, height: 4)
                    }
                    
                    Spacer()
                    
                    // Invisible spacer for centering
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // MARK: - Icon
                        ZStack {
                            // Soft glow behind
                            Circle()
                                .fill(greenPrimary.opacity(0.08))
                                .frame(width: 110, height: 110)
                            
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [greenPrimary, greenLight],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 88, height: 88)
                                .shadow(color: greenPrimary.opacity(0.3), radius: 20, x: 0, y: 10)
                            
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(appearAnimation ? 1.0 : 0.5)
                        .opacity(appearAnimation ? 1 : 0)
                        .padding(.top, 12)
                        
                        // MARK: - Title & Description
                        VStack(spacing: 10) {
                            Text("Verification Code")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 4) {
                                Text("We sent a 6-digit code to")
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                
                                Text(phoneNumber)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(greenPrimary)
                            }
                        }
                        .multilineTextAlignment(.center)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 15)
                        
                        // MARK: - OTP Input Fields
                        HStack(spacing: 10) {
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
                        .padding(.horizontal, 20)
                        .offset(x: shakeOffset)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                        
                        // MARK: - Timer & Resend
                        VStack(spacing: 8) {
                            if !canResend {
                                // Circular progress timer
                                HStack(spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .stroke(Color(.systemGray5), lineWidth: 2.5)
                                            .frame(width: 28, height: 28)
                                        
                                        Circle()
                                            .trim(from: 0, to: CGFloat(timeRemaining) / 60.0)
                                            .stroke(greenPrimary, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                                            .frame(width: 28, height: 28)
                                            .rotationEffect(.degrees(-90))
                                            .animation(.linear(duration: 1), value: timeRemaining)
                                        
                                        Text("\(timeRemaining)")
                                            .font(.system(size: 10, weight: .bold, design: .rounded))
                                            .foregroundColor(greenPrimary)
                                    }
                                    
                                    Text("Resend code in \(timeRemaining)s")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                Button(action: resendOTP) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 14, weight: .bold))
                                        
                                        Text("Resend Code")
                                            .font(.system(size: 15, weight: .bold))
                                    }
                                    .foregroundColor(greenPrimary)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(greenPrimary.opacity(0.1))
                                    .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.top, 4)
                        
                        // MARK: - Stay Signed In
                        if isFirstTimeUser {
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    staySignedIn.toggle()
                                }
                            }) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(staySignedIn ? greenPrimary : Color.clear)
                                            .frame(width: 24, height: 24)
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(staySignedIn ? greenPrimary : Color(.systemGray3), lineWidth: 1.5)
                                            }
                                        
                                        if staySignedIn {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Stay Signed In")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        Text("Keep me logged in on this device")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.white)
                                )
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            staySignedIn ? greenPrimary.opacity(0.4) : Color(.systemGray5),
                                            lineWidth: 1
                                        )
                                }
                                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // MARK: - Verify Button
                        Button(action: verifyOTP) {
                            HStack(spacing: 10) {
                                if isVerifying {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Verify & Continue")
                                        .font(.system(size: 17, weight: .bold))
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 17))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                Group {
                                    if isOTPComplete {
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
                                color: isOTPComplete ? greenPrimary.opacity(0.35) : Color.clear,
                                radius: 12,
                                x: 0,
                                y: 6
                            )
                            .animation(.spring(response: 0.4), value: isOTPComplete)
                        }
                        .disabled(!isOTPComplete || isVerifying)
                        .padding(.horizontal, 24)
                        .padding(.top, 4)
                        
                        // Security notice
                        HStack(spacing: 6) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary.opacity(0.6))
                            
                            Text("Secured with end-to-end encryption")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary.opacity(0.6))
                        }
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                appearAnimation = true
            }
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
    
    private let greenPrimary = Color(hex: "16A34A")
    
    var body: some View {
        ZStack {
            // Background with subtle gradient
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
            
            // Border
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isFocused
                        ? greenPrimary
                        : (digit.isEmpty ? Color(.systemGray5) : greenPrimary.opacity(0.35)),
                    lineWidth: isFocused ? 2 : 1
                )
            
            // Bottom accent line when focused
            if isFocused {
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 1)
                        .fill(greenPrimary)
                        .frame(width: 20, height: 2.5)
                        .padding(.bottom, 8)
                }
            }
            
            // Digit text
            Text(digit)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            // Blinking cursor when empty + focused
            if digit.isEmpty && isFocused {
                RoundedRectangle(cornerRadius: 1)
                    .fill(greenPrimary)
                    .frame(width: 2, height: 24)
                    .opacity(isFocused ? 1 : 0)
                    .modifier(BlinkingModifier())
            }
            
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
        .frame(width: 50, height: 60)
        .shadow(
            color: isFocused ? greenPrimary.opacity(0.15) : Color.black.opacity(0.03),
            radius: isFocused ? 10 : 4,
            x: 0,
            y: isFocused ? 4 : 2
        )
        .scaleEffect(isFocused ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
    }
}

// MARK: - Blinking Cursor Modifier
struct BlinkingModifier: ViewModifier {
    @State private var isVisible = true
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    isVisible = false
                }
            }
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
