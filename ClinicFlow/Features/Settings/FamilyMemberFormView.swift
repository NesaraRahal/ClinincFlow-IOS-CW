//
//  FamilyMemberFormView.swift
//  ClinicFlow
//
//  Created by COBSCCOMP242P-052 on 2026-02-27.
//

import SwiftUI
import PhotosUI

// MARK: - Add/Edit Form
struct FamilyMemberFormView: View {
    enum Mode {
        case add
        case edit(FamilyMember)
    }

    let mode: Mode
    @EnvironmentObject var familyManager: FamilyMembersManager
    @EnvironmentObject var hapticsManager: HapticsManager
    @Environment(\.dismiss) private var dismiss

    // MARK: - Form Fields
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var relationship = "Spouse"
    @State private var dateOfBirth = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    @State private var gender = "Male"
    @State private var phone = ""
    @State private var email = ""
    @State private var bloodType = ""
    @State private var allergies: [String] = []
    @State private var chronicConditions: [String] = []
    @State private var currentMedications: [String] = []
    @State private var emergencyContactName = ""
    @State private var emergencyContactPhone = ""
    @State private var insuranceProvider = ""
    @State private var insurancePolicyNumber = ""
    @State private var notes = ""

    @State private var newAllergyText = ""
    @State private var newConditionText = ""
    @State private var newMedicationText = ""

    // Photo picker states
    @State private var profileImage: UIImage? = nil
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var showImageSourceSheet = false
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var didChangePhoto = false

    @State private var expandedSection: FormSection? = .personal

    // MARK: - Constants
    enum FormSection: String, CaseIterable {
        case personal = "Personal Info"
        case contact = "Contact"
        case medical = "Medical Info"
        case emergency = "Emergency Contact"
        case insurance = "Insurance"
        case notes = "Notes"
    }

    let relationships = ["Spouse", "Partner", "Son", "Daughter", "Father", "Mother", "Brother", "Sister", "Child", "Sibling", "Other"]
    let genders = ["Male", "Female", "Other"]
    let bloodTypes = ["", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]

    // MARK: - Computed
    var isAdd: Bool {
        if case .add = mode { return true }
        return false
    }

    var title: String { isAdd ? "Add Member" : "Edit Member" }

    var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    profilePhotoSection

                    // Personal
                    formSection(.personal) {
                        VStack(spacing: 14) {
                            FloatingField(label: "First Name", text: $firstName)
                            FloatingField(label: "Last Name", text: $lastName)
                            relationshipPicker
                            DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                                .font(.system(size: 14, weight: .medium))
                            ageDisplay
                            genderPicker
                        }
                    }

                    // Contact
                    formSection(.contact) {
                        VStack(spacing: 14) {
                            FloatingField(label: "Phone Number", text: $phone, keyboardType: .phonePad)
                            FloatingField(label: "Email", text: $email, keyboardType: .emailAddress)
                        }
                    }

                    // Medical
                    formSection(.medical) {
                        VStack(spacing: 14) {
                            bloodTypePicker
                            chipEditor(title: "Allergies", items: $allergies, newText: $newAllergyText, placeholder: "Add allergy (e.g. Penicillin)", color: .orange)
                            chipEditor(title: "Chronic Conditions", items: $chronicConditions, newText: $newConditionText, placeholder: "Add condition (e.g. Diabetes)", color: .red)
                            chipEditor(title: "Current Medications", items: $currentMedications, newText: $newMedicationText, placeholder: "Add medication (e.g. Metformin)", color: .blue)
                        }
                    }

                    // Emergency
                    formSection(.emergency) {
                        VStack(spacing: 14) {
                            FloatingField(label: "Contact Name", text: $emergencyContactName)
                            FloatingField(label: "Contact Phone", text: $emergencyContactPhone, keyboardType: .phonePad)
                        }
                    }

                    // Insurance
                    formSection(.insurance) {
                        VStack(spacing: 14) {
                            FloatingField(label: "Insurance Provider", text: $insuranceProvider)
                            FloatingField(label: "Policy Number", text: $insurancePolicyNumber)
                        }
                    }

