//
//  AssignedStaffCardView.swift
//  ClinicFlow
//

import SwiftUI

struct AssignedStaffCardView: View {
    @EnvironmentObject var hapticsManager: HapticsManager
    let appointment: AppointmentData
    @Binding var showDoctorDetail: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            SectionHeader(
                icon: appointment.department == "Specialist Clinic" ? "stethoscope" : (appointment.department == "OPD" ? "stethoscope" : "person.badge.shield.checkmark.fill"),
                title: appointment.department == "Specialist Clinic" || appointment.department == "OPD" ? "Your Doctor" : "Assigned Staff"
            )
            
            Button(action: {
                hapticsManager.playTapSound()
                showDoctorDetail = true
            }) {
                HStack(spacing: 16) {
                    // Profile Image
                    Image("doctor_sarah")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "16A34A").opacity(0.2), lineWidth: 2)
                        )
                    
                    // Info
                    VStack(alignment: .leading, spacing: 6) {
                        Text(appointment.doctorName)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(appointment.doctorRole)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                            
                            Text(appointment.doctorRating)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Spacer()
                    
                    // View Profile Button
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
}
