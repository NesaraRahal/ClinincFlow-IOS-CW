//
//  MyVisitsView.swift
//  ClinicFlow
//
//  Created by COBSCCOMP242P-052 on 2026-02-27.
//

import SwiftUI

struct MyVisitsView: View {
    @EnvironmentObject var visitsManager: VisitsManager
    @EnvironmentObject var hapticsManager: HapticsManager
    @EnvironmentObject var activeProfileManager: ActiveProfileManager
    @EnvironmentObject var profileManager: UserProfileManager
    @EnvironmentObject var familyManager: FamilyMembersManager
    @State private var selectedFilter: VisitFilter = .all
    @State private var selectedVisit: Visit? = nil
    @State private var showProfileSwitcher = false
    
    enum VisitFilter: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case completed = "Completed"
        case cancelled = "Cancelled"
    }
    
    /// Visits belonging to the active profile only
    private var profileVisits: [Visit] {
        let name = activeProfileManager.activeProfile.patientName(
            profileManager: profileManager,
            familyManager: familyManager
        )
        return visitsManager.visits.filter { $0.patientName == name }
    }
    
    /// Profile-filtered active visits
    private var profileActiveVisits: [Visit] {
        profileVisits.filter { $0.status == .active }
    }
    
    var filteredVisits: [Visit] {
        switch selectedFilter {
        case .all:
            return profileVisits.sorted { $0.bookedAt > $1.bookedAt }
        case .active:
            return profileActiveVisits
        case .completed:
            return profileVisits
                .filter { $0.status == .completed }
                .sorted { $0.bookedAt > $1.bookedAt }
        case .cancelled:
            return profileVisits
                .filter { $0.status == .cancelled }
                .sorted { $0.bookedAt > $1.bookedAt }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Stats Summary
                    if !profileVisits.isEmpty {
                        visitStatsSummary
                    }
                    
                    // Filter Chips
                    filterChips
                    
                    // Active Visits Section
                    if selectedFilter == .all || selectedFilter == .active {
                        if !profileActiveVisits.isEmpty {
                            activeVisitsSection
                        }
                    }
                    
                    // Visit Cards
                    if filteredVisits.isEmpty {
                        emptyStateView
                    } else {
                        let visitsToShow = selectedFilter == .all
                            ? filteredVisits.filter { $0.status != .active }
                            : (selectedFilter == .active ? [] : filteredVisits)
                        
                        if !visitsToShow.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                Text(selectedFilter == .all ? "Past Visits" : "\(selectedFilter.rawValue) Visits")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 4)
                                
                                ForEach(visitsToShow) { visit in
                                    VisitCardView(visit: visit)
                                        .onTapGesture {
                                            hapticsManager.playTapSound()
                                            selectedVisit = visit
                                        }
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 100)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("My Visits")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ActiveProfileButton(size: 34) {
                        hapticsManager.playTapSound()
                        showProfileSwitcher = true
                    }
                }
            }
            .sheet(item: $selectedVisit) { visit in
                VisitDetailView(visitID: visit.id)
            }
            .sheet(isPresented: $showProfileSwitcher) {
                NavigationStack {
                    ProfileSwitcherView()
                }
            }
            .onAppear {
                let activeCount = profileActiveVisits.count
                let pastCount = profileVisits.filter { $0.status != .active }.count
                let total = profileVisits.count
                if total == 0 {
                    hapticsManager.speak("My Visits tab. No visits yet. Book an appointment to see your visits here.")
                } else {
                    hapticsManager.speak("My Visits tab. \(activeCount) active and \(pastCount) past visits.")
                }
            }
        }
    }
    
    // MARK: - Stats Summary
    private var visitStatsSummary: some View {
        HStack(spacing: 12) {
            StatBadge(
                count: profileActiveVisits.count,
                label: "Active",
                color: Color(hex: "16A34A"),
                icon: "clock.fill"
            )
            
            StatBadge(
                count: profileVisits.filter { $0.status == .completed }.count,
                label: "Done",
                color: .blue,
                icon: "checkmark.circle.fill"
            )
            
            StatBadge(
                count: profileVisits.count,
                label: "Total",
                color: .purple,
                icon: "list.clipboard.fill"
            )
        }
    }
    
    // MARK: - Filter Chips
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(VisitFilter.allCases, id: \.self) { filter in
                    let count = countForFilter(filter)
                    
                    Button {
                        hapticsManager.playTapSound()
                        withAnimation(.spring(response: 0.3)) {
                            selectedFilter = filter
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(filter.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                            
                            if count > 0 {
                                Text("\(count)")
                                    .font(.system(size: 11, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(selectedFilter == filter
                                                  ? Color.white.opacity(0.3)
                                                  : Color(.systemGray4))
                                    )
                            }
                        }
                        .foregroundColor(selectedFilter == filter ? .white : .secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selectedFilter == filter
                                      ? Color(hex: "16A34A")
                                      : Color(.systemBackground))
                        )
                        .overlay {
                            Capsule()
                                .stroke(selectedFilter == filter
                                        ? Color.clear
                                        : Color(.systemGray4), lineWidth: 1)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Active Visits Section
    private var activeVisitsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Active Visits")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: "16A34A"))
                        .frame(width: 8, height: 8)
                        .overlay {
                            Circle()
                                .fill(Color(hex: "16A34A").opacity(0.3))
                                .frame(width: 16, height: 16)
                        }
                    
                    Text("\(profileActiveVisits.count) in progress")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "16A34A"))
                }
            }
            .padding(.horizontal, 4)
            
            ForEach(profileActiveVisits) { visit in
                ActiveVisitCard(visit: visit)
                    .onTapGesture {
                        hapticsManager.playTapSound()
                        selectedVisit = visit
                    }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 40)
            
            ZStack {
                Circle()
                    .fill(Color(hex: "16A34A").opacity(0.08))
                    .frame(width: 100, height: 100)
                
                Image(systemName: selectedFilter == .all ? "calendar.badge.clock" : "tray")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "16A34A").opacity(0.5))
            }
            
            VStack(spacing: 8) {
                Text(selectedFilter == .all ? "No Visits Yet" : "No \(selectedFilter.rawValue) Visits")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(selectedFilter == .all
                     ? "Book an appointment from the Home tab\nto see your visits here"
                     : "You don't have any \(selectedFilter.rawValue.lowercased()) visits")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer().frame(height: 40)
        }
    }
    
    // MARK: - Helper
    private func countForFilter(_ filter: VisitFilter) -> Int {
        switch filter {
        case .all: return profileVisits.count
        case .active: return profileActiveVisits.count
        case .completed: return profileVisits.filter { $0.status == .completed }.count
        case .cancelled: return profileVisits.filter { $0.status == .cancelled }.count
        }
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let count: Int
    let label: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                
                Text("\(count)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: color.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Active Visit Card
struct ActiveVisitCard: View {
    let visit: Visit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: visit.status.icon)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "16A34A"))
                    
                    Text("In Progress")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "16A34A"))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(hex: "16A34A").opacity(0.1))
                .clipShape(Capsule())
                
                Spacer()
                
                Text(visit.tokenNumber)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(hex: "16A34A"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(hex: "16A34A").opacity(0.08))
                    .clipShape(Capsule())
            }
            
            Divider()
            
            // Doctor Info
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(visit.departmentColor.opacity(0.12))
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: visit.departmentIcon)
                        .font(.system(size: 22))
                        .foregroundColor(visit.departmentColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(visit.doctorName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if visit.patientName != "Self" {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 9))
                            Text("For: \(visit.patientName)")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.orange)
                    }
                    
                    Text("\(visit.department) • \(visit.appointmentTime)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("Room \(visit.roomNumber) • \(visit.floor)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            // Mini Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Stage: \(visit.currentStepLabel)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(visit.progress * 100))%")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "16A34A"))
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.systemGray5))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * visit.progress, height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: "16A34A").opacity(0.25), lineWidth: 1.5)
        }
        .shadow(color: Color(hex: "16A34A").opacity(0.1), radius: 12, x: 0, y: 4)
    }
}

#Preview {
    MyVisitsView()
        .environmentObject(VisitsManager())
        .environmentObject(HapticsManager())
        .environmentObject(ActiveProfileManager())
        .environmentObject(UserProfileManager())
        .environmentObject(FamilyMembersManager())
}
