//
//  VisitCardView.swift
//  ClinicFlow
//
//  Created by COBSCCOMP242P-052 on 2026-02-27.
//

import SwiftUI

struct VisitCardView: View {
    let visit: Visit
    
    var body: some View {
        VStack(spacing: 12) {
            // MARK: - Top Row: icon + info + date chip + status
            HStack(spacing: 14) {
                // Department Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(visit.departmentColor.opacity(0.1))
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: visit.departmentIcon)
                        .font(.system(size: 21))
                        .foregroundColor(visit.departmentColor)
                }
                
                // Doctor & Department
                VStack(alignment: .leading, spacing: 4) {
                    Text(visit.doctorName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if visit.patientName != "Self" {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 9))
                            Text("For: \(visit.patientName)")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.orange)
                    }
                    
                    Text(visit.department)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Right column: date chip + status badge
                VStack(alignment: .trailing, spacing: 6) {
                    // Appointment Date chip
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10, weight: .semibold))
                        Text(visit.shortAppointmentDate)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(visit.departmentColor)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(visit.departmentColor.opacity(0.1))
                    .clipShape(Capsule())
                    
                    statusBadge
                }
            }
            
            Divider()
                .padding(.vertical, 2)
            
            // MARK: - Footer Row: time · token · chevron
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text(visit.appointmentTime)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.secondary.opacity(0.8))
                
                Text("·")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary.opacity(0.4))
                
                HStack(spacing: 4) {
                    Image(systemName: "ticket")
                        .font(.system(size: 10))
                    Text("#\(visit.tokenNumber)")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                }
                .foregroundColor(visit.departmentColor.opacity(0.85))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(.systemGray3))
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Status Badge
    private var statusBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: visit.status.icon)
                .font(.system(size: 9))
            
            Text(visit.status.label)
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundColor(visit.status.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(visit.status.color.opacity(0.1))
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 12) {
        VisitCardView(visit: Visit(from: AppointmentData.randomForService("OPD")))
        VisitCardView(visit: {
            var v = Visit(from: AppointmentData.randomForService("Laboratory"))
            v.status = .completed
            return v
        }())
        VisitCardView(visit: {
            var v = Visit(from: AppointmentData.randomForService("Radiology"))
            v.status = .cancelled
            return v
        }())
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
