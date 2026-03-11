//
//  FamilyMembersManager.swift
//  ClinicFlow
//

import SwiftUI
import Combine

// MARK: - Family Member Model
struct FamilyMember: Identifiable, Codable {
    let id: UUID
    var fullName: String
    var relationship: String
    var age: Int
    var gender: String
    var bloodType: String
    
    init(id: UUID = UUID(), fullName: String, relationship: String, age: Int, gender: String = "", bloodType: String = "") {
        self.id = id
        self.fullName = fullName
        self.relationship = relationship
        self.age = age
        self.gender = gender
        self.bloodType = bloodType
    }
    
    var initials: String {
        let parts = fullName.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1)) + String(parts[1].prefix(1))
        }
        return String(fullName.prefix(2)).uppercased()
    }
    
    // Each member gets a consistent color based on their name
    var iconColor: Color {
        let colors: [Color] = [.blue, .purple, .orange, .pink, .teal, .indigo, .mint, .cyan]
        let hash = fullName.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return colors[hash % colors.count]
    }
}

// MARK: - Family Members Manager
class FamilyMembersManager: ObservableObject {
    @Published var members: [FamilyMember] = []
    
    private let storageKey = "familyMembers"
    
    init() {
        loadMembers()
    }
    
    // MARK: - CRUD
    
    func addMember(_ member: FamilyMember) {
        members.append(member)
        saveMembers()
    }
    
    func removeMember(at offsets: IndexSet) {
        members.remove(atOffsets: offsets)
        saveMembers()
    }
    
    func removeMember(byID id: UUID) {
        members.removeAll { $0.id == id }
        saveMembers()
    }
    
    func updateMember(_ member: FamilyMember) {
        if let index = members.firstIndex(where: { $0.id == member.id }) {
            members[index] = member
            saveMembers()
        }
    }
    
    func member(byID id: UUID) -> FamilyMember? {
        members.first(where: { $0.id == id })
    }
    
    // MARK: - Profile Image
    
    func loadProfileImage(for memberID: UUID) -> UIImage? {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent("family_\(memberID.uuidString).jpg")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
    
    func saveProfileImage(_ image: UIImage, for memberID: UUID) {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent("family_\(memberID.uuidString).jpg")
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: url)
        }
    }
    
    // MARK: - Persistence
    
    private func saveMembers() {
        if let data = try? JSONEncoder().encode(members) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func loadMembers() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([FamilyMember].self, from: data) {
            members = decoded
        }
    }
}
