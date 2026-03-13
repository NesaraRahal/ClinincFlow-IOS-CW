import SwiftUI

// MARK: - Payment Selection View
// Shown after the appointment summary — lets the user pick a payment method,
// shows a processing animation, then hands off to AppointmentConfirmedView.
struct PaymentSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var hapticsManager: HapticsManager

    let totalAmount: String
    let doctor: SpecialistDoctor
    let date: String
    let time: String
    let patientName: String
    var onAppointmentBooked: ((AppointmentData) -> Void)? = nil

    @State private var selectedMethod: PaymentMethod = .payOnArrival
    @State private var paymentState: PaymentState = .selecting
    @State private var processingComplete = false
    @State private var spinAngle: Double = 0
    @State private var showConfirmed = false

    // MARK: - Types
    enum PaymentState { case selecting, processing }

    enum PaymentMethod: String, CaseIterable, Identifiable {
        case payOnArrival = "Pay on Arrival"
        case card         = "Credit / Debit Card"
        case applePay     = "Apple Pay"
        case googlePay    = "Google Pay"

        var id: String { rawValue }

        var subtitle: String {
            switch self {
            case .payOnArrival: return "Pay at the clinic counter on arrival"
            case .card:         return "Visa, Mastercard, Amex accepted"
            case .applePay:     return "Pay with Face ID or Touch ID"
            case .googlePay:    return "Pay with your Google account"
            }
        }

        var icon: String {
            switch self {
            case .payOnArrival: return "building.2.fill"
            case .card:         return "creditcard.fill"
            case .applePay:     return "apple.logo"
            case .googlePay:    return "g.circle.fill"
            }
        }

        var iconColor: Color {
            switch self {
            case .payOnArrival: return Color(hex: "16A34A")
            case .card:         return Color(hex: "2563EB")
            case .applePay:     return Color.primary
            case .googlePay:    return Color(hex: "4285F4")
            }
        }

        var isPayLater: Bool { self == .payOnArrival }
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            if paymentState == .selecting {
                selectionBody
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            } else {
                processingBody
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: paymentState)
        .fullScreenCover(isPresented: $showConfirmed) {
            AppointmentConfirmedView(
                doctor: doctor,
                date: date,
                time: time,
                patientName: patientName,
                onAppointmentBooked: onAppointmentBooked
            )
        }
    }

    // MARK: - Selection Screen
    private var selectionBody: some View {
        VStack(spacing: 0) {
            // Top handle + header
            VStack(spacing: 0) {
                Capsule()
                    .fill(Color.secondary.opacity(0.25))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 16)

                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.secondary)
                            .frame(width: 34, height: 34)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text("Payment")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)

                    Spacer()

                    // Invisible spacer so title stays centred
                    Color.clear.frame(width: 34, height: 34)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
            .background(Color(.systemGroupedBackground))

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // Amount hero card
                    VStack(spacing: 6) {
                        Text("Total Due")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .tracking(1)

                        Text(totalAmount)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)

                        Text("\(doctor.specialty) · \(doctor.name)")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)

                    // Payment method cards
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Choose how to pay")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)

                        ForEach(PaymentMethod.allCases) { method in
                            PaymentMethodCard(
                                method: method,
                                isSelected: selectedMethod == method
                            ) {
                                hapticsManager.playTapSound()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedMethod = method
                                }
                            }
                        }
                    }

                    // Security badge
                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "16A34A").opacity(0.7))
                        Text("256-bit SSL encrypted · PCI DSS compliant")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 130)
            }
        }
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                // Pay on Arrival info banner
                if selectedMethod.isPayLater {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "16A34A"))
                        Text("No payment needed now — pay at the counter on arrival")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // CTA button
                Button(action: {
                    hapticsManager.playConfirmSound()
                    withAnimation(.easeInOut(duration: 0.4)) {
                        paymentState = .processing
                    }
                    startProcessing()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: selectedMethod.isPayLater ? "checkmark.circle.fill" : "lock.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text(selectedMethod.isPayLater ? "Confirm Booking" : "Pay \(totalAmount)")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color(hex: "16A34A").opacity(0.35), radius: 12, x: 0, y: 5)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
            .animation(.spring(response: 0.35), value: selectedMethod)
            .background(
                Color(.systemBackground)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: -4)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }

    // MARK: - Processing Screen
    private var processingBody: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 36) {
                // Spinner / Checkmark ring
                ZStack {
                    // Track ring
                    Circle()
                        .stroke(Color(hex: "16A34A").opacity(0.12), lineWidth: 5)
                        .frame(width: 96, height: 96)

                    if !processingComplete {
                        // Spinning arc
                        Circle()
                            .trim(from: 0, to: 0.72)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 5, lineCap: .round)
                            )
                            .frame(width: 96, height: 96)
                            .rotationEffect(.degrees(spinAngle))
                            .transition(.opacity)
                    } else {
                        // Success checkmark
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 72, height: 72)
                            Image(systemName: "checkmark")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .transition(.scale(scale: 0.3).combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.65), value: processingComplete)

                // Status text
                VStack(spacing: 10) {
                    Text(processingComplete
                         ? (selectedMethod.isPayLater ? "Booking Confirmed!" : "Payment Successful!")
                         : (selectedMethod.isPayLater ? "Confirming Booking…" : "Processing Payment…"))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)

                    Text(processingComplete
                         ? "Your appointment is all set 🎉"
                         : processingSubtitle)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // "via" method badge — hidden once complete
                if !processingComplete {
                    HStack(spacing: 8) {
                        Image(systemName: selectedMethod.icon)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(selectedMethod.iconColor)
                        Text("via \(selectedMethod.rawValue)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: processingComplete)
            .padding(.horizontal, 40)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                spinAngle = 360
            }
        }
    }

    // MARK: - Helpers
    private var processingSubtitle: String {
        switch selectedMethod {
        case .payOnArrival: return "Setting up your appointment"
        case .card:         return "Securely processing your payment"
        case .applePay:     return "Verifying with Apple Pay"
        case .googlePay:    return "Verifying with Google Pay"
        }
    }

    private func startProcessing() {
        // Show checkmark after 2.2 s
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                processingComplete = true
            }
            hapticsManager.mediumTap()
        }
        // Navigate to confirmed after 3.6 s
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.6) {
            showConfirmed = true
        }
    }
}

