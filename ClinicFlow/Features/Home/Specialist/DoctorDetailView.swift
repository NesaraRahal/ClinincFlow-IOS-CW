//
//  DoctorDetailView.swift
//  ClinicFlow
//
//  Created by COBSCCOMP24.2P-053 on 2026-03-03.
//

import SwiftUI

enum OPDStatus {
    case ongoing
    case closed
    case startingAt(String)
    
    var color: Color {
        switch self {
        case .ongoing: return .green
        case .closed: return .red
        case .startingAt: return .orange
        }
    }
    
    var text: String {
        switch self {
        case .ongoing: return "Ongoing"
        case .closed: return "Closed"
        case .startingAt(let time): return "Starting at \(time)"
        }
    }
    
    var icon: String {
        switch self {
        case .ongoing: return "circle.fill"
        case .closed: return "circle.fill"
        case .startingAt: return "circle.fill"
        }
    }
}

struct DoctorDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var hapticsManager: HapticsManager
    
    // Sample data
    let doctorName = "Dr. Sarah Ahmed"
    let specialization = "General Physician"
    let qualification = "MBBS, MD"
    let opdStatus: OPDStatus = .ongoing
    let appointmentDate = "Tomorrow, Feb 25"
    let timeSlot = "4:00 PM – 7:00 PM"
    let floorRoom = "2nd Floor, Room 204"
    let queueCount = 12
    let nextTokenNumber = 13
    let arrivalTime = "5:30 PM"
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Adaptive background
                Color(.systemBackground).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Hero Section with Doctor Image
                        ZStack(alignment: .bottom) {
                            // Doctor photo
                            Image("doctor_sarah")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 380)
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
                                // Status Badge
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(opdStatus.color)
                                        .frame(width: 8, height: 8)
                                    
                                    Text(opdStatus.text)
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Capsule())
                                
                                Text(doctorName)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("\(specialization) · \(qualification)")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding(.bottom, 20)
                        }
                        .frame(height: 380)
                        
                        // Content Section
                        VStack(spacing: 16) {
                            // Three Cards Layout
                            HStack(spacing: 10) {
                                // Queue Card
                                VStack(spacing: 6) {
                                    Image(systemName: "person.3.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.orange)
                                    
                                    Text("\(queueCount)")
                                        .font(.system(size: 26, weight: .bold))
                                        .foregroundColor(.primary)
                                    
                                    Text("In Queue")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: 85, height: 95)
                                .background(Color(red: 1.0, green: 0.95, blue: 0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                
                                // Date & Time Card
                                VStack(spacing: 8) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "calendar")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text("Feb 25")
                                            .font(.system(size: 15, weight: .semibold))
                                    }
                                    .foregroundColor(Color(hex: "16A34A"))
                                    
                                    Rectangle()
                                        .fill(Color(hex: "16A34A").opacity(0.2))
                                        .frame(height: 1)
                                        .padding(.horizontal, 12)
                                    
                                    HStack(spacing: 6) {
                                        Image(systemName: "clock.fill")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text("4 – 7 PM")
                                            .font(.system(size: 15, weight: .semibold))
                                    }
                                    .foregroundColor(Color(hex: "16A34A"))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 95)
                                .background(Color(red: 0.95, green: 0.94, blue: 1.0))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                
                                // Arrival Time Card
                                VStack(spacing: 6) {
                                    Image(systemName: "clock.badge.checkmark.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.green)
                                    
                                    Text(arrivalTime)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.primary)
                                    
                                    Text("Arrive By")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: 85, height: 95)
                                .background(Color(red: 0.92, green: 0.98, blue: 0.93))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            // Location Card
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
                                    
                                    Text(floorRoom)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(.systemGray3))
                            }
                            .padding(16)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal, 20)
                            
                            // Consultation Fee & Experience Row
                            HStack(spacing: 12) {
                                // Consultation Fee
                                HStack(spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.green.opacity(0.15))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "creditcard.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.green)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Consultation")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.secondary)
                                        
                                        Text("Rs. 1,500")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.primary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(14)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                
                                // Next Token
                                HStack(spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "16A34A").opacity(0.15))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "ticket.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: "16A34A"))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Next Token")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.secondary)
                                        
                                        Text("#13")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.primary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(14)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 4)
                            .padding(.top, 4)
                            
                            // Important Notes
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 8) {
                                    Image(systemName: "info.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.orange)
                                    
                                    Text("Important Notes")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    NoteRow(text: "Please arrive 15 minutes before your appointment")
                                    NoteRow(text: "Bring your previous medical records if available")
                                    NoteRow(text: "Wear a mask inside the clinic premises")
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.orange.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal, 20)
                            .padding(.top, 4)
                            
                            Spacer().frame(height: 100)
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
            .safeAreaInset(edge: .bottom) {
                // Book Appointment Button
                Button(action: {
                    hapticsManager.playConfirmSound()
                    print("Book Appointment tapped")
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text("Book Appointment")
                            .font(.system(size: 17, weight: .semibold))
                        
                        Text("·")
                            .font(.system(size: 18, weight: .bold))
                        
                        Text("Token #\(nextTokenNumber)")
                            .font(.system(size: 15, weight: .semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.25))
                            .clipShape(Capsule())
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
        }
    }
}

#Preview {
    DoctorDetailView()
        .environmentObject(HapticsManager())
}

struct NoteRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color.orange)
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            
            Text(text)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
        }
    }
}