                    // Notes
                    formSection(.notes) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Additional Notes")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            TextEditor(text: $notes)
                                .font(.system(size: 14))
                                .frame(minHeight: 80)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isAdd ? "Add" : "Save") { saveMember() }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "16A34A"))
                        .disabled(!isFormValid)
                }
            }
            .onAppear {
                if case .edit(let m) = mode {
                    loadFields(from: m)
                    profileImage = familyManager.loadProfileImage(for: m.id)
                }
            }
            .confirmationDialog("Profile Photo", isPresented: $showImageSourceSheet, titleVisibility: .visible) {
                Button("Take Photo") { showCamera = true }
                Button("Choose from Library") { showPhotoPicker = true }
                if profileImage != nil {
                    Button("Remove Photo", role: .destructive) {
                        withAnimation { profileImage = nil }
                        didChangePhoto = true
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            profileImage = uiImage
                            didChangePhoto = true
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPickerView { image in
                    profileImage = image
                    didChangePhoto = true
                }
                .ignoresSafeArea()
            }
        }
    }

    // MARK: - Profile Photo Section
    private var profilePhotoSection: some View {
        VStack(spacing: 12) {
            ZStack {
                if let img = profileImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 96, height: 96)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 96, height: 96)
                        .overlay {
                            Image(systemName: "person.fill")
                                .font(.system(size: 38))
                                .foregroundColor(Color(.systemGray3))
                        }
                }

                Button { showImageSourceSheet = true } label: {
                    Circle()
                        .fill(Color(hex: "16A34A"))
                        .frame(width: 30, height: 30)
                        .overlay {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                        }
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                }
                .offset(x: 34, y: 34)
            }

            Text("Tap to add photo")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Inline Pickers
    private var relationshipPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Relationship")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(relationships, id: \.self) { rel in
                        Button { relationship = rel } label: {
                            Text(rel)
                                .font(.system(size: 13, weight: relationship == rel ? .semibold : .medium))
                                .foregroundColor(relationship == rel ? .white : .primary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(relationship == rel ? Color(hex: "16A34A") : Color(.systemGray6))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }

    private var ageDisplay: some View {
        HStack {
            Text("Age")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            Spacer()
            Text("\(age) years")
                .font(.system(size: 14, weight: .semibold))
        }
    }

    private var genderPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Gender")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            HStack(spacing: 10) {
                ForEach(genders, id: \.self) { g in
                    Button { gender = g } label: {
                        Text(g)
                            .font(.system(size: 13, weight: gender == g ? .semibold : .medium))
                            .foregroundColor(gender == g ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(gender == g ? Color(hex: "16A34A") : Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }

    private var bloodTypePicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Blood Type")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(bloodTypes, id: \.self) { bt in
                        if !bt.isEmpty {
                            Button { bloodType = bloodType == bt ? "" : bt } label: {
                                Text(bt)
                                    .font(.system(size: 13, weight: bloodType == bt ? .semibold : .medium))
                                    .foregroundColor(bloodType == bt ? .white : .primary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(bloodType == bt ? Color.red : Color(.systemGray6))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Expandable Section
    private func formSection<Content: View>(_ section: FormSection, @ViewBuilder content: @escaping () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    expandedSection = expandedSection == section ? nil : section
                }
            } label: {
                HStack {
                    Text(section.rawValue)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(expandedSection == section ? 90 : 0))
                }
                .padding(16)
            }

            if expandedSection == section {
                content()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    // MARK: - Chip Editor
    private func chipEditor(title: String, items: Binding<[String]>, newText: Binding<String>, placeholder: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                TextField(placeholder, text: newText)
                    .font(.system(size: 14))
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Button {
                    let text = newText.wrappedValue.trimmingCharacters(in: .whitespaces)
                    if !text.isEmpty && !items.wrappedValue.contains(text) {
                        items.wrappedValue.append(text)
                        newText.wrappedValue = ""
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "16A34A"))
                }
                .disabled(newText.wrappedValue.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            if !items.wrappedValue.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(items.wrappedValue, id: \.self) { item in
                        HStack(spacing: 4) {
                            Text(item)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(color)

                            Button {
                                items.wrappedValue.removeAll { $0 == item }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(color.opacity(0.6))
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(color.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }

    // MARK: - Save
    private func saveMember() {
        var member: FamilyMember
        if case .edit(let existing) = mode {
            member = existing
        } else {
            member = FamilyMember.empty()
        }

        member.firstName = firstName.trimmingCharacters(in: .whitespaces)
        member.lastName = lastName.trimmingCharacters(in: .whitespaces)
        member.relationship = relationship
        member.dateOfBirth = dateOfBirth
        member.gender = gender
        member.phone = phone.trimmingCharacters(in: .whitespaces)
        member.email = email.trimmingCharacters(in: .whitespaces)
        member.bloodType = bloodType
        member.allergies = allergies
        member.chronicConditions = chronicConditions
        member.currentMedications = currentMedications
        member.emergencyContactName = emergencyContactName.trimmingCharacters(in: .whitespaces)
        member.emergencyContactPhone = emergencyContactPhone.trimmingCharacters(in: .whitespaces)
        member.insuranceProvider = insuranceProvider.trimmingCharacters(in: .whitespaces)
        member.insurancePolicyNumber = insurancePolicyNumber.trimmingCharacters(in: .whitespaces)
        member.notes = notes.trimmingCharacters(in: .whitespaces)

        if isAdd {
            hapticsManager.playConfirmSound()
            familyManager.addMember(member)
        } else {
            hapticsManager.playConfirmSound()
            familyManager.updateMember(member)
        }

        // Save or remove profile image
        if didChangePhoto {
            if let img = profileImage {
                familyManager.saveProfileImage(img, for: member.id)
            } else {
                familyManager.removeProfileImage(for: member.id)
            }
        }

        dismiss()
    }

    // MARK: - Load
    private func loadFields(from m: FamilyMember) {
        firstName = m.firstName
        lastName = m.lastName
        relationship = m.relationship
        dateOfBirth = m.dateOfBirth
        gender = m.gender
        phone = m.phone
        email = m.email
        bloodType = m.bloodType
        allergies = m.allergies
        chronicConditions = m.chronicConditions
        currentMedications = m.currentMedications
        emergencyContactName = m.emergencyContactName
        emergencyContactPhone = m.emergencyContactPhone
        insuranceProvider = m.insuranceProvider
        insurancePolicyNumber = m.insurancePolicyNumber
        notes = m.notes
    }
}

// MARK: - Floating Text Field
struct FloatingField: View {
    let label: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            TextField(label, text: $text)
                .font(.system(size: 15))
                .keyboardType(keyboardType)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
