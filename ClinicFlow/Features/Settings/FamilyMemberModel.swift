//
//  FamilyMemberModel.swift
//  ClinicFlow
//
//  Created by COBSCCOMP242P-052 on 2026-02-27.
//

import SwiftUI
import Combine

// MARK: - Family Member Model
struct FamilyMember: Identifiable, Codable, Equatable {
    var id = UUID()
    var firstName: String
    var lastName: String
    var relationship: String
    var dateOfBirth: Date
    var gender: String

    // Contact
    var phone: String
    var email: String

    // Medical
    var bloodType: String
    var allergies: [String]
    var chronicConditions: [String]
    var currentMedications: [String]

    // Emergency
    var emergencyContactName: String
    var emergencyContactPhone: String

    // Insurance
    var insuranceProvider: String
    var insurancePolicyNumber: String

    // Meta
    var notes: String
    var addedDate: Date

    // MARK: Computed
    var fullName: String { "\(firstName) \(lastName)" }

    var initials: String {
        let f = firstName.prefix(1).uppercased()
        let l = lastName.prefix(1).uppercased()
        return f + l
    }

    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }

    var allergiesDisplay: String {
        allergies.isEmpty ? "None reported" : allergies.joined(separator: ", ")
    }

    var conditionsDisplay: String {
        chronicConditions.isEmpty ? "None" : chronicConditions.joined(separator: ", ")
    }

    var medicationsDisplay: String {
        currentMedications.isEmpty ? "None" : currentMedications.joined(separator: ", ")
    }

    var iconColor: Color {
        switch relationship.lowercased() {
        case "spouse", "partner": return .pink
        case "son", "daughter", "child": return .blue
        case "father", "mother", "parent": return .orange
        case "sibling", "brother", "sister": return .purple
        default: return .teal
        }
    }

    var relationshipIcon: String {
        switch relationship.lowercased() {
        case "spouse", "partner": return "heart.fill"
        case "son", "daughter", "child": return "figure.child"
        case "father", "mother", "parent": return "figure.stand"
        case "sibling", "brother", "sister": return "person.2.fill"
        default: return "person.fill"
        }
    }

    // MARK: Factory
    static func empty() -> FamilyMember {
        FamilyMember(
            firstName: "",
            lastName: "",
            relationship: "Spouse",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date(),
            gender: "Male",
            phone: "",
            email: "",
            bloodType: "",
            allergies: [],
            chronicConditions: [],
            currentMedications: [],
            emergencyContactName: "",
            emergencyContactPhone: "",
            insuranceProvider: "",
            insurancePolicyNumber: "",
            notes: "",
            addedDate: Date()
        )
    }
}

// MARK: - Family Members Manager
class FamilyMembersManager: ObservableObject {
    @Published var members: [FamilyMember] = [] {
        didSet { save() }
    }

    private let key = "familyMembers_v2"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([FamilyMember].self, from: data) {
            self.members = decoded
        }
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(members) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    func addMember(_ member: FamilyMember) {
        members.append(member)
    }

    func updateMember(_ member: FamilyMember) {
        if let idx = members.firstIndex(where: { $0.id == member.id }) {
            members[idx] = member
        }
    }

    func deleteMember(_ member: FamilyMember) {
        removeProfileImage(for: member.id)
        members.removeAll { $0.id == member.id }
    }

    func deleteMember(at offsets: IndexSet) {
        for idx in offsets {
            removeProfileImage(for: members[idx].id)
        }
        members.remove(atOffsets: offsets)
    }

    func member(byID id: UUID) -> FamilyMember? {
        members.first { $0.id == id }
    }

    var memberCount: Int { members.count }

    // MARK: - Profile Image (file-based, keyed by member UUID)

    private func imageURL(for memberID: UUID) -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("family_photo_\(memberID.uuidString).jpg")
    }

    func saveProfileImage(_ image: UIImage, for memberID: UUID) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: imageURL(for: memberID))
        }
        objectWillChange.send()
    }

    func loadProfileImage(for memberID: UUID) -> UIImage? {
        guard let data = try? Data(contentsOf: imageURL(for: memberID)),
              let image = UIImage(data: data) else { return nil }
        return image
    }

    func removeProfileImage(for memberID: UUID) {
        try? FileManager.default.removeItem(at: imageURL(for: memberID))
        objectWillChange.send()
    }

    func hasProfileImage(for memberID: UUID) -> Bool {
        FileManager.default.fileExists(atPath: imageURL(for: memberID).path)
    }
}
