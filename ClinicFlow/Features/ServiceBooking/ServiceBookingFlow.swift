//
//  ServiceBookingFlow.swift
//  ClinicFlow
//

import SwiftUI

// MARK: - Service Booking Flow
// Wraps the booking confirmation flow for non-specialist services
// (OPD, Laboratory, Pharmacy, Radiology, Vaccination)
struct ServiceBookingFlow: View {
    let serviceTitle: String
    let serviceIcon: String
    var patientName: String = "Self"
    var onAppointmentBooked: ((AppointmentData) -> Void)? = nil
    
    var body: some View {
        ServiceBookingConfirmationView(
            serviceName: serviceTitle,
            patientName: patientName,
            onConfirm: onAppointmentBooked
        )
    }
}

#Preview {
    ServiceBookingFlow(
        serviceTitle: "OPD",
        serviceIcon: "stethoscope"
    )
    .environmentObject(HapticsManager())
}
