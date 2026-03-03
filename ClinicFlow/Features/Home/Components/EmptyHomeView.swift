//
//  EmptyHomeView.swift
//  ClinicFlow
//
//  Created by COBSCCOMP24.2P-053 on 2026-03-03.
//

import SwiftUI

// MARK: - Empty Home View
struct EmptyHomeView: View {

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Custom Header
            HStack {
                // Logo
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 36, height: 36)

                        Image(systemName: "cross.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Text("ClinicFlow")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                }

                Spacer()

                // Notification Icon
                ZStack {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 42, height: 42)

                    Image(systemName: "bell.fill")
                        .font(.system(size: 17))
                        .foregroundColor(.primary)
                }

                // Profile Icon
                ZStack {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 42, height: 42)

                    Image(systemName: "person.fill")
                        .font(.system(size: 17))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 16)

            Spacer()

            // MARK: - Empty State Content
            VStack(spacing: 32) {
                // Illustration
                ZStack {
                    Circle()
                        .fill(Color(hex: "16A34A").opacity(0.08))
                        .frame(width: 160, height: 160)

                    Circle()
                        .fill(Color(hex: "16A34A").opacity(0.12))
                        .frame(width: 120, height: 120)

                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 72, height: 72)

                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.white)
                    }
                }

                // Text Content
                VStack(spacing: 12) {
                    Text("No Appointments Yet")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)

                    Text("Book your first appointment and\nwe'll take care of the rest")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                // Book Appointment Button
                Button(action: {}) {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20, weight: .semibold))

                        Text("Book Appointment")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color(hex: "16A34A").opacity(0.3), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)
            }
            .padding(.bottom, 60)

            Spacer()
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    EmptyHomeView()
}
