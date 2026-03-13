//
//  VisitDetailView.swift
//  ClinicFlow
//
//  Created by COBSCCOMP242P-052 on 2026-02-27.
//

import SwiftUI

struct VisitDetailView: View {
    let visitID: UUID
    @EnvironmentObject var visitsManager: VisitsManager
    @EnvironmentObject var hapticsManager: HapticsManager
    @Environment(\.dismiss) private var dismiss
    @State private var showCancelConfirmation = false
    @State private var animateProgress = false
    
    private var visit: Visit? {
        visitsManager.visit(byID: visitID)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if let visit = visit {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            statusHeaderCard(visit)
                            
                            if visit.status == .active {
                                progressTrackerCard(visit)
                            }
                            
                            appointmentDetailsCard(visit)
                            doctorInfoCard(visit)
                            locationCard(visit)
                            
                            if visit.status == .active {
                                queueInfoCard(visit)
                            }
                            
                            bookingInfoCard(visit)
                            
                            if visit.status == .active {
                                actionButtons()
                            }
                            
                            Spacer().frame(height: 20)
                        }
                        .padding(20)
                    }
                } else {
                    VStack {
                        Text("Visit not found")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Visit Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        hapticsManager.playTapSound()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .alert("Cancel Visit?", isPresented: $showCancelConfirmation) {
                Button("Keep Visit", role: .cancel) {}
                Button("Cancel Visit", role: .destructive) {
                    if let v = visit {
                        hapticsManager.playErrorSound()
                        visitsManager.cancelVisit(v)
                        dismiss()
                    }
                }
            } message: {
                Text("Are you sure you want to cancel this visit? This action cannot be undone.")
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                    animateProgress = true
                }
                if let v = visit {
                    hapticsManager.speak("Visit details for \(v.doctorName), \(v.department). Status: \(v.status.label).")
                }
            }
        }
    }
    
    // MARK: - Status Header Card
    private func statusHeaderCard(_ visit: Visit) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(visit.status.color.opacity(0.12))
                    .frame(width: 72, height: 72)
                
                Circle()
                    .fill(visit.status.color.opacity(0.06))
                    .frame(width: 90, height: 90)
                
                Image(systemName: visit.departmentIcon)
                    .font(.system(size: 30))
                    .foregroundColor(visit.status.color)
            }
            
            Text(visit.tokenNumber)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
            
            HStack(spacing: 6) {
                Circle()
                    .fill(visit.status.color)
                    .frame(width: 8, height: 8)
                
                Text(visit.status.label.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(visit.status.color)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(visit.status.color.opacity(0.1))
            .clipShape(Capsule())
            
            if visit.patientName != "Self" {
                HStack(spacing: 6) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 12))
                    Text("Booking for \(visit.patientName)")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.orange)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.1))
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: visit.status.color.opacity(0.1), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - Progress Tracker Card
    private func progressTrackerCard(_ visit: Visit) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "16A34A"))
                
                Text("Visit Progress")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(Int(visit.progress * 100))%")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "16A34A"))
            }
            
            // Dynamic step count
            Text("\(visit.steps.filter { $0.isCompleted }.count) of \(visit.steps.count) steps completed")
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
                                ? geo.size.width * visit.progress
                                : 0,
                            height: 8
                        )
                        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: visit.progress)
                }
            }
            .frame(height: 8)
            
            // Stage Steps
            VStack(spacing: 0) {
                ForEach(Array(visit.steps.enumerated()), id: \.element.id) { index, step in
                    DynamicStepRow(
                        step: step,
                        isLast: index == visit.steps.count - 1
                    )
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Appointment Details Card
    private func appointmentDetailsCard(_ visit: Visit) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Appointment Details", icon: "calendar")
            
            VisitDetailRow(icon: "calendar", label: "Date", value: visit.appointmentDate)
            VisitDetailRow(icon: "clock", label: "Time", value: visit.appointmentTime)
            VisitDetailRow(icon: "number", label: "Token", value: visit.tokenNumber)
            VisitDetailRow(icon: "banknote", label: "Fee", value: visit.consultationFee)
            
            if visit.patientName != "Self" {
                VisitDetailRow(icon: "person.2.fill", label: "Patient", value: visit.patientName)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Doctor Info Card
    private func doctorInfoCard(_ visit: Visit) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Doctor Information", icon: "stethoscope")
            
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(visit.departmentColor.opacity(0.12))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                        .foregroundColor(visit.departmentColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(visit.doctorName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(visit.doctorRole)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        
                        Text(visit.doctorRating)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Location Card
    private func locationCard(_ visit: Visit) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Location", icon: "mappin.and.ellipse")
            
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(hex: "16A34A").opacity(0.1))
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "16A34A"))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Room \(visit.roomNumber)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(visit.floor)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(visit.department)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.8))
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Queue Info Card
    private func queueInfoCard(_ visit: Visit) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Queue Information", icon: "person.3.fill")
            
            HStack(spacing: 16) {
                QueueInfoBubble(value: "\(visit.patientsAhead)", label: "Ahead", icon: "person.2.fill", color: .orange)
                QueueInfoBubble(value: visit.currentToken, label: "Current", icon: "number.circle.fill", color: .blue)
                QueueInfoBubble(value: visit.estimatedWait, label: "Est. Wait", icon: "hourglass", color: Color(hex: "16A34A"))
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Booking Info Card
    private func bookingInfoCard(_ visit: Visit) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Booking Information", icon: "info.circle")
            
            VisitDetailRow(icon: "clock.badge.checkmark", label: "Booked On", value: visit.formattedBookedDate)
            VisitDetailRow(icon: "tag", label: "Department", value: visit.department)
            
            if visit.steps.contains(where: { $0.isAdditional }) {
                Divider()
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                    Text("\(visit.steps.filter { $0.isAdditional }.count) additional step(s) added by doctor")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Action Buttons
    private func actionButtons() -> some View {
        VStack(spacing: 12) {
            // Cancel Visit
            Button {
                hapticsManager.playTapSound()
                showCancelConfirmation = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 16))
                    Text("Cancel Visit")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.red.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
    
    // MARK: - Helpers
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "16A34A"))
            
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Dynamic Step Row
struct DynamicStepRow: View {
    let step: VisitStep
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Timeline
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(
                            step.isCompleted
                                ? Color(hex: "16A34A")
                                : step.isCurrent
                                    ? Color(hex: "16A34A").opacity(0.2)
                                    : Color(.systemGray5)
                        )
                        .frame(width: 28, height: 28)
                    
                    if step.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: step.icon)
                            .font(.system(size: 11))
                            .foregroundColor(
                                step.isCurrent ? Color(hex: "16A34A") : .secondary
                            )
                    }
                    
                    if step.isCurrent {
                        Circle()
                            .stroke(Color(hex: "16A34A"), lineWidth: 2)
                            .frame(width: 28, height: 28)
                    }
                }
                
                if !isLast {
                    Rectangle()
                        .fill(step.isCompleted ? Color(hex: "16A34A") : Color(.systemGray5))
                        .frame(width: 2, height: 28)
                }
            }
            
            // Label & Detail
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(step.label)
                        .font(.system(size: 14, weight: step.isCurrent ? .bold : step.isCompleted ? .semibold : .medium))
                        .foregroundColor(
                            step.isCurrent ? Color(hex: "16A34A")
                            : step.isCompleted ? .primary
                            : .secondary
                        )
                    
                    if step.isAdditional {
                        Text("NEW")
                            .font(.system(size: 8, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .clipShape(Capsule())
                    }
                }
                
                if step.isCurrent {
                    Text("Current stage")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "16A34A").opacity(0.7))
                }
                
                if step.isAdditional && !step.room.isEmpty {
                    Text("\(step.department) • Room \(step.room) • \(step.floor)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.8))
                }
            }
            .padding(.top, 4)
            
            Spacer()
        }
    }
}

