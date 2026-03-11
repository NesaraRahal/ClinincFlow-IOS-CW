import SwiftUI

// MARK: - Appointment Date & Time View
struct AppointmentDateTimeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var hapticsManager: HapticsManager
    let doctor: SpecialistDoctor
    var onAppointmentBooked: ((AppointmentData) -> Void)? = nil
    
    @State private var selectedDate = Date()
    @State private var selectedTimeSlot: String? = nil
    @State private var showSummary = false
    
    let timeSlots = [
        "08:00 AM - 10:00 AM",
        "10:00 AM - 12:00 PM",
        "12:00 PM - 02:00 PM",
        "02:00 PM - 04:00 PM",
        "04:00 PM - 06:00 PM",
        "06:00 PM - 08:00 PM"
    ]
    
    // Simulate some booked slots
    let bookedSlots = ["10:00 AM - 12:00 PM", "06:00 PM - 08:00 PM"]
    
    var morningSlots: [String] {
        timeSlots.filter { $0.contains("08:00 AM") || $0.contains("10:00 AM") }
    }
    
    var afternoonSlots: [String] {
        timeSlots.filter { !morningSlots.contains($0) }
    }
    
    var canProceed: Bool {
        selectedTimeSlot != nil
    }
    
    // Calculate next available token based on date and time
    var nextAvailableToken: String {
        guard selectedTimeSlot != nil else { return "--" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: selectedDate)
        
        // Simulate token calculation based on date + time
        // In real app, this would come from backend
        let baseToken = dateString.hash % 40 + 10
        let timeIndex = timeSlots.firstIndex(of: selectedTimeSlot ?? "") ?? 0
        let tokenNumber = baseToken + timeIndex
        
        return "S\(tokenNumber)"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // MARK: - Doctor Summary Card
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "16A34A").opacity(0.15), Color(hex: "22C55E").opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex: "16A34A"))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(doctor.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text(doctor.specialty)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(doctor.consultationFee)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "16A34A"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "16A34A").opacity(0.1))
                            .clipShape(Capsule())
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                    
                    // MARK: - Available Token Card
                    if selectedTimeSlot != nil {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "16A34A").opacity(0.12))
                                    .frame(width: 48, height: 48)
                                
                                Image(systemName: "ticket.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(hex: "16A34A"))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your Token Number")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text(nextAvailableToken)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "16A34A"))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("RESERVED")
                                    .font(.system(size: 10, weight: .bold))
                                    .tracking(0.5)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color(hex: "16A34A"))
                                    .clipShape(Capsule())
                                
                                Text("for this slot")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "16A34A").opacity(0.06))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [Color(hex: "16A34A").opacity(0.3), Color(hex: "22C55E").opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                        )
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: nextAvailableToken)
                    }
                    
                    // MARK: - Date Picker
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 10) {
                            Image(systemName: "calendar")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "16A34A"))
                            
                            Text("Select Date")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        DatePicker(
                            "Appointment Date",
                            selection: $selectedDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .tint(Color(hex: "16A34A"))
                    }
                    .padding(18)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                    
                    // MARK: - Time Slots
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(spacing: 10) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "16A34A"))
                            
                            Text("Select Time")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        // Morning Slots
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Image(systemName: "sun.max.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(.orange)
                                
                                Text("Morning")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 10) {
                                ForEach(morningSlots, id: \.self) { slot in
                                    TimeSlotButton(
                                        time: slot,
                                        isSelected: selectedTimeSlot == slot,
                                        isBooked: bookedSlots.contains(slot)
                                    ) {
                                        selectedTimeSlot = slot
                                    }
                                }
                            }
                        }
                        
                        // Afternoon Slots
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Image(systemName: "moon.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(.indigo)
                                
                                Text("Afternoon & Evening")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 10) {
                                ForEach(afternoonSlots, id: \.self) { slot in
                                    TimeSlotButton(
                                        time: slot,
                                        isSelected: selectedTimeSlot == slot,
                                        isBooked: bookedSlots.contains(slot)
                                    ) {
                                        selectedTimeSlot = slot
                                    }
                                }
                            }
                        }
                    }
                    .padding(18)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                    
                    Spacer().frame(height: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Select Date & Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: {
                    hapticsManager.playNavigationSound()
                    showSummary = true
                }) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(canProceed ? Color(hex: "16A34A") : Color(.systemGray4))
                        .clipShape(Capsule())
                        .shadow(color: canProceed ? Color(hex: "16A34A").opacity(0.35) : Color.clear, radius: 10, x: 0, y: 4)
                }
                .disabled(!canProceed)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 20)
                .background(
                    Color(.systemBackground)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: -4)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
            .fullScreenCover(isPresented: $showSummary) {
                AppointmentSummaryView(
                    doctor: doctor,
                    selectedDate: selectedDate,
                    selectedTime: selectedTimeSlot ?? "",
                    onAppointmentBooked: onAppointmentBooked
                )
            }
        }
    }
}

// MARK: - Time Slot Button
struct TimeSlotButton: View {
    let time: String
    let isSelected: Bool
    let isBooked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if !isBooked {
                action()
            }
        }) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "clock")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(
                        isBooked ? Color(.systemGray3) :
                        isSelected ? .white : Color(hex: "16A34A")
                    )
                
                Text(time)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(
                        isBooked ? Color(.systemGray3) :
                        isSelected ? .white : .primary
                    )
                
                Spacer()
                
                if isBooked {
                    Text("BOOKED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(.systemGray3))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                } else if isSelected {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                isBooked ? Color(.systemGray6) :
                isSelected ? Color(hex: "16A34A") : Color(.systemBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isBooked ? Color(.systemGray5) :
                        isSelected ? Color(hex: "16A34A") : Color(.systemGray5),
                        lineWidth: isSelected ? 0 : 1
                    )
            }
            .shadow(
                color: isSelected ? Color(hex: "16A34A").opacity(0.25) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .disabled(isBooked)
    }
}

#Preview {
    AppointmentDateTimeView(doctor: sampleDoctors[0])
        .environmentObject(HapticsManager())
}