// MARK: - Payment Method Card
struct PaymentMethodCard: View {
    let method: PaymentSelectionView.PaymentMethod
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Icon box
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(method.iconColor.opacity(isSelected ? 0.16 : 0.09))
                        .frame(width: 50, height: 50)
                    Image(systemName: method.icon)
                        .font(.system(size: 21))
                        .foregroundColor(method.iconColor)
                }

                // Text
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(method.rawValue)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        if method.isPayLater {
                            Text("Free now")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color(hex: "16A34A"))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Color(hex: "16A34A").opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                    Text(method.subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Radio button
                ZStack {
                    Circle()
                        .stroke(
                            isSelected ? Color(hex: "16A34A") : Color(.systemGray3),
                            lineWidth: isSelected ? 2 : 1.5
                        )
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(Color(hex: "16A34A"))
                            .frame(width: 12, height: 12)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isSelected ? Color(hex: "16A34A") : Color.clear,
                        lineWidth: 2
                    )
            )
            .shadow(
                color: isSelected
                    ? Color(hex: "16A34A").opacity(0.14)
                    : Color.black.opacity(0.04),
                radius: isSelected ? 12 : 6,
                x: 0, y: 2
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PaymentSelectionView(
        totalAmount: "LKR 2,700",
        doctor: sampleDoctors[0],
        date: "Monday, 16 March 2026",
        time: "10:00 AM",
        patientName: "Kavindu Perera"
    )
    .environmentObject(HapticsManager())
}
