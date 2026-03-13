import SwiftUI
import Combine

// MARK: - User Profile Model
struct UserProfile: Codable {
    var fullName: String = "John Doe"
    var patientID: String = "P-2026-1001"
    var email: String = ""
    var phone: String = ""
    var dateOfBirth: String = ""
    var gender: String = ""
    var bloodType: String = ""
    var address: String = ""
    var emergencyContact: String = ""
    var allergies: [String] = []
    var chronicConditions: [String] = []
    
    // Get initials for avatar
    var initials: String {
        let parts = fullName.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1)) + String(parts[1].prefix(1))
        }
        return String(fullName.prefix(2)).uppercased()
    }
    
    var allergiesDisplay: String {
        allergies.isEmpty ? "None reported" : allergies.joined(separator: ", ")
    }
    
    var chronicConditionsDisplay: String {
        chronicConditions.isEmpty ? "None" : chronicConditions.joined(separator: ", ")
    }
}

// MARK: - UserProfile Manager
class UserProfileManager: ObservableObject {
    @Published var profile: UserProfile {
        didSet {
            saveProfile()
        }
    }
    
    @Published var hasCompletedSetup: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedSetup, forKey: "hasCompletedProfileSetup")
        }
    }
    
    /// UIImage for the profile picture — stored locally in documents directory
    @Published var profileImage: UIImage? = nil
    
    init() {
        self.hasCompletedSetup = UserDefaults.standard.bool(forKey: "hasCompletedProfileSetup")
        
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.profile = decoded
        } else {
            self.profile = UserProfile()
        }

        // For incomplete profiles, keep only basic identity and clear old demo data
        if !hasCompletedSetup {
            profile.email = ""
            profile.phone = ""
            profile.dateOfBirth = ""
            profile.gender = ""
            profile.bloodType = ""
            profile.address = ""
            profile.emergencyContact = ""
            profile.allergies = []
            profile.chronicConditions = []
        }
        
        loadProfileImage()
    }
    
    private func saveProfile() {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
        }
    }
    
    func completeSetup() {
        hasCompletedSetup = true
    }
    
    // MARK: - Profile Image (local file storage)
    
    private var imageURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("profile_picture.jpg")
    }
    
    func saveProfileImage(_ image: UIImage) {
        profileImage = image
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: imageURL)
        }
    }
    
    func loadProfileImage() {
        if let data = try? Data(contentsOf: imageURL),
           let image = UIImage(data: data) {
            profileImage = image
        }
    }
    
    func removeProfileImage() {
        profileImage = nil
        try? FileManager.default.removeItem(at: imageURL)
    }
}
