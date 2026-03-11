//
//  HomeView.swift
//  ClinicFlow
//
//  Created by COBSCCOMP242P-052 on 2026-02-23.
//

import SwiftUI

struct ServiceOption: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
}

struct HomeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var hapticsManager: HapticsManager
    @EnvironmentObject var profileManager: UserProfileManager
    @EnvironmentObject var activeProfileManager: ActiveProfileManager
    @EnvironmentObject var familyManager: FamilyMembersManager
    var onAppointmentBooked: ((AppointmentData) -> Void)? = nil
    
    /// The patient name derived from the active profile
    private var activePatientName: String {
        activeProfileManager.activeProfile.patientName(
            profileManager: profileManager,
            familyManager: familyManager
        )
    }
    
    let services = [
        ServiceOption(title: "Pharmacy", icon: "cross.case.fill", color: Color(hex: "16A34A")),
        ServiceOption(title: "OPD", icon: "stethoscope", color: Color(hex: "16A34A")),
        ServiceOption(title: "Laboratory", icon: "flask.fill", color: Color(hex: "16A34A")),
        ServiceOption(title: "Specialist Clinic", icon: "heart.text.square.fill", color: Color(hex: "16A34A")),
        ServiceOption(title: "Radiology", icon: "waveform.path.ecg", color: Color(hex: "16A34A")),
        ServiceOption(title: "Vaccination", icon: "syringe.fill", color: Color(hex: "16A34A"))
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome to")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.secondary)
                    
                    Text("ClinicFlow")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Select a service to book")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 20)
                
                // Active Profile Indicator
                if activePatientName != "Self" {
                    HStack(spacing: 10) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.orange)
                        
                        Text("Booking for \(activePatientName)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Text("FAMILY")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.orange)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.orange.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
                }
                
                // Services Grid
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(services) { service in
                        ServiceCard(
                            service: service,
                            patientName: activePatientName,
                            onAppointmentBooked: onAppointmentBooked
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Book Appointment")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
        }
        .onAppear {
            hapticsManager.speak("Book an appointment. Choose from services: Pharmacy, OPD, Laboratory, Specialist Clinic, Radiology, or Vaccination.")
        }
    }
}

struct ServiceCard: View {
    @EnvironmentObject var hapticsManager: HapticsManager
    let service: ServiceOption
    var patientName: String = "Self"
    var onAppointmentBooked: ((AppointmentData) -> Void)? = nil
    
    @State private var isPressed = false
    @State private var showDoctorDetail = false
    @State private var showServiceBooking = false
    
    /// Wraps the callback to inject the patientName
    private var wrappedCallback: ((AppointmentData) -> Void)? {
        guard let original = onAppointmentBooked else { return nil }
        let name = patientName
        return { data in
            var modified = data
            modified.patientName = name
            original(modified)
        }
    }
    
    // Determines if service goes to DoctorDetailView or ServiceBookingFlow
    var isSpecialistService: Bool {
        service.title == "Specialist Clinic"
    }
    
