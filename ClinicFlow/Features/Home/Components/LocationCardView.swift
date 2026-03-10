//
//  LocationCardView.swift
//  ClinicFlow
//

import SwiftUI

struct LocationCardView: View {
    @EnvironmentObject var hapticsManager: HapticsManager
    let appointment: AppointmentData
    @Binding var showMap: Bool
    var onNavigateToMap: ((_ originID: String, _ destinationID: String) -> Void)? = nil
    
    private var resolvedDestID: String {
        ClinicMapStore.roomID(forDepartment: appointment.department, roomNumber: appointment.roomNumber) ?? "entrance"
    }
    
    var body: some View {
        VStack(spacing: 16) {
            SectionHeader(icon: "location.fill", title: "Your Destination")
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Room \(appointment.roomNumber)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("\(appointment.department) Wing • \(appointment.floor)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    // Show resolved room ID
                    Text(resolvedDestID)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(hex: "16A34A"))
                }
                
                Spacer()
                
                // Mini floor plan preview
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "16A34A").opacity(0.08))
                        .frame(width: 80, height: 80)
                    
                    VStack(spacing: 4) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "16A34A"))
                        Text(appointment.floor)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color(hex: "16A34A"))
                    }
                }
            }
            
            // Directions Button
            Button(action: {
                hapticsManager.playNavigationSound()
                if let navigate = onNavigateToMap {
                    navigate("entrance", resolvedDestID)
                } else {
                    showMap = true
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Get Directions")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color(hex: "16A34A").opacity(0.2), radius: 6, y: 3)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
}
