import SwiftUI

struct OngoingAppointmentBubble: View {
    let appointment: AppointmentData
    let extraCount: Int
    let action: () -> Void

    @State private var isExpanded = false
    @State private var isPressed = false
    @State private var didTriggerExpansion = false
    @State private var expandWorkItem: DispatchWorkItem?

    private var statusText: String {
        appointment.patientsAhead <= 0 ? "It's almost your turn" : "Queue is moving"
    }

    var body: some View {
        HStack {
            Spacer()

            Button(action: {
                guard !didTriggerExpansion else {
                    didTriggerExpansion = false
                    return
                }
                action()
            }) {
                Group {
                    if isExpanded {
                        expandedBubble
                    } else {
                        compactBubble
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(HoldTrackingButtonStyle(isPressed: $isPressed))
        }
        .onChange(of: isPressed) { _, pressed in
            if pressed {
                let workItem = DispatchWorkItem {
                    guard isPressed else { return }
                    didTriggerExpansion = true
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                        isExpanded = true
                    }
                }
                expandWorkItem?.cancel()
                expandWorkItem = workItem
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.22, execute: workItem)
            } else {
                expandWorkItem?.cancel()
                expandWorkItem = nil

                if isExpanded {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                        isExpanded = false
                    }
                }

                if didTriggerExpansion {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        didTriggerExpansion = false
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Ongoing appointment. Your token \(appointment.tokenNumber). Now serving \(appointment.currentToken). \(max(appointment.patientsAhead, 0)) patients ahead. Tap to view live status.")
        .accessibilityHint("Touch and hold to expand queue details.")
    }

    private var compactBubble: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.7), lineWidth: 1)
                    )
                    .frame(width: 70, height: 70)

                VStack(spacing: 2) {
                    Text("Now")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)

                    Text(appointment.currentToken)
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "16A34A"))
                }
            }

            Circle()
                .fill(Color(hex: "16A34A"))
                .frame(width: 14, height: 14)
                .overlay(
                    Circle()
                        .stroke(Color(.systemBackground), lineWidth: 2)
                )
                .offset(x: -2, y: 2)
        }
        .shadow(color: Color.black.opacity(0.12), radius: 14, x: 0, y: 7)
    }

    private var expandedBubble: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(hex: "16A34A"))
                    .frame(width: 8, height: 8)
                    .overlay {
                        Circle()
                            .fill(Color(hex: "16A34A").opacity(0.18))
                            .frame(width: 16, height: 16)
                    }

                Text("Queue Status")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "16A34A"))

                Spacer()

                if extraCount > 0 {
                    Text("+\(extraCount)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: 8) {
                CompactMetricChip(title: "Serving", value: appointment.currentToken, accent: Color(hex: "16A34A"))
                CompactMetricChip(title: "Your", value: appointment.tokenNumber, accent: Color(hex: "2563EB"))
                CompactMetricChip(title: "Ahead", value: "\(max(appointment.patientsAhead, 0))", accent: Color(hex: "F59E0B"))
            }

            HStack(spacing: 6) {
                Text(statusText)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.primary)

                Spacer()

                Text(appointment.estimatedWait)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.7), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 7)
    }
}

private struct HoldTrackingButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, pressed in
                isPressed = pressed
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

private struct CompactMetricChip: View {
    let title: String
    let value: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(accent.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    OngoingAppointmentBubble(
        appointment: AppointmentData(
            tokenNumber: "S24",
            department: "Specialist Clinic",
            doctorName: "Dr. Sarah Johnson",
            doctorRole: "Cardiologist",
            doctorRating: "4.8",
            roomNumber: "312",
            floor: "3rd Floor",
            appointmentDate: "Thursday, 13 March 2026",
            appointmentTime: "10:00 AM",
            consultationFee: "Rs. 3,500",
            patientName: "Self",
            patientsAhead: 3,
            estimatedWait: "15 Mins",
            currentToken: "S21"
        ),
        extraCount: 1,
        action: {}
    )
}