// MARK: - Add Referral Step View
struct AddReferralStepView: View {
    let visitID: UUID
    @EnvironmentObject var visitsManager: VisitsManager
    @EnvironmentObject var hapticsManager: HapticsManager
    @Environment(\.dismiss) private var dismiss
    
    struct ReferralOption: Identifiable {
        let id = UUID()
        let label: String
        let icon: String
        let description: String
        let color: Color
        let builder: () -> VisitStep
    }
    
    let options: [ReferralOption] = [
        ReferralOption(label: "Lab Test", icon: "flask.fill", description: "General laboratory test • 2nd Floor", color: .purple, builder: Visit.labTestStep),
        ReferralOption(label: "Blood Test", icon: "drop.fill", description: "Blood work analysis • 2nd Floor", color: .red, builder: Visit.bloodTestStep),
        ReferralOption(label: "Radiology Scan", icon: "waveform.path.ecg", description: "X-Ray / CT / MRI • 3rd Floor", color: .orange, builder: Visit.radiologyStep),
        ReferralOption(label: "Collect Medicine", icon: "cross.case.fill", description: "Pharmacy pickup • Ground Floor", color: .blue, builder: Visit.pharmacyStep),
        ReferralOption(label: "Follow-up Consultation", icon: "arrow.triangle.2.circlepath", description: "Return to doctor after tests", color: Color(hex: "16A34A"), builder: Visit.followUpStep),
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Info Banner
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "16A34A"))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Doctor Referral")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Add additional steps to this visit as referred by your doctor")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(Color(hex: "16A34A").opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                    // Options
                    ForEach(options) { option in
                        Button {
                            hapticsManager.playConfirmSound()
                            let step = option.builder()
                            withAnimation(.spring(response: 0.3)) {
                                visitsManager.addReferralStep(step, to: visitID)
                            }
                            dismiss()
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(option.color.opacity(0.12))
                                        .frame(width: 48, height: 48)
                                    
                                    Image(systemName: option.icon)
                                        .font(.system(size: 20))
                                        .foregroundColor(option.color)
                                }
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(option.label)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text(option.description)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(option.color.opacity(0.6))
                            }
                            .padding(16)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add Referral Step")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - Visit Detail Row
struct VisitDetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Queue Info Bubble
struct QueueInfoBubble: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    VisitDetailView(visitID: UUID())
        .environmentObject(VisitsManager())
        .environmentObject(HapticsManager())
}
