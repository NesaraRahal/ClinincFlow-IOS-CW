//
//  FamilyMemberCard.swift
//  ClinicFlow
//
//  Created by COBSCCOMP242P-052 on 2026-02-27.
//

import SwiftUI

// MARK: - Family Member Card
struct FamilyMemberCard: View {
    let member: FamilyMember
    @EnvironmentObject var familyManager: FamilyMembersManager

    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            ZStack {
                if let img = familyManager.loadProfileImage(for: member.id) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 54, height: 54)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(member.iconColor.opacity(0.15))
                        .frame(width: 54, height: 54)

                    Text(member.initials)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(member.iconColor)
                }
            }
            .frame(width: 54, height: 54)

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(member.fullName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Image(systemName: member.relationshipIcon)
                        .font(.system(size: 10))
                    Text(member.relationship)
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    if member.age > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "calendar")
                                .font(.system(size: 9))
                            Text("\(member.age) yrs")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.secondary.opacity(0.8))
                    }

                    if !member.bloodType.isEmpty {
                        HStack(spacing: 3) {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 9))
                            Text(member.bloodType)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.red.opacity(0.7))
                    }

                    if !member.allergies.isEmpty {
                        HStack(spacing: 3) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 9))
                            Text("\(member.allergies.count) allerg\(member.allergies.count == 1 ? "y" : "ies")")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.orange.opacity(0.8))
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(.systemGray3))
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}
