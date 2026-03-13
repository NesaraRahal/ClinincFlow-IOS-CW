import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @EnvironmentObject var hapticsManager: HapticsManager
    @EnvironmentObject var visitsManager: VisitsManager
    @EnvironmentObject var profileManager: UserProfileManager
    @EnvironmentObject var familyManager: FamilyMembersManager
    @EnvironmentObject var activeProfileManager: ActiveProfileManager
    @Binding var isLoggedIn: Bool
    
    // All active appointments across all profiles
    @State private var allActiveAppointments: [AppointmentData] = []
    
    // Map deep-link navigation
    @State private var mapOriginID: String? = nil
    @State private var mapDestinationID: String? = nil
    
    // Appointments filtered for the current active profile
    private var profileAppointments: [AppointmentData] {
        let name = activeProfileManager.activeProfile.patientName(
            profileManager: profileManager,
            familyManager: familyManager
        )
        return allActiveAppointments.filter { $0.patientName == name }
    }

    private var prioritizedAppointment: AppointmentData? {
        profileAppointments.min {
            if $0.patientsAhead == $1.patientsAhead {
                return $0.tokenNumber < $1.tokenNumber
            }
            return $0.patientsAhead < $1.patientsAhead
        }
    }
    
    enum Tab: String, CaseIterable {
        case home = "Home"
        case map = "Map"
        case visits = "Visits"
        case settings = "Settings"
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .map: return "map.fill"
            case .visits: return "calendar.badge.clock"
            case .settings: return "gearshape.fill"
            }
        }
        
        var iconUnselected: String {
            switch self {
            case .home: return "house"
            case .map: return "map"
            case .visits: return "calendar"
            case .settings: return "gearshape"
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content
            Group {
                switch selectedTab {
                case .home:
                    if !profileAppointments.isEmpty {
                        PatientHomeView(
                            appointments: profileAppointments,
                            onCancelAppointment: { tokenNumber in
                                withAnimation(.spring()) {
                                    visitsManager.cancelVisitByToken(tokenNumber)
                                    allActiveAppointments.removeAll { $0.tokenNumber == tokenNumber }
                                }
                            },
                            onNavigateToMap: { originID, destID in
                                mapOriginID = originID
                                mapDestinationID = destID
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedTab = .map
                                }
                            },
                            onBookAnotherService: { data in
                                withAnimation(.spring()) {
                                    var bookingData = data
                                    bookingData.patientName = activeProfileManager.activeProfile.patientName(
                                        profileManager: profileManager,
                                        familyManager: familyManager
                                    )
                                    allActiveAppointments.append(bookingData)
                                    visitsManager.addVisit(from: bookingData)
                                }
                            }
                        )
                    } else {
                        EmptyHomeView(onAppointmentBooked: { data in
                            withAnimation(.spring()) {
                                // Auto-set the active profile's patient name
                                var bookingData = data
                                bookingData.patientName = activeProfileManager.activeProfile.patientName(
                                    profileManager: profileManager,
                                    familyManager: familyManager
                                )
                                allActiveAppointments.append(bookingData)
                                visitsManager.addVisit(from: bookingData)
                            }
                        })
                    }
                case .map:
                    MapTabView(
                        initialOriginID: mapOriginID,
                        initialDestinationID: mapDestinationID
                    )
                case .visits:
                    MyVisitsView()
                case .settings:
                    SettingsView(isLoggedIn: $isLoggedIn)
                }
            }

            if let prioritizedAppointment,
               selectedTab != .home {
                OngoingAppointmentBubble(
                    appointment: prioritizedAppointment,
                    extraCount: max(profileAppointments.count - 1, 0)
                ) {
                    hapticsManager.playTapSound()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                        selectedTab = .home
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 142)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: selectedTab)
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: profileAppointments.count)
        .onChange(of: selectedTab) { _, newTab in
            hapticsManager.playNavigationSound()
            hapticsManager.speak("\(newTab.rawValue) tab selected")
        }
        .onChange(of: visitsManager.visits) { _, _ in
            // Sync: remove appointments whose visits were cancelled/completed
            let activeTokens = Set(visitsManager.visits.filter { $0.status == .active }.map { $0.tokenNumber })
            allActiveAppointments.removeAll { !activeTokens.contains($0.tokenNumber) }
        }
    }
}

// MARK: - Custom Tab Bar (Liquid Glass Style)
struct CustomTabBar: View {
    @Binding var selectedTab: MainTabView.Tab
    @EnvironmentObject var hapticsManager: HapticsManager
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTabView.Tab.allCases, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    animation: animation
                ) {
                    hapticsManager.playNavigationSound()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background {
            // Liquid Glass Effect
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let tab: MainTabView.Tab
    let isSelected: Bool
    let animation: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(Color(hex: "16A34A").opacity(0.15))
                            .frame(width: 56, height: 32)
                            .matchedGeometryEffect(id: "TAB_BG", in: animation)
                    }
                    
                    Image(systemName: isSelected ? tab.icon : tab.iconUnselected)
                        .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? Color(hex: "16A34A") : .secondary)
                }
                .frame(height: 32)
                
                Text(tab.rawValue)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? Color(hex: "16A34A") : .secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabView(isLoggedIn: .constant(true))
        .environmentObject(UserProfileManager())
        .environmentObject(AppearanceManager())
        .environmentObject(HapticsManager())
        .environmentObject(VisitsManager())
        .environmentObject(FamilyMembersManager())
        .environmentObject(ActiveProfileManager())
}
