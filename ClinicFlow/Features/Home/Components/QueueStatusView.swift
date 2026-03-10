//
//  QueueStatusView.swift
//  ClinicFlow
//

import SwiftUI

struct QueueStatusView: View {
    let appointment: AppointmentData
    
    var body: some View {
        VStack(spacing: 16) {
            SectionHeader(icon: "person.2.fill", title: "Queue Status")
            
            HStack(spacing: 16) {
                // Current Token
                VStack(spacing: 6) {
                    Text("NOW SERVING")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(0.8)
                        .foregroundColor(.secondary)
                    
                    Text(appointment.currentToken)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "16A34A"))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "16A34A").opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                // Your Token
                VStack(spacing: 6) {
                    Text("YOUR TOKEN")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(0.8)
                        .foregroundColor(.secondary)
                    
                    Text(appointment.tokenNumber)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            // Progress Indicator
            VStack(spacing: 10) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "16A34A"))
                            .frame(width: geometry.size.width * 0.7)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Text("\(appointment.patientsAhead) patients ahead of you")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("~\(appointment.estimatedWait)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "16A34A"))
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
}
