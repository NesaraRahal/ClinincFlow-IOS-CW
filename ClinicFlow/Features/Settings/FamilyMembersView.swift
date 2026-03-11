//
//  FamilyMembersView.swift
//  ClinicFlow
//
//  Created by COBSCCOMP242P-052 on 2026-02-27.
//

import SwiftUI

// MARK: - Family Members View
struct FamilyMembersView: View {
    @EnvironmentObject var familyManager: FamilyMembersManager
    @EnvironmentObject var hapticsManager: HapticsManager
    @State private var showAddMember = false
    @State private var memberToDelete: FamilyMember? = nil
    @State private var showDeleteAlert = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {

                // Info Banner
                infoBanner

                if familyManager.members.isEmpty {
                    emptyState
                } else {
                    // Members Count
                    HStack {
                        Text("Members")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)

                        Spacer()

                        Text("\(familyManager.memberCount)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 26, height: 26)
                            .background(Color(hex: "16A34A"))
                            .clipShape(Circle())
                    }
                    .padding(.horizontal, 4)

                    // Member Cards
                    ForEach(familyManager.members) { member in
                        NavigationLink {
                            FamilyMemberDetailView(memberID: member.id)
                        } label: {
                            FamilyMemberCard(member: member)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                memberToDelete = member
                                showDeleteAlert = true
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                }

                // Add Button
                addMemberButton
            }
            .padding(20)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Family Members")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    hapticsManager.playTapSound()
                    showAddMember = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "16A34A"))
                }
            }
        }
        .sheet(isPresented: $showAddMember) {
            FamilyMemberFormView(mode: .add)
        }
        .alert("Remove Member?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                if let m = memberToDelete {
                    hapticsManager.playErrorSound()
                    withAnimation(.spring(response: 0.3)) {
                        familyManager.deleteMember(m)
                    }
                }
            }
        } message: {
            if let m = memberToDelete {
                Text("Are you sure you want to remove \(m.fullName) from your family members?")
            }
        }
        .onAppear {
            let count = familyManager.memberCount
            if count == 0 {
                hapticsManager.speak("Family members. No members added yet. Tap Add to add a family member.")
            } else {
                hapticsManager.speak("Family members. \(count) member\(count == 1 ? "" : "s") added.")
            }
        }
    }

    // MARK: - Info Banner
    private var infoBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: "16A34A").opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: "person.3.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "16A34A"))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Family Healthcare")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                Text("Add family members to manage their appointments and medical records.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 30)

            ZStack {
                Circle()
                    .fill(Color(hex: "16A34A").opacity(0.08))
                    .frame(width: 100, height: 100)
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "16A34A").opacity(0.5))
            }

            VStack(spacing: 8) {
                Text("No Family Members")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)

                Text("Add your family members to easily\nbook appointments for them")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer().frame(height: 20)
        }
    }

    // MARK: - Add Member Button
    private var addMemberButton: some View {
        Button {
            hapticsManager.playTapSound()
            showAddMember = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                Text("Add Family Member")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color(hex: "16A34A"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

// Preview
// Note: FamilyMemberCard, FamilyMemberDetailView, and FamilyMemberFormView
// are in their own files for better organization.

#Preview {
    NavigationStack {
        FamilyMembersView()
            .environmentObject(FamilyMembersManager())
            .environmentObject(HapticsManager())
    }
}
