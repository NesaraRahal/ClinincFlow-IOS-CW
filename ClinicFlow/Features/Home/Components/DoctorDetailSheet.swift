//
//  DoctorDetailSheet.swift
//  ClinicFlow
//

import SwiftUI

struct DoctorDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var hapticsManager: HapticsManager
    let appointment: AppointmentData
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Hero Section with Doctor Image
                        ZStack(alignment: .bottom) {
                            // Doctor photo
                            Image("doctor_sarah")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 320)
                                .clipped()
                            
                            // Gradient overlay for text readability
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.clear,
                                    Color.black.opacity(0.6)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            
                            // Doctor Details Overlay
                            VStack(spacing: 6) {
                                // Rating Badge
                                HStack(spacing: 6) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.orange)
                                    
                                    Text(appointment.doctorRating)
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Capsule())
                                
                                Text(appointment.doctorName)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("\(appointment.doctorRole) · \(appointment.department)")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding(.bottom, 20)
                        }
                        .frame(height: 320)
                        
                        // Content Section
                        VStack(spacing: 16) {
                            // Three Cards Layout
                            HStack(spacing: 10) {
                                DoctorStatsCard(icon: "calendar", value: "12+", label: "Years Exp", color: Color(red: 0.95, green: 0.94, blue: 1.0), iconColor: Color(hex: "16A34A"), width: 85)
                                DoctorStatsCard(icon: "person.2.fill", value: "5000+", label: "Patients", color: Color(red: 1.0, green: 0.95, blue: 0.9), iconColor: .orange, width: nil)
                                DoctorStatsCard(icon: "star.fill", value: appointment.doctorRating, label: "Rating", color: Color(red: 0.92, green: 0.98, blue: 0.93), iconColor: .orange, width: 85)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            // Location Card
                            DoctorLocationCard(appointment: appointment)
                            
                            // Specializations Section
                            DoctorSpecializationsCard(department: appointment.department)
                            
                            // Education & Certifications
                            DoctorEducationCard(department: appointment.department)
                            
                            Spacer().frame(height: 40)
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 16))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }
}

// MARK: - Doctor Stats Card
struct DoctorStatsCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let iconColor: Color
    var width: CGFloat? = nil
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
            
            Text(value)
                .font(.system(size: width == nil ? 22 : 24, weight: .bold))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: width == nil ? .infinity : width)
        .frame(height: 95)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Doctor Location Card
struct DoctorLocationCard: View {
    let appointment: AppointmentData
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: "16A34A").opacity(0.12))
                    .frame(width: 48, height: 48)
                
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "16A34A"))
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text("Location")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text("Room \(appointment.roomNumber) · \(appointment.department) Wing · \(appointment.floor)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }
}

// MARK: - Doctor Specializations Card
struct DoctorSpecializationsCard: View {
    let department: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "16A34A"))
                
                Text("Specializations")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            HStack(spacing: 8) {
                SpecializationTag(text: department)
                SpecializationTag(text: "Patient Care")
                SpecializationTag(text: "Medical Consultation")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "16A34A").opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }
}

// MARK: - Doctor Education Card
struct DoctorEducationCard: View {
    let department: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "16A34A"))
                
                Text("Education & Certifications")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                EducationRow(text: "MBBS - Medical University (2010)")
                EducationRow(text: "MD - \(department) - Specialized Institute (2014)")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }
}

// MARK: - Specialization Tag
struct SpecializationTag: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "16A34A"))
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color(hex: "16A34A").opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Education Row
struct EducationRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color(hex: "16A34A"))
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            
            Text(text)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
        }
    }
}
