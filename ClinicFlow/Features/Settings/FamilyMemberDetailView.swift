//
//  FamilyMemberDetailView.swift
//  ClinicFlow
//
//  Created by COBSCCOMP242P-052 on 2026-02-27.
//

import SwiftUI

// MARK: - Family Member Detail View
struct FamilyMemberDetailView: View {
    let memberID: UUID
    @EnvironmentObject var familyManager: FamilyMembersManager
    @EnvironmentObject var hapticsManager: HapticsManager
    @EnvironmentObject var visitsManager: VisitsManager
    @EnvironmentObject var activeProfileManager: ActiveProfileManager
    @Environment(\.dismiss) private var dismiss
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var showBooking = false

    private var member: FamilyMember? {
        familyManager.member(byID: memberID)
    }

    var body: some View {
        Group {
            if let member = member {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        profileHeader(member)
                        quickStats(member)
                        personalInfoSection(member)
                        medicalInfoSection(member)
                        emergencySection(member)

                        if !member.insuranceProvider.isEmpty || !member.insurancePolicyNumber.isEmpty {
                            insuranceSection(member)
                        }

                        if !member.notes.isEmpty {
                            notesSection(member)
                        }

                        actionsSection(member)
                        deleteButton(member)

                        Spacer().frame(height: 40)
                    }
                    .padding(20)
                }
            } else {
                VStack {
                    Text("Member not found")
                        .foregroundColor(.secondary)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Member Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    hapticsManager.playTapSound()
                    showEditSheet = true
                } label: {
                    Text("Edit")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "16A34A"))
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            if let member = member {
                FamilyMemberFormView(mode: .edit(member))
            }
        }
        .sheet(isPresented: $showBooking) {
            if let member = member {
                NavigationStack {
                    HomeView(
                        onAppointmentBooked: { data in
                            showBooking = false
                            hapticsManager.playSuccessSound()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                visitsManager.addVisit(from: data)
                            }
                        }
                    )
                }
                .onAppear {
                    // Switch active profile to this family member before booking
                    activeProfileManager.switchToMember(member)
                }
            }
        }
        .alert("Remove Member?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                if let m = member {
                    hapticsManager.playErrorSound()
                    familyManager.deleteMember(m)
                    dismiss()
                }
            }
        } message: {
            Text("This will permanently remove this family member and all their information.")
        }
    }

    // MARK: - Profile Header
    private func profileHeader(_ m: FamilyMember) -> some View {
        VStack(spacing: 14) {
            ZStack {
                if let img = familyManager.loadProfileImage(for: m.id) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 88, height: 88)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(m.iconColor.opacity(0.3), lineWidth: 3)
                        )
                } else {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [m.iconColor, m.iconColor.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 88, height: 88)

                    Text(m.initials)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            Text(m.fullName)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)

            HStack(spacing: 6) {
                Image(systemName: m.relationshipIcon)
                    .font(.system(size: 13))
                Text(m.relationship)
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundColor(.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(m.iconColor.opacity(0.1))
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: m.iconColor.opacity(0.1), radius: 12, x: 0, y: 4)
    }

    // MARK: - Quick Stats
    private func quickStats(_ m: FamilyMember) -> some View {
        HStack(spacing: 12) {
            quickStatBubble(value: "\(m.age)", label: "Age", icon: "calendar", color: .blue)
            quickStatBubble(value: m.bloodType.isEmpty ? "—" : m.bloodType, label: "Blood", icon: "drop.fill", color: .red)
            quickStatBubble(value: "\(m.allergies.count)", label: "Allergies", icon: "exclamationmark.triangle.fill", color: .orange)
            quickStatBubble(value: m.gender.prefix(1).uppercased(), label: "Gender", icon: "person.fill", color: .purple)
        }
    }

    private func quickStatBubble(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Personal Info Section
    private func personalInfoSection(_ m: FamilyMember) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Personal Information", icon: "person.text.rectangle")

            FamilyInfoRow(icon: "person.fill", label: "Full Name", value: m.fullName)
            FamilyInfoRow(icon: "calendar", label: "Date of Birth", value: formattedDate(m.dateOfBirth))
            FamilyInfoRow(icon: "person.fill.questionmark", label: "Gender", value: m.gender)
            FamilyInfoRow(icon: "heart.fill", label: "Relationship", value: m.relationship)

            if !m.phone.isEmpty {
                FamilyInfoRow(icon: "phone.fill", label: "Phone", value: m.phone)
            }
            if !m.email.isEmpty {
                FamilyInfoRow(icon: "envelope.fill", label: "Email", value: m.email)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 2)
    }

    // MARK: - Medical Info Section
    private func medicalInfoSection(_ m: FamilyMember) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Medical Information", icon: "cross.case.fill")

            FamilyInfoRow(icon: "drop.fill", label: "Blood Type", value: m.bloodType.isEmpty ? "Not set" : m.bloodType)

            // Allergies
            chipDisplaySection(
                icon: "exclamationmark.triangle.fill",
                iconColor: .orange,
                title: "Allergies",
                items: m.allergies,
                emptyText: "None reported",
                chipColor: .orange
            )

            // Chronic Conditions
            chipDisplaySection(
                icon: "heart.text.clipboard.fill",
                iconColor: .red,
                title: "Chronic Conditions",
                items: m.chronicConditions,
                emptyText: "None",
                chipColor: .red
            )

            // Medications
            chipDisplaySection(
                icon: "pills.fill",
                iconColor: .blue,
                title: "Current Medications",
                items: m.currentMedications,
                emptyText: "None",
                chipColor: .blue
            )
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 2)
    }

    /// Reusable chip display for allergies / conditions / medications
    private func chipDisplaySection(icon: String, iconColor: Color, title: String, items: [String], emptyText: String, chipColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(iconColor)
                    .frame(width: 20)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }

            if items.isEmpty {
                Text(emptyText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .padding(.leading, 28)
            } else {
                FlowLayout(spacing: 6) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(chipColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(chipColor.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                .padding(.leading, 28)
            }
        }
    }

    // MARK: - Emergency Section
    private func emergencySection(_ m: FamilyMember) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Emergency Contact", icon: "phone.badge.waveform.fill")

            FamilyInfoRow(icon: "person.fill", label: "Name", value: m.emergencyContactName.isEmpty ? "Not set" : m.emergencyContactName)
            FamilyInfoRow(icon: "phone.fill", label: "Phone", value: m.emergencyContactPhone.isEmpty ? "Not set" : m.emergencyContactPhone)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 2)
    }

    // MARK: - Insurance Section
    private func insuranceSection(_ m: FamilyMember) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Insurance", icon: "shield.checkered")

            if !m.insuranceProvider.isEmpty {
                FamilyInfoRow(icon: "building.2.fill", label: "Provider", value: m.insuranceProvider)
            }
            if !m.insurancePolicyNumber.isEmpty {
                FamilyInfoRow(icon: "number", label: "Policy No.", value: m.insurancePolicyNumber)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 2)
    }

    // MARK: - Notes Section
    private func notesSection(_ m: FamilyMember) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Notes", icon: "note.text")

            Text(m.notes)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.primary)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 2)
    }

    // MARK: - Actions Section
    private func actionsSection(_ m: FamilyMember) -> some View {
        VStack(spacing: 12) {
            Button {
                hapticsManager.playNavigationSound()
                showBooking = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 16))
                    Text("Book Appointment for \(m.firstName)")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: Color(hex: "16A34A").opacity(0.25), radius: 8, x: 0, y: 4)
            }
        }
    }

    // MARK: - Delete Button
    private func deleteButton(_ m: FamilyMember) -> some View {
        Button {
            hapticsManager.playTapSound()
            showDeleteAlert = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                Text("Remove Family Member")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.red.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Helpers
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "16A34A"))
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .long
        return f.string(from: date)
    }
}

// MARK: - Family Info Row
struct FamilyInfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .frame(width: 20)

            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
    }
}
