//
//  HomeView.swift
//  ClinicFlow
//
//  Created by COBSCCOMP242P-052 on 2026-02-23.
//

import SwiftUI

struct HomeView: View {
    @Binding var isLoggedIn: Bool
    @Binding var showProfileSwitcher: Bool

    var body: some View {
        TabView {
            DashboardView(isLoggedIn: $isLoggedIn)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            Text("Appointments")
                .tabItem {
                    Label("Appointments", systemImage: "calendar")
                }

            Text("Services")
                .tabItem {
                    Label("Services", systemImage: "cross.case.fill")
                }

            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(Color(hex: "16A34A"))
    }
}

// MARK: - Dashboard (Home Tab)
struct DashboardView: View {
    @Binding var isLoggedIn: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Greeting
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Good morning 👋")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            Text("Welcome to ClinicFlow")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                        }
                        Spacer()
                        Button {
                            isLoggedIn = false
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "16A34A"))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // Quick Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.horizontal, 20)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            QuickActionCard(icon: "stethoscope", title: "Book Appointment", color: "16A34A")
                            QuickActionCard(icon: "cross.case.fill", title: "OPD", color: "0EA5E9")
                            QuickActionCard(icon: "flask.fill", title: "Laboratory", color: "8B5CF6")
                            QuickActionCard(icon: "pills.fill", title: "Pharmacy", color: "F59E0B")
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
            }
            .navigationTitle("ClinicFlow")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: String

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: color).opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(Color(hex: color))
            }
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

#Preview {
    HomeView(isLoggedIn: .constant(true), showProfileSwitcher: .constant(false))
}
