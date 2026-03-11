//
//  MapTabView.swift
//  ClinicFlow
//

import SwiftUI

// MARK: - Map Tab View
// Indoor clinic map with floor-based navigation
struct MapTabView: View {
    var initialOriginID: String? = nil
    var initialDestinationID: String? = nil
    
    @State private var selectedFloor = 0
    
    let floors = ["Ground", "1st Floor", "2nd Floor", "3rd Floor"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Clinic Map")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Navigate the clinic easily")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(Color(hex: "16A34A").opacity(0.12))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "map.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "16A34A"))
                    }
                }
                .padding(.horizontal, 20)
                
                // Floor Selector
                Picker("Floor", selection: $selectedFloor) {
                    ForEach(0..<floors.count, id: \.self) { index in
                        Text(floors[index]).tag(index)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
            }
            .padding(.top, 16)
            .padding(.bottom, 20)
            
            // Map Area
            ZStack {
                Color(.systemGray6)
                
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "map")
                            .font(.system(size: 40))
                            .foregroundColor(Color(.systemGray3))
                    }
                    
                    VStack(spacing: 8) {
                        Text("Indoor Map")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Interactive floor plans coming soon")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    if let dest = initialDestinationID {
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "16A34A"))
                                
                                Text("Navigating to: \(dest)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: "16A34A"))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(hex: "16A34A").opacity(0.1))
                            .clipShape(Capsule())
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    MapTabView()
}
