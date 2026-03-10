//
//  VisitProgressView.swift
//  ClinicFlow
//

import SwiftUI

struct VisitProgressView: View {
    let visitSteps: [PatientVisitStep]
    
    var body: some View {
        VStack(spacing: 16) {
            SectionHeader(icon: "arrow.right.circle.fill", title: "Visit Progress")
            
            HStack(spacing: 0) {
                ForEach(Array(visitSteps.enumerated()), id: \.offset) { index, step in
                    // Step Circle
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .stroke(
                                    step.isCompleted || step.isCurrent ? Color(hex: "16A34A") : Color(.systemGray4),
                                    lineWidth: 2
                                )
                                .frame(width: 32, height: 32)
                            
                            Circle()
                                .fill(step.isCompleted ? Color(hex: "16A34A") : Color.clear)
                                .frame(width: 26, height: 26)
                            
                            if step.isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            } else if step.isCurrent {
                                Circle()
                                    .fill(Color(hex: "16A34A"))
                                    .frame(width: 10, height: 10)
                            }
                        }
                        
                        Text(step.title)
                            .font(.system(size: 10, weight: step.isCurrent || step.isCompleted ? .semibold : .medium))
                            .foregroundColor(step.isCurrent || step.isCompleted ? .primary : .secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Connector Line
                    if index < visitSteps.count - 1 {
                        VStack {
                            Rectangle()
                                .fill(step.isCompleted ? Color(hex: "16A34A") : Color(.systemGray4))
                                .frame(height: 2)
                            Spacer()
                        }
                        .frame(height: 40)
                        .padding(.horizontal, -6)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
}

// MARK: - Visit Step Model
struct PatientVisitStep {
    let title: String
    let isCompleted: Bool
    let isCurrent: Bool
}