    var body: some View {
        Button(action: {
            hapticsManager.playNavigationSound()
            if isSpecialistService {
                // Specialist Clinic -> DoctorDetailView
                showDoctorDetail = true
            } else {
                // OPD, Lab, Pharmacy, Radiology, Vaccination -> Service Booking Flow
                showServiceBooking = true
            }
        }) {
            VStack(spacing: 16) {
                // Icon Circle
                ZStack {
                    Circle()
                        .fill(service.color.opacity(0.1))
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: service.icon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(service.color)
                }
                
                // Title
                Text(service.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6).opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .fullScreenCover(isPresented: $showDoctorDetail) {
            DoctorListView(onAppointmentBooked: wrappedCallback)
        }
        .fullScreenCover(isPresented: $showServiceBooking) {
            // For non-specialist services, use the service booking flow
            ServiceBookingFlow(
                serviceTitle: service.title,
                serviceIcon: service.icon,
                patientName: patientName,
                onAppointmentBooked: wrappedCallback
            )
        }
    }
}

// MARK: - Service Booking Confirmation View
// Temporary confirmation screen before going to PatientHomeView
struct ServiceBookingConfirmationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var hapticsManager: HapticsManager
    let serviceName: String
    var patientName: String = "Self"
    var onConfirm: ((AppointmentData) -> Void)? = nil
    
    @State private var isBooking = false
    @State private var bookingComplete = false
    @State private var generatedAppointment: AppointmentData? = nil
    
    // Pre-generate on init so we can show doctor info before confirming
    init(serviceName: String, patientName: String = "Self", onConfirm: ((AppointmentData) -> Void)? = nil) {
        self.serviceName = serviceName
        self.patientName = patientName
        self.onConfirm = onConfirm
        self._generatedAppointment = State(initialValue: AppointmentData.randomForService(serviceName))
    }
    
    var serviceIcon: String {
        switch serviceName {
        case "Pharmacy": return "cross.case.fill"
        case "OPD": return "stethoscope"
        case "Laboratory": return "flask.fill"
        case "Radiology": return "waveform.path.ecg"
        case "Vaccination": return "syringe.fill"
        default: return "cross.case.fill"
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()
                
                if bookingComplete {
                    // Success State
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Booking Confirmed!")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Your token has been generated")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                        
                        // Token Preview
                        VStack(spacing: 12) {
                            Text("YOUR TOKEN")
                                .font(.system(size: 11, weight: .semibold))
                                .tracking(2)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text(generatedAppointment?.tokenNumber ?? "--")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(serviceName)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 40)
                        
                        // Doctor / Staff Summary
                        if let apt = generatedAppointment {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "16A34A").opacity(0.12))
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(hex: "16A34A"))
                                }
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(apt.doctorName)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text("Room \(apt.roomNumber) • \(apt.floor)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding(14)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(.horizontal, 24)
                        }
                    }
                } else {
                    // Booking State
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "16A34A").opacity(0.1))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: serviceIcon)
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(hex: "16A34A"))
                            }
                            
                            VStack(spacing: 8) {
                                Text(serviceName)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text("Confirm your appointment")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.secondary)
                                
                                if patientName != "Self" {
                                    HStack(spacing: 6) {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 11))
                                        Text("For: \(patientName)")
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                    .foregroundColor(Color(hex: "16A34A"))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(Color(hex: "16A34A").opacity(0.1))
                                    .clipShape(Capsule())
                                }
                            }
                            
                            // MARK: - Assigned Staff Card
                            if let apt = generatedAppointment {
                                VStack(spacing: 14) {
                                    HStack(spacing: 8) {
                                        Image(systemName: serviceName == "OPD" ? "stethoscope" : "person.badge.shield.checkmark.fill")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Color(hex: "16A34A"))
                                        
                                        Text(serviceName == "OPD" ? "Assigned Doctor" : "Assigned Staff")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                    }
                                    
                                    HStack(spacing: 14) {
                                        // Profile Picture
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
                                        
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(apt.doctorName)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.primary)
                                            
                                            Text(apt.doctorRole)
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(.secondary)
                                            
                                            HStack(spacing: 4) {
                                                Image(systemName: "star.fill")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(.orange)
                                                
                                                Text(apt.doctorRating)
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                .padding(16)
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                                .padding(.horizontal, 24)
                            }
                            
                            // MARK: - Appointment Details Card
                            if let apt = generatedAppointment {
                                VStack(spacing: 12) {
                                    BookingInfoRow(icon: "calendar", label: "Date", value: apt.appointmentDate)
                                    
                                    Divider()
                                    
                                    BookingInfoRow(icon: "clock", label: "Est. Wait", value: apt.estimatedWait)
                                    
                                    Divider()
                                    
                                    BookingInfoRow(icon: "door.left.hand.open", label: "Room", value: apt.roomNumber)
                                    
                                    Divider()
                                    
                                    BookingInfoRow(icon: "building.2", label: "Floor", value: apt.floor)
                                    
                                    if apt.consultationFee != "N/A" {
                                        Divider()
                                        
                                        BookingInfoRow(icon: "creditcard", label: "Fee", value: apt.consultationFee)
                                    }
                                }
                                .padding(20)
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                                .padding(.horizontal, 24)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 120)
                    }
                }
                
                Spacer()
                
                // Bottom Button
                VStack(spacing: 12) {
                    if bookingComplete {
                        Button(action: {
                            hapticsManager.playSuccessSound()
                            if let apt = generatedAppointment {
                                onConfirm?(apt)
                            }
                            dismiss()
                        }) {
                            Text("View Queue Status")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "16A34A"))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    } else {
                        Button(action: {
                            hapticsManager.playConfirmSound()
                            isBooking = true
                            // Simulate booking process
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                isBooking = false
                                hapticsManager.playSuccessSound()
                                withAnimation(.spring()) {
                                    bookingComplete = true
                                }
                            }
                        }) {
                            HStack(spacing: 8) {
                                if isBooking {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18))
                                }
                                
                                Text(isBooking ? "Booking..." : "Confirm Booking")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "16A34A"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(isBooking)
                        
                        Button(action: {
                            hapticsManager.playTapSound()
                            dismiss()
                        }) {
                            Text("Cancel")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(bookingComplete)
            .toolbar {
                if !bookingComplete {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Booking Info Row
struct BookingInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "16A34A"))
                    .frame(width: 24)
                
                Text(label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Patient Chip (for booking-for picker)
struct PatientChip: View {
    let name: String
    let label: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? color : color.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isSelected ? .white : color)
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(name.components(separatedBy: " ").first ?? name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .primary)
                        .lineLimit(1)
                    
                    Text(label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 1)
            }
            .shadow(color: isSelected ? color.opacity(0.3) : Color.clear, radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
        .environmentObject(HapticsManager())
        .environmentObject(FamilyMembersManager())
        .environmentObject(UserProfileManager())
        .environmentObject(ActiveProfileManager())
}
