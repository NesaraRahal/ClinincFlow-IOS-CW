//
//  AppointmentConfirmedView.swift
//  ClinicFlow
//
//  Created by COBSCCOMP24.2P-053 on 2026-03-03.
//

import SwiftUI

// MARK: - Appointment Confirmed View
struct AppointmentConfirmedView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var hapticsManager: HapticsManager
    let doctor: SpecialistDoctor
    let date: String
    let time: String
    let patientName: String
    var onAppointmentBooked: ((AppointmentData) -> Void)? = nil
    
    @State private var showCheckmark = false
    @State private var showContent = false
    @State private var tokenNumber = "S\(Int.random(in: 10...99))"
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                Spacer().frame(height: 20)
                
                // MARK: - Animated Checkmark
                ZStack {
                    Circle()
                        .fill(Color(hex: "16A34A").opacity(0.1))
                        .frame(width: 130, height: 130)
                        .scaleEffect(showCheckmark ? 1 : 0.5)
                    
                    Circle()
                        .fill(Color(hex: "16A34A").opacity(0.2))
                        .frame(width: 100, height: 100)
                        .scaleEffect(showCheckmark ? 1 : 0.5)
                    
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
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(showCheckmark ? 1 : 0)
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showCheckmark)
                
                // MARK: - Title
                VStack(spacing: 8) {
                    Text("Appointment Confirmed!")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Your appointment has been\nsuccessfully booked")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 15)
                
                // MARK: - Token Card
                VStack(spacing: 12) {
                    Text("Your Token")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(tokenNumber)
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "16A34A"))
                    
                    Text("Please save this token number")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(hex: "16A34A").opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color(hex: "16A34A").opacity(0.15), lineWidth: 1)
                        )
                )
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 15)
                
                // MARK: - Appointment Details
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "16A34A"))
                        Text("Appointment Details")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    
                    VStack(spacing: 10) {
                        DetailRow(label: "Doctor", value: doctor.name)
                        DetailRow(label: "Specialty", value: doctor.specialty)
                        DetailRow(label: "Date", value: date)
                        DetailRow(label: "Time", value: time)
                        DetailRow(label: "Patient", value: patientName)
                        DetailRow(label: "Fee", value: doctor.consultationFee)
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 15)
                
                // MARK: - Requirements Card
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.orange)
                        Text("Requirements for Visit")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    
                    Text("Please bring the following items for your appointment:")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        RequirementItem(icon: "drop.fill", color: .red, text: "Recent Blood Report (within 3 months)")
                        RequirementItem(icon: "flask.fill", color: .orange, text: "Urine Report (within 1 month)")
                        RequirementItem(icon: "doc.text.fill", color: .blue, text: "Previous Medical Records")
                        RequirementItem(icon: "pills.fill", color: .purple, text: "Current Medication List")
                        RequirementItem(icon: "creditcard.fill", color: Color(hex: "16A34A"), text: "Valid ID / Insurance Card")
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                        )
                )
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 15)
                
                // MARK: - Important Note
                HStack(spacing: 10) {
                    Image(systemName: "clock.badge.exclamationmark")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "16A34A"))
                    
                    Text("Please arrive 15 minutes before your scheduled time")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "16A34A").opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .opacity(showContent ? 1 : 0)
                
                Spacer().frame(height: 80)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                hapticsManager.playSuccessSound()
                // Generate appointment data and redirect to PatientHomeView
                let appointmentData = AppointmentData.fromSpecialistBooking(
                    doctor: doctor,
                    date: date,
                    time: time,
                    tokenNumber: tokenNumber
                )
                onAppointmentBooked?(appointmentData)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 16))
                    Text("Finish")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color(hex: "16A34A"))
                .clipShape(Capsule())
                .shadow(color: Color(hex: "16A34A").opacity(0.35), radius: 10, x: 0, y: 4)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 20)
            .background(
                Color(.systemBackground)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: -4)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
        .onAppear {
            hapticsManager.playSuccessSound()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2)) {
                showCheckmark = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
                showContent = true
            }
        }
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Requirement Item
struct RequirementItem: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "circle")
                .font(.system(size: 16))
                .foregroundColor(Color(.systemGray4))
        }
    }
}

#Preview {
    AppointmentConfirmedView(
        doctor: sampleDoctors[0],
        date: "Monday, 15 January 2025",
        time: "09:30 AM",
        patientName: "Kavindu Perera"
    )
    .environmentObject(HapticsManager())
}
