//
//  MainTabView.swift
//  ClinicFlow
//
//  Created by COBSCCOMP24.2P-053 on 2026-03-03.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    @Binding var isLoggedIn: Bool

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
                    EmptyHomeView()
                case .map:
                    Text("Map")
                case .visits:
                    Text("Visits")
                case .settings:
                    Text("Settings")
                }
            }

            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)

    }
}

// MARK: - Custom Tab Bar (Liquid Glass Style)
struct CustomTabBar: View {
    @Binding var selectedTab: MainTabView.Tab
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTabView.Tab.allCases, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    animation: animation
                ) {
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
