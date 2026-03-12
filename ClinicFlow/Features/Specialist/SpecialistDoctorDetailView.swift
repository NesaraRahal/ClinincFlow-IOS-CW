import SwiftUI

// MARK: - Specialist Doctor Detail View
struct SpecialistDoctorDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var hapticsManager: HapticsManager
    let doctor: SpecialistDoctor
    var onAppointmentBooked: ((AppointmentData) -> Void)? = nil
    
    @State private var showDateTimePicker = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // MARK: - Hero Section
                        ZStack(alignment: .bottom) {
                            // Profile Image
                            Image(doctor.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 300)
                                .clipped()
                            
                            // Gradient overlay
                            LinearGradient(
                                colors: [Color.clear, Color.clear, Color.black.opacity(0.5)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            
                            // Doctor Info Overlay
                            VStack(spacing: 8) {
                                // Availability Badge
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(doctor.isAvailable ? Color.green : Color.orange)
                                        .frame(width: 8, height: 8)
                                    
                                    Text(doctor.isAvailable ? "Available Today" : "Next: \(doctor.nextAvailable)")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Capsule())
                                
                                Text(doctor.name)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("\(doctor.specialty) · \(doctor.qualification)")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding(.bottom, 24)
                        }
                        .frame(height: 300)
                        
                        // MARK: - Stats Row
                        HStack(spacing: 0) {
                            DoctorStatItem(value: String(format: "%.1f", doctor.rating), label: "Rating", icon: "star.fill", iconColor: .orange)
                            
                            Rectangle()
                                .fill(Color(.systemGray4))
                                .frame(width: 1, height: 40)
                            
                            DoctorStatItem(value: "\(doctor.experience) yrs", label: "Experience", icon: "briefcase.fill", iconColor: Color(hex: "16A34A"))
                            
                            Rectangle()
                                .fill(Color(.systemGray4))
                                .frame(width: 1, height: 40)
                            
                            DoctorStatItem(value: "\(doctor.reviewCount)", label: "Reviews", icon: "text.bubble.fill", iconColor: .blue)
                        }
                        .padding(.vertical, 20)
                        .background(Color(.systemBackground))
                        
                        // MARK: - Content Cards
                        VStack(spacing: 14) {
                            // Specialty Card
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(spacing: 10) {
                                    Image(systemName: "heart.text.square.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(hex: "16A34A"))
                                    
                                    Text("Specialization")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                                
                                Text(doctor.specialty)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text("Qualified: \(doctor.qualification)")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(18)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
                            
                            // Consultation Fee
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color.green.opacity(0.12))
                                        .frame(width: 48, height: 48)
                                    
                                    Image(systemName: "creditcard.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.green)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Consultation Fee")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondary)
                                    
                                    Text(doctor.consultationFee)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.primary)
                                }
                                
                                Spacer()
                            }
                            .padding(18)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
                            
                            // About Doctor
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(spacing: 10) {
                                    Image(systemName: "person.text.rectangle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(hex: "16A34A"))
                                    
                                    Text("About")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                                
                                Text("\(doctor.name) is a highly experienced \(doctor.specialty.lowercased()) with over \(doctor.experience) years of clinical practice. Known for patient-centric care and thorough consultations.")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.secondary)
                                    .lineSpacing(5)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(18)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
                            
                            Spacer().frame(height: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 14)
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: {
                    hapticsManager.playNavigationSound()
                    showDateTimePicker = true
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text("Book Appointment")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(hex: "16A34A"))
                    .clipShape(Capsule())
                    .shadow(color: Color(hex: "16A34A").opacity(0.35), radius: 10, x: 0, y: 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 20)
                .background(
                    Color(.systemBackground)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: -4)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
            .fullScreenCover(isPresented: $showDateTimePicker) {
                AppointmentDateTimeView(
                    doctor: doctor,
                    onAppointmentBooked: onAppointmentBooked
                )
            }
        }
    }
}

// MARK: - Doctor Stat Item
struct DoctorStatItem: View {
    let value: String
    let label: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(iconColor)
                
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SpecialistDoctorDetailView(doctor: sampleDoctors[0])
        .environmentObject(HapticsManager())
}
