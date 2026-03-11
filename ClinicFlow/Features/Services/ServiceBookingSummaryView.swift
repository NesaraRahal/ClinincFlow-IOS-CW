//
//  ServiceBookingSummaryView.swift
//  ClinicFlow
//

import SwiftUI

struct ServiceBookingSummaryView: View {
    @EnvironmentObject var hapticsManager: HapticsManager
    
    let serviceTitle: String
    let serviceIcon: String
    let patientName: String
    let selectedDate: Date
    let selectedTimeSlot: String
    let prescriptionImage: UIImage?
    let notes: String
    let onConfirm: () -> Void
    let onBack: () -> Void
    let onEdit: (String) -> Void
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM dd, yyyy"
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
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
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text("Review & Confirm")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Please review your appointment details")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Service Info
                VStack(spacing: 16) {
                    ServiceInfoRow(
                        icon: serviceIcon,
                        title: "Service",
                        value: serviceTitle,
                        color: Color(hex: "16A34A")
                    )
                    
                    Divider()
                    
                    if patientName != "Self" {
                        ServiceInfoRow(
                            icon: "person.fill",
                            title: "Patient",
                            value: patientName,
                            color: .orange
                        )
                        
                        Divider()
                    }
                }
                .padding(20)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                
                // Date & Time
                VStack(spacing: 16) {
                    HStack {
                        HStack(spacing: 10) {
                            Image(systemName: "calendar")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "16A34A"))
                            
                            Text("Date & Time")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            hapticsManager.playTapSound()
                            onEdit("date")
                        }) {
                            Text("Edit")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "16A34A"))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "calendar.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "16A34A").opacity(0.7))
                            
                            Text(formattedDate)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "16A34A").opacity(0.7))
                            
                            Text(selectedTimeSlot)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(20)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                
                // Prescription (if uploaded)
                if let prescriptionImage = prescriptionImage {
                    VStack(spacing: 16) {
                        HStack {
                            HStack(spacing: 10) {
                                Image(systemName: "doc.text.image")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(hex: "16A34A"))
                                
                                Text("Prescription")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                hapticsManager.playTapSound()
                                onEdit("prescription")
                            }) {
                                Text("Edit")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: "16A34A"))
                            }
                        }
                        
                        Image(uiImage: prescriptionImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        if !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes:")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.secondary)
                                
                                Text(notes)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                }
                
                // Important Info
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "16A34A"))
                        
                        Text("Important Information")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        InfoPoint(text: "Please arrive 10 minutes before your appointment")
                        InfoPoint(text: "Bring a valid ID and original prescription")
                        InfoPoint(text: "You will receive a token number after confirmation")
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "16A34A").opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                // Back Button
                Button(action: {
                    hapticsManager.playTapSound()
                    onBack()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "16A34A"))
                        .frame(width: 54, height: 54)
                        .background(Color(hex: "16A34A").opacity(0.1))
                        .clipShape(Circle())
                }
                
                // Confirm Button
                Button(action: {
                    hapticsManager.playConfirmSound()
                    onConfirm()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Confirm Booking")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(hex: "16A34A"))
                    .clipShape(Capsule())
                    .shadow(color: Color(hex: "16A34A").opacity(0.35), radius: 10, x: 0, y: 4)
                }
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
    }
}

// MARK: - Service Info Row
struct ServiceInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Info Point
struct InfoPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color(hex: "16A34A"))
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}
