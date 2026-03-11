import SwiftUI
import Combine

// MARK: - User Profile Model
struct UserProfile: Codable {
    var fullName: String = "John Doe"
    var patientID: String = "P-2024-0892"
    var email: String = "john.doe@example.com"
    var phone: String = "+94 77 123 4567"
    var dateOfBirth: String = "1995-06-15"
    var gender: String = "Male"
    var bloodType: String = "O+"
    var address: String = "123 Hospital Street, Colombo"
    var emergencyContact: String = "Jane Doe (+94 71 987 6543)"
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
