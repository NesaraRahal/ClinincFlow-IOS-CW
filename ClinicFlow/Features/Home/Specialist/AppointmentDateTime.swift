//
//  AppointmentDateTime.swift
//  ClinicFlow
//
//  Created by COBSCCOMP24.2P-053 on 2026-03-03.
//

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
        "09:00 AM", "09:30 AM", "10:00 AM", "10:30 AM",
        "11:00 AM", "11:30 AM",
        "02:00 PM", "02:30 PM", "03:00 PM", "03:30 PM",
        "04:00 PM", "04:30 PM", "05:00 PM"
    ]
    
    // Simulate some booked slots
    let bookedSlots = ["10:00 AM", "02:30 PM", "04:00 PM"]
    
    var morningSlots: [String] {
        timeSlots.filter { $0.contains("AM") }
    }
    
    var afternoonSlots: [String] {
        timeSlots.filter { $0.contains("PM") }
    }
    
    var canProceed: Bool {
        selectedTimeSlot != nil
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
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 10) {
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
                                Image(systemName: "sun.haze.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(.orange)
                                
                                Text("Afternoon")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 10) {
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
            Text(time)
                .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                .foregroundColor(
                    isBooked ? Color(.systemGray3) :
                    isSelected ? .white : .primary
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    isBooked ? Color(.systemGray6) :
                    isSelected ? Color(hex: "16A34A") : Color(.systemGray6)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay {
                    if isBooked {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                            .foregroundColor(Color(.systemGray4))
                    }
                }
        }
        .disabled(isBooked)
    }
}

#Preview {
    AppointmentDateTimeView(doctor: sampleDoctors[0])
        .environmentObject(HapticsManager())
}
