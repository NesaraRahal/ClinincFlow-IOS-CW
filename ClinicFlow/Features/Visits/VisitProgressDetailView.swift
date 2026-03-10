//
//  VisitProgressDetailView.swift
//  ClinicFlow
//

import SwiftUI

struct VisitProgressDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var hapticsManager: HapticsManager
    
    let appointment: AppointmentData
    let visitSteps: [VisitStep]
    
    @State private var animateProgress = false
    
    // Convert AppointmentData visitSteps to VisitStep format
    init(appointment: AppointmentData, patientSteps: [PatientVisitStep]) {
        self.appointment = appointment
        
        // Convert PatientVisitStep to VisitStep
        var steps: [VisitStep] = []
        
        // Base steps
        steps.append(VisitStep(
            label: "Booked",
            icon: "calendar.badge.checkmark",
            department: appointment.department,
            room: appointment.roomNumber,
            floor: appointment.floor,
            isCompleted: true,
            isCurrent: false
        ))
        
        steps.append(VisitStep(
            label: "Checked In",
            icon: "person.badge.shield.checkmark.fill",
            department: appointment.department,
            room: appointment.roomNumber,
            floor: appointment.floor,
            isCompleted: true,
            isCurrent: false
        ))
        
        steps.append(VisitStep(
            label: "Waiting",
            icon: "hourglass",
            department: appointment.department,
            room: appointment.roomNumber,
            floor: appointment.floor,
            isCompleted: false,
            isCurrent: true
        ))
        
        steps.append(VisitStep(
            label: "In Consultation",
            icon: "stethoscope",
            department: appointment.department,
            room: appointment.roomNumber,
            floor: appointment.floor,
            isCompleted: false,
            isCurrent: false
        ))
        
        // Add department-specific steps
        switch appointment.department {
        case "Laboratory":
            steps.append(VisitStep(
                label: "Lab Test",
                icon: "flask.fill",
                department: "Laboratory",
                room: appointment.roomNumber,
                floor: appointment.floor,
                isCompleted: false,
                isCurrent: false,
                isAdditional: true
            ))
        case "Pharmacy":
            steps.append(VisitStep(
                label: "Collect Medicine",
                icon: "cross.case.fill",
                department: "Pharmacy",
                room: "G-05",
                floor: "Ground Floor",
                isCompleted: false,
                isCurrent: false,
                isAdditional: true
            ))
        case "Radiology":
            steps.append(VisitStep(
                label: "Radiology Scan",
                icon: "waveform.path.ecg",
                department: "Radiology",
                room: appointment.roomNumber,
                floor: appointment.floor,
                isCompleted: false,
                isCurrent: false,
                isAdditional: true
            ))
        case "Vaccination":
            steps.append(VisitStep(
                label: "Vaccination",
                icon: "syringe.fill",
                department: "Vaccination",
                room: appointment.roomNumber,
                floor: appointment.floor,
                isCompleted: false,
                isCurrent: false,
                isAdditional: true
            ))
        default:
            break
        }
        
        // Final step
        steps.append(VisitStep(
            label: "Completed",
            icon: "checkmark.seal.fill",
            department: appointment.department,
            room: appointment.roomNumber,
            floor: appointment.floor,
            isCompleted: false,
            isCurrent: false
        ))
        
        self.visitSteps = steps
    }
    
    var progress: Double {
        guard !visitSteps.isEmpty else { return 0 }
        let completed = visitSteps.filter { $0.isCompleted }.count
        return Double(completed) / Double(visitSteps.count)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header Icon
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
                        
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                    
                    // Title
                    VStack(spacing: 8) {
                        Text("Visit Progress")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Token: \(appointment.tokenNumber)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    
                    // Progress Card
                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: "16A34A"))
                            
                            Text("Overall Progress")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(Int(progress * 100))%")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "16A34A"))
                        }
                        
                        // Dynamic step count
                        Text("\(visitSteps.filter { $0.isCompleted }.count) of \(visitSteps.count) steps completed")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        // Progress Bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color(.systemGray5))
                                    .frame(height: 8)
                                
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: animateProgress
                                            ? geo.size.width * progress
                                            : 0,
                                        height: 8
                                    )
                                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: progress)
                            }
                        }
                        .frame(height: 8)
                        
                        // Stage Steps
                        VStack(spacing: 0) {
                            ForEach(Array(visitSteps.enumerated()), id: \.element.id) { index, step in
                                DynamicStepRow(
                                    step: step,
                                    isLast: index == visitSteps.count - 1
                                )
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 2)
                    
                    // Info Banner
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "16A34A"))
                            
                            Text("Visit Timeline")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        Text("Your visit progress is tracked in real-time. Additional steps may be added if the doctor prescribes tests or medication.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "16A34A").opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Spacer(minLength: 40)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        hapticsManager.playTapSound()
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.secondary, Color(.systemGray5))
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animateProgress = true
                }
                hapticsManager.speak("Visit Progress. \(visitSteps.filter { $0.isCompleted }.count) of \(visitSteps.count) steps completed.")
            }
        }
    }
}
