//
//  VisitProgressDetailView.swift
//  ClinicFlow
//

import SwiftUI

// MARK: - Visit Progress Detail View
// Expanded view of the patient's visit steps and queue information
struct VisitProgressDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var hapticsManager: HapticsManager
    
    let appointment: AppointmentData
    let patientSteps: [PatientVisitStep]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Token Summary Card
                    VStack(spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "ticket.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "16A34A"))
                            
                            Text("TOKEN")
                                .font(.system(size: 12, weight: .bold))
                                .tracking(1)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(appointment.tokenNumber)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "16A34A"))
                        
                        Text(appointment.department)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color(hex: "16A34A").opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 20)
                    
                    // Queue Info
                    HStack(spacing: 16) {
                        QueueInfoCard(
                            title: "NOW SERVING",
                            value: appointment.currentToken,
                            color: Color(hex: "16A34A")
                        )
                        
                        QueueInfoCard(
                            title: "AHEAD",
                            value: "\(appointment.patientsAhead)",
                            color: .orange
                        )
                        
                        QueueInfoCard(
                            title: "EST. WAIT",
                            value: appointment.estimatedWait,
                            color: .blue
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Steps Timeline
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "16A34A"))
                            
                            Text("Visit Steps")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        .padding(.bottom, 20)
                        
                        ForEach(Array(patientSteps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 16) {
                                // Timeline
                                VStack(spacing: 0) {
                                    ZStack {
                                        Circle()
                                            .fill(step.isCompleted ? Color(hex: "16A34A") : (step.isCurrent ? Color(hex: "16A34A").opacity(0.2) : Color(.systemGray5)))
                                            .frame(width: 32, height: 32)
                                        
                                        if step.isCompleted {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.white)
                                        } else if step.isCurrent {
                                            Circle()
                                                .fill(Color(hex: "16A34A"))
                                                .frame(width: 12, height: 12)
                                        }
                                    }
                                    
                                    if index < patientSteps.count - 1 {
                                        Rectangle()
                                            .fill(step.isCompleted ? Color(hex: "16A34A") : Color(.systemGray4))
                                            .frame(width: 2, height: 40)
                                    }
                                }
                                
                                // Step Info
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(step.title)
                                        .font(.system(size: 16, weight: step.isCurrent || step.isCompleted ? .semibold : .medium))
                                        .foregroundColor(step.isCurrent || step.isCompleted ? .primary : .secondary)
                                    
                                    if step.isCurrent {
                                        Text("In progress...")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(Color(hex: "16A34A"))
                                    } else if step.isCompleted {
                                        Text("Completed")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.bottom, index < patientSteps.count - 1 ? 20 : 0)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                    .padding(.horizontal, 20)
                    
                    // Room Info
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Destination")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                            
                            Text("Room \(appointment.roomNumber)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("\(appointment.department) • \(appointment.floor)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "16A34A").opacity(0.1))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "door.left.hand.open")
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex: "16A34A"))
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Visit Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "16A34A"))
                }
            }
        }
        .onAppear {
            let currentStep = patientSteps.first(where: { $0.isCurrent })?.title ?? "Unknown"
            hapticsManager.speak("Visit progress. Current step: \(currentStep). \(appointment.patientsAhead) patients ahead.")
        }
    }
}

// MARK: - Queue Info Card
struct QueueInfoCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .tracking(0.5)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    VisitProgressDetailView(
        appointment: AppointmentData.randomForService("OPD"),
        patientSteps: [
            PatientVisitStep(title: "Check-in", isCompleted: true, isCurrent: false),
            PatientVisitStep(title: "Wait", isCompleted: false, isCurrent: true),
            PatientVisitStep(title: "Consult", isCompleted: false, isCurrent: false),
            PatientVisitStep(title: "Done", isCompleted: false, isCurrent: false)
        ]
    )
    .environmentObject(HapticsManager())
}
