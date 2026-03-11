//
//  MyVisitsView.swift
//  ClinicFlow
//

import SwiftUI

// MARK: - My Visits View
struct MyVisitsView: View {
    @EnvironmentObject var visitsManager: VisitsManager
    @EnvironmentObject var hapticsManager: HapticsManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Visits")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("\(visitsManager.visits.count) total visits")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color(hex: "16A34A").opacity(0.12))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "16A34A"))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
            
            if visitsManager.visits.isEmpty {
                // Empty State
                Spacer()
                
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "calendar")
                            .font(.system(size: 32))
                            .foregroundColor(Color(.systemGray3))
                    }
                    
                    Text("No Visits Yet")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Your visit history will appear here")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            } else {
                // Visits List
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(visitsManager.visits) { visit in
                            VisitCard(visit: visit)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            hapticsManager.speak("My Visits. \(visitsManager.visits.count) total visits.")
        }
    }
}

// MARK: - Visit Card
struct VisitCard: View {
    let visit: VisitRecord
    
    var statusColor: Color {
        switch visit.status {
        case .active: return Color(hex: "16A34A")
        case .completed: return .blue
        case .cancelled: return .red
        }
    }
    
    var statusText: String {
        switch visit.status {
        case .active: return "Active"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Token Badge
            VStack(spacing: 4) {
                Text(visit.tokenNumber)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(statusColor)
            }
            .frame(width: 60)
            .padding(.vertical, 12)
            .background(statusColor.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(visit.department)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(visit.doctorName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text("Room \(visit.roomNumber) • \(visit.floor)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Status Badge
            Text(statusText)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(statusColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(statusColor.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    MyVisitsView()
        .environmentObject(VisitsManager())
        .environmentObject(HapticsManager())
}
