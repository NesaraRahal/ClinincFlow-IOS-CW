import SwiftUI
import PhotosUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var profileManager: UserProfileManager
    @EnvironmentObject var hapticsManager: HapticsManager
    
    @State private var isEditing = false
    
    // Temp editing fields
    @State private var editName = ""
    @State private var editEmail = ""
    @State private var editPhone = ""
    @State private var editDOB = ""
    @State private var editGender = ""
    @State private var editBloodType = ""
    @State private var editAddress = ""
    @State private var editEmergencyContact = ""
    @State private var editAllergies: [String] = []
    @State private var editChronicConditions: [String] = []
    @State private var newAllergyText = ""
    @State private var newConditionText = ""
    
    // Image picker
    @State private var showImageSourceSheet = false
    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    
    let genders = ["Male", "Female", "Other"]
    let bloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - First Time Setup Banner
                    if !profileManager.hasCompletedSetup && !isEditing {
                        VStack(spacing: 12) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(Color(hex: "16A34A"))
                            
                            Text("Complete Your Profile")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Please fill in your details to get the best experience from ClinicFlow.")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: startEditing) {
                                Text("Set Up Profile")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "16A34A"))
                                    .clipShape(Capsule())
                            }
                            .padding(.top, 4)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    
                    // MARK: - Profile Header
                    VStack(spacing: 16) {
                        // Avatar with photo
                        ZStack {
                            if let img = profileManager.profileImage {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Text(profileManager.profile.initials)
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            // Camera button
                            Button(action: { showImageSourceSheet = true }) {
                                Circle()
                                    .fill(Color(.systemBackground))
                                    .frame(width: 32, height: 32)
                                    .overlay {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(hex: "16A34A"))
                                    }
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                            .offset(x: 35, y: 35)
                        }
                        
                        VStack(spacing: 4) {
                            Text(profileManager.profile.fullName)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text(profileManager.profile.patientID)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, !profileManager.hasCompletedSetup && !isEditing ? 0 : 20)
                    
                    // MARK: - Quick Stats
                    HStack(spacing: 12) {
                        ProfileStatCard(value: "12", label: "Total Visits", icon: "calendar")
                        ProfileStatCard(value: profileManager.profile.bloodType, label: "Blood Group", icon: "drop.fill")
                        ProfileStatCard(value: "3", label: "Reports", icon: "doc.text.fill")
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - Content (Edit or Display)
                    if isEditing {
                        editingSection
                    } else {
                        displaySection
                    }
                    
                    // MARK: - Actions
                    actionButtons
                    
                    Spacer(minLength: 40)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.secondary, Color(.systemGray5))
                    }
                }
            }
            .confirmationDialog("Profile Photo", isPresented: $showImageSourceSheet, titleVisibility: .visible) {
                Button("Take Photo") {
                    showCamera = true
                }
                Button("Choose from Library") {
                    showPhotoPicker = true
                }
                if profileManager.profileImage != nil {
                    Button("Remove Photo", role: .destructive) {
                        profileManager.removeProfileImage()
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
                            profileManager.saveProfileImage(uiImage)
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPickerView { image in
                    profileManager.saveProfileImage(image)
                }
                .ignoresSafeArea()
            }
        }
    }
    
    // MARK: - Editing Section
    private var editingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Information")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 16) {
                EditableField(icon: "person.fill", label: "Full Name", text: $editName)
                EditableField(icon: "envelope.fill", label: "Email", text: $editEmail, keyboard: .emailAddress)
                EditableField(icon: "phone.fill", label: "Phone", text: $editPhone, keyboard: .phonePad)
                EditableField(icon: "birthday.cake.fill", label: "Date of Birth", text: $editDOB)
                EditableField(icon: "mappin.circle.fill", label: "Address", text: $editAddress)
                EditableField(icon: "phone.badge.waveform.fill", label: "Emergency Contact", text: $editEmergencyContact)
                
                // Gender Picker
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "16A34A"))
                        Text("Gender")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 10) {
                        ForEach(genders, id: \.self) { g in
                            Button(action: { editGender = g }) {
                                Text(g)
                                    .font(.system(size: 14, weight: editGender == g ? .semibold : .medium))
                                    .foregroundColor(editGender == g ? .white : .primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(editGender == g ? Color(hex: "16A34A") : Color(.systemGray6))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                
                // Blood Type Picker
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "16A34A"))
                        Text("Blood Type")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()), GridItem(.flexible()),
                        GridItem(.flexible()), GridItem(.flexible())
                    ], spacing: 10) {
                        ForEach(bloodTypes, id: \.self) { bt in
                            Button(action: { editBloodType = bt }) {
                                Text(bt)
                                    .font(.system(size: 14, weight: editBloodType == bt ? .semibold : .medium))
                                    .foregroundColor(editBloodType == bt ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(editBloodType == bt ? Color(hex: "16A34A") : Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }
                
                // Allergies Editor
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "pills.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "16A34A"))
                        Text("Allergies")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    ChipEditorView(items: $editAllergies, newItemText: $newAllergyText, placeholder: "Add allergy (e.g. Penicillin)")
                }
                
                // Chronic Conditions Editor
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.text.clipboard.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "16A34A"))
                        Text("Chronic Conditions")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    ChipEditorView(items: $editChronicConditions, newItemText: $newConditionText, placeholder: "Add condition (e.g. Diabetes)")
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Display Section
    private var displaySection: some View {
        VStack(spacing: 24) {
            // Personal Information
            VStack(alignment: .leading, spacing: 16) {
                Text("Personal Information")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 4)
                
                VStack(spacing: 0) {
                    ProfileInfoRow(icon: "envelope.fill", label: "Email", value: profileManager.profile.email)
                    Divider().padding(.leading, 52)
                    ProfileInfoRow(icon: "phone.fill", label: "Phone", value: profileManager.profile.phone)
                    Divider().padding(.leading, 52)
                    ProfileInfoRow(icon: "birthday.cake.fill", label: "Date of Birth", value: profileManager.profile.dateOfBirth)
                    Divider().padding(.leading, 52)
                    ProfileInfoRow(icon: "person.2.fill", label: "Gender", value: profileManager.profile.gender)
                    Divider().padding(.leading, 52)
                    ProfileInfoRow(icon: "mappin.circle.fill", label: "Address", value: profileManager.profile.address)
                    Divider().padding(.leading, 52)
                    ProfileInfoRow(icon: "phone.badge.waveform.fill", label: "Emergency Contact", value: profileManager.profile.emergencyContact)
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 20)
            
            // Medical Information
            VStack(alignment: .leading, spacing: 16) {
                Text("Medical Information")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 4)
                
                VStack(spacing: 0) {
                    ProfileInfoRow(icon: "drop.fill", label: "Blood Group", value: profileManager.profile.bloodType)
                    Divider().padding(.leading, 52)
                    ProfileInfoRow(icon: "pills.fill", label: "Allergies", value: profileManager.profile.allergiesDisplay)
                    Divider().padding(.leading, 52)
                    ProfileInfoRow(icon: "heart.text.clipboard.fill", label: "Chronic Conditions", value: profileManager.profile.chronicConditionsDisplay)
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if isEditing {
                Button(action: saveProfile) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Save Changes")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "16A34A"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
                Button(action: cancelEditing) {
                    HStack {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            } else {
                Button(action: startEditing) {
                    HStack {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Edit Profile")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "16A34A"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("View Medical Records")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "16A34A"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "16A34A").opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Actions
    private func startEditing() {
        hapticsManager.playTapSound()
        let p = profileManager.profile
        editName = p.fullName
        editEmail = p.email
        editPhone = p.phone
        editDOB = p.dateOfBirth
        editGender = p.gender
        editBloodType = p.bloodType
        editAddress = p.address
        editEmergencyContact = p.emergencyContact
        editAllergies = p.allergies
        editChronicConditions = p.chronicConditions
        newAllergyText = ""
        newConditionText = ""
        withAnimation(.easeInOut(duration: 0.25)) {
            isEditing = true
        }
    }
    
    private func saveProfile() {
        hapticsManager.playSuccessSound()
        profileManager.profile.fullName = editName
        profileManager.profile.email = editEmail
        profileManager.profile.phone = editPhone
        profileManager.profile.dateOfBirth = editDOB
        profileManager.profile.gender = editGender
        profileManager.profile.bloodType = editBloodType
        profileManager.profile.address = editAddress
        profileManager.profile.emergencyContact = editEmergencyContact
        profileManager.profile.allergies = editAllergies
        profileManager.profile.chronicConditions = editChronicConditions
        profileManager.completeSetup()
        withAnimation(.easeInOut(duration: 0.25)) {
            isEditing = false
        }
    }
    
    private func cancelEditing() {
        hapticsManager.playTapSound()
        withAnimation(.easeInOut(duration: 0.25)) {
            isEditing = false
        }
    }
}

// MARK: - Editable Field
struct EditableField: View {
    let icon: String
    let label: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "16A34A"))
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            TextField(label, text: $text)
                .font(.system(size: 15))
                .keyboardType(keyboard)
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: - Profile Stat Card
struct ProfileStatCard: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(hex: "16A34A"))
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Profile Info Row
struct ProfileInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "16A34A").opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "16A34A"))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Chip Editor (for allergies / conditions)
struct ChipEditorView: View {
    @Binding var items: [String]
    @Binding var newItemText: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Existing chips
            if !items.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        HStack(spacing: 6) {
                            Text(item)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "16A34A"))
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    items.removeAll { $0 == item }
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "16A34A").opacity(0.6))
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color(hex: "16A34A").opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
            }
            
            // Add new
            HStack(spacing: 8) {
                TextField(placeholder, text: $newItemText)
                    .font(.system(size: 14))
                    .padding(10)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button(action: addItem) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(newItemText.trimmingCharacters(in: .whitespaces).isEmpty ? Color(.systemGray4) : Color(hex: "16A34A"))
                }
                .disabled(newItemText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
    
    private func addItem() {
        let trimmed = newItemText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !items.contains(trimmed) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            items.append(trimmed)
        }
        newItemText = ""
    }
}

// MARK: - Flow Layout (wrapping chips)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }
    
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
        }
        
        return (positions, CGSize(width: maxX, height: y + rowHeight))
    }
}

// MARK: - Camera Picker (UIImagePickerController wrapper)
struct CameraPickerView: UIViewControllerRepresentable {
    let onImagePicked: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView
        
        init(_ parent: CameraPickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let edited = info[.editedImage] as? UIImage {
                parent.onImagePicked(edited)
            } else if let original = info[.originalImage] as? UIImage {
                parent.onImagePicked(original)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserProfileManager())
        .environmentObject(HapticsManager())
}
