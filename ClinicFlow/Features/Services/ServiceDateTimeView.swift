//
//  ServiceDateTimeView.swift
//  ClinicFlow
//

import SwiftUI

struct ServiceDateTimeView: View {
    @EnvironmentObject var hapticsManager: HapticsManager
    
    let serviceTitle: String
    let serviceIcon: String
    @Binding var selectedDate: Date
    @Binding var selectedTimeSlot: String?
    let onContinue: () -> Void
    
    let timeSlots = [
        "08:00 AM - 10:00 AM",
        "10:00 AM - 12:00 PM",
        "12:00 PM - 02:00 PM",
        "02:00 PM - 04:00 PM",
        "04:00 PM - 06:00 PM",
        "06:00 PM - 08:00 PM"
    ]
    
    // Simulate some booked slots
    let bookedSlots = ["10:00 AM - 12:00 PM", "04:00 PM - 06:00 PM"]
    
    var morningSlots: [String] {
        timeSlots.filter { $0.contains("08:00 AM") || $0.contains("10:00 AM") }
    }
    
    var afternoonSlots: [String] {
        timeSlots.filter { !morningSlots.contains($0) }
    }
    
    var canProceed: Bool {
        selectedTimeSlot != nil
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Service Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: serviceIcon)
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Text(serviceTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Select your preferred date and time")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Date Picker
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
                .padding(20)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                
                // Time Slots
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 10) {
                        Image(systemName: "clock")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "16A34A"))
                        
                        Text("Select Time")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    // Morning Slots
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Morning")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 10) {
                            ForEach(morningSlots, id: \.self) { slot in
                                TimeSlotButton(
                                    time: slot,
                                    isSelected: selectedTimeSlot == slot,
                                    isBooked: bookedSlots.contains(slot)
                                ) {
                                    if !bookedSlots.contains(slot) {
                                        hapticsManager.playTapSound()
                                        selectedTimeSlot = slot
                                    }
                                }
                            }
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    // Afternoon Slots
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Afternoon & Evening")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 10) {
                            ForEach(afternoonSlots, id: \.self) { slot in
                                TimeSlotButton(
                                    time: slot,
                                    isSelected: selectedTimeSlot == slot,
                                    isBooked: bookedSlots.contains(slot)
                                ) {
                                    if !bookedSlots.contains(slot) {
                                        hapticsManager.playTapSound()
                                        selectedTimeSlot = slot
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
        .safeAreaInset(edge: .bottom) {
            // Continue Button
            Button(action: {
                hapticsManager.playConfirmSound()
                onContinue()
            }) {
                HStack(spacing: 10) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .semibold))
                }
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
    }
}
