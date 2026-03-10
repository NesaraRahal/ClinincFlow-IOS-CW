import SwiftUI

// MARK: - Specialist Doctor Model
struct SpecialistDoctor: Identifiable {
    let id = UUID()
    let name: String
    let specialty: String
    let qualification: String
    let rating: Double
    let reviewCount: Int
    let experience: Int // years
    let consultationFee: String
    let imageName: String
    let isAvailable: Bool
    let nextAvailable: String
}

// Sample data
let sampleDoctors: [SpecialistDoctor] = [
    SpecialistDoctor(name: "Dr. Sarah Ahmed", specialty: "Cardiologist", qualification: "MBBS, MD, FACC", rating: 4.8, reviewCount: 234, experience: 12, consultationFee: "Rs. 3,500", imageName: "doctor_sarah", isAvailable: true, nextAvailable: "Today"),
    SpecialistDoctor(name: "Dr. Rajiv Perera", specialty: "Neurologist", qualification: "MBBS, MD", rating: 4.9, reviewCount: 189, experience: 15, consultationFee: "Rs. 4,000", imageName: "doctor_rajiv", isAvailable: true, nextAvailable: "Today"),
    SpecialistDoctor(name: "Dr. Nisha Fernando", specialty: "Dermatologist", qualification: "MBBS, MD, DDV", rating: 4.7, reviewCount: 312, experience: 8, consultationFee: "Rs. 2,500", imageName: "doctor_nisha", isAvailable: false, nextAvailable: "Tomorrow"),
    SpecialistDoctor(name: "Dr. Amal Jayasinghe", specialty: "Orthopedic Surgeon", qualification: "MBBS, MS Ortho", rating: 4.6, reviewCount: 156, experience: 20, consultationFee: "Rs. 3,000", imageName: "doctor_amal", isAvailable: true, nextAvailable: "Today"),
    SpecialistDoctor(name: "Dr. Priya Kumar", specialty: "ENT Specialist", qualification: "MBBS, MS ENT", rating: 4.5, reviewCount: 98, experience: 10, consultationFee: "Rs. 2,800", imageName: "doctor_priya", isAvailable: true, nextAvailable: "Today"),
    SpecialistDoctor(name: "Dr. Kamal Dias", specialty: "Cardiologist", qualification: "MBBS, MD, DM", rating: 4.8, reviewCount: 278, experience: 18, consultationFee: "Rs. 4,500", imageName: "doctor_kamal", isAvailable: false, nextAvailable: "Feb 27"),
    SpecialistDoctor(name: "Dr. Meena Sharma", specialty: "Gynecologist", qualification: "MBBS, MS OBG", rating: 4.9, reviewCount: 421, experience: 14, consultationFee: "Rs. 3,000", imageName: "doctor_meena", isAvailable: true, nextAvailable: "Today"),
    SpecialistDoctor(name: "Dr. Dinesh Silva", specialty: "Neurologist", qualification: "MBBS, DM Neuro", rating: 4.4, reviewCount: 87, experience: 6, consultationFee: "Rs. 2,500", imageName: "doctor_dinesh", isAvailable: true, nextAvailable: "Today")
]

let specialties = ["All", "Cardiologist", "Neurologist", "Dermatologist", "Orthopedic Surgeon", "ENT Specialist", "Gynecologist"]

// MARK: - Doctor List View
struct DoctorListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var hapticsManager: HapticsManager
    @State private var searchText = ""
    @State private var selectedSpecialty = "All"
    @State private var selectedDoctor: SpecialistDoctor? = nil
    
    var onAppointmentBooked: ((AppointmentData) -> Void)? = nil
    
    var filteredDoctors: [SpecialistDoctor] {
        var result = sampleDoctors
        
        // Filter by specialty
        if selectedSpecialty != "All" {
            result = result.filter { $0.specialty == selectedSpecialty }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.specialty.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    TextField("Search doctors or specialties", text: $searchText)
                        .font(.system(size: 16))
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // MARK: - Specialty Filter Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(specialties, id: \.self) { specialty in
                            SpecialtyChip(
                                title: specialty,
                                isSelected: selectedSpecialty == specialty,
                                action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedSpecialty = specialty
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                }
                
                // Results count
                HStack {
                    Text("\(filteredDoctors.count) doctors found")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                
                // MARK: - Doctor List
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 14) {
                        ForEach(filteredDoctors) { doctor in
                            DoctorCard(doctor: doctor)
                                .onTapGesture {
                                    selectedDoctor = doctor
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Specialist Clinic")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                }
            }
            .fullScreenCover(item: $selectedDoctor) { doctor in
                SpecialistDoctorDetailView(
                    doctor: doctor,
                    onAppointmentBooked: onAppointmentBooked
                )
            }
        }
    }
}

// MARK: - Specialty Chip
struct SpecialtyChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color(hex: "16A34A") : Color(.systemGray6))
                .clipShape(Capsule())
        }
    }
}

// MARK: - Doctor Card
struct DoctorCard: View {
    let doctor: SpecialistDoctor
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile Image
            Image(doctor.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(hex: "16A34A").opacity(0.2), lineWidth: 2)
                )
            
            // Doctor Info
            VStack(alignment: .leading, spacing: 6) {
                Text(doctor.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(doctor.specialty)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "16A34A"))
                
                HStack(spacing: 12) {
                    // Rating
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.orange)
                        
                        Text(String(format: "%.1f", doctor.rating))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("(\(doctor.reviewCount))")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    // Experience
                    HStack(spacing: 3) {
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        
                        Text("\(doctor.experience) yrs")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Availability & Fee
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(doctor.isAvailable ? Color.green : Color.orange)
                            .frame(width: 6, height: 6)
                        
                        Text(doctor.isAvailable ? "Available" : doctor.nextAvailable)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(doctor.isAvailable ? .green : .orange)
                    }
                    
                    Text("•")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    Text(doctor.consultationFee)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primary)
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

#Preview {
    DoctorListView()
        .environmentObject(HapticsManager())
}
