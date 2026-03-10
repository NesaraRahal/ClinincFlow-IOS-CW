//
//  TokenCardView.swift
//  ClinicFlow
//

import SwiftUI

struct TokenCardView: View {
    let appointment: AppointmentData
    
    var body: some View {
        VStack(spacing: 16) {
            // Patient Name Badge (for family member bookings)
            if appointment.patientName != "Self" {
                HStack(spacing: 6) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 11))
                    Text("Booking for \(appointment.patientName)")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.6))
                .clipShape(Capsule())
            }
            
            // MARK: - Priority Layout with Center Focus
            ZStack {
                // Center Column: Now Serving (top) + Your Token (bottom)
                VStack(spacing: 12) {
                    // Now Serving - Center Top (Priority 1)
                    VStack(spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "megaphone.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "16A34A"))
                            
                            Text("NOW SERVING")
                                .font(.system(size: 12, weight: .bold))
                                .tracking(1.2)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(appointment.currentToken)
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "16A34A"))
                            .shadow(color: Color.white.opacity(0.8), radius: 0, x: 0, y: -1)
                    }
                    .frame(width: 160)
                    .padding(.vertical, 28)
                    .background(
                        ZStack {
                            // Base color with slight gradient for depth
                            LinearGradient(
                                colors: [
                                    Color(hex: "16A34A").opacity(0.12),
                                    Color(hex: "16A34A").opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            
                            // Top highlight for raised effect
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.2),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                            
                            // Bottom shadow for depth
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.black.opacity(0.03)
                                ],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.8),
                                        Color.white.opacity(0.3),
                                        Color.gray.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color.white.opacity(0.5), radius: 1, x: 0, y: -1)
                    .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                    .shadow(color: Color(hex: "16A34A").opacity(0.15), radius: 15, x: 0, y: 8)
                    .shadow(color: Color.black.opacity(0.08), radius: 30, x: 0, y: 12)
                    
                    // Your Token - Center Bottom (Priority 2)
                    VStack(spacing: 12) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color.yellow.opacity(0.9), Color.yellow],
                                        center: .topLeading,
                                        startRadius: 1,
                                        endRadius: 8
                                    )
                                )
                                .frame(width: 8, height: 8)
                                .shadow(color: Color.yellow.opacity(0.5), radius: 3, x: 0, y: 0)
                            
                            Text("YOUR TOKEN")
                                .font(.system(size: 12, weight: .bold))
                                .tracking(1.2)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(appointment.tokenNumber)
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .shadow(color: Color.white.opacity(0.8), radius: 0, x: 0, y: -1)
                    }
                    .frame(width: 160)
                    .padding(.vertical, 28)
                    .background(
                        ZStack {
                            // Base color
                            Color(.systemBackground)
                            
                            // Top highlight for raised effect
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.8),
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                            
                            // Bottom subtle shadow for depth
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.black.opacity(0.02)
                                ],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.9),
                                        Color.white.opacity(0.4),
                                        Color.gray.opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.white, lineWidth: 0.5)
                            .blur(radius: 0.5)
                            .offset(y: -1)
                            .mask(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white, Color.clear],
                                            startPoint: .top,
                                            endPoint: .center
                                        )
                                    )
                            )
                    )
                    .shadow(color: Color.white.opacity(0.6), radius: 1, x: 0, y: -1)
                    .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                    .shadow(color: Color.black.opacity(0.06), radius: 15, x: 0, y: 8)
                    .shadow(color: Color.black.opacity(0.1), radius: 30, x: 0, y: 12)
                }
                
                // Left Side Card: Room Location (at vertical center)
                HStack {
                    VStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "16A34A"))
                        
                        Text(appointment.roomNumber)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .shadow(color: Color.white.opacity(0.8), radius: 0, x: 0, y: -1)
                        
                        Text(appointment.floor)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 85)
                    .padding(.vertical, 20)
                    .background(
                        ZStack {
                            // Base color
                            Color(.systemBackground)
                            
                            // Top highlight
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.8),
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                            
                            // Bottom shadow
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.black.opacity(0.02)
                                ],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.9),
                                        Color.white.opacity(0.4),
                                        Color.gray.opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.white, lineWidth: 0.5)
                            .blur(radius: 0.5)
                            .offset(y: -1)
                            .mask(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white, Color.clear],
                                            startPoint: .top,
                                            endPoint: .center
                                        )
                                    )
                            )
                    )
                    .shadow(color: Color.white.opacity(0.6), radius: 1, x: 0, y: -1)
                    .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
                    .shadow(color: Color.black.opacity(0.08), radius: 24, x: 0, y: 10)
                    
                    Spacer()
                }
                .padding(.leading, 0)
                
                // Right Side Card: Queue Status (at vertical center)
                HStack {
                    Spacer()
                    
                    VStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "16A34A"))
                        
                        Text("\(appointment.patientsAhead)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .shadow(color: Color.white.opacity(0.8), radius: 0, x: 0, y: -1)
                        
                        Text("ahead")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        Text(appointment.estimatedWait)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "16A34A"))
                    }
                    .frame(width: 85)
                    .padding(.vertical, 20)
                    .background(
                        ZStack {
                            // Base color
                            Color(.systemBackground)
                            
                            // Top highlight
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.8),
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                            
                            // Bottom shadow
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.black.opacity(0.02)
                                ],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.9),
                                        Color.white.opacity(0.4),
                                        Color.gray.opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.white, lineWidth: 0.5)
                            .blur(radius: 0.5)
                            .offset(y: -1)
                            .mask(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white, Color.clear],
                                            startPoint: .top,
                                            endPoint: .center
                                        )
                                    )
                            )
                    )
                    .shadow(color: Color.white.opacity(0.6), radius: 1, x: 0, y: -1)
                    .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
                    .shadow(color: Color.black.opacity(0.08), radius: 24, x: 0, y: 10)
                }
                .padding(.trailing, 0)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

// MARK: - Token Stat Item (Kept for compatibility)
struct TokenStatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}
