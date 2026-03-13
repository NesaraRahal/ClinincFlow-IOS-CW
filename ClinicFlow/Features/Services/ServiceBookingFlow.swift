//
//  ServiceBookingFlow.swift
//  ClinicFlow
//

import SwiftUI
import PhotosUI

struct ServiceBookingFlow: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var hapticsManager: HapticsManager
    @EnvironmentObject var notificationManager: NotificationManager
    
    let serviceTitle: String
    let serviceIcon: String
    var patientName: String = "Self"
    var onAppointmentBooked: ((AppointmentData) -> Void)? = nil
    
    @State private var currentStep: BookingStep = .dateTime
    @State private var selectedDate = Date()
    @State private var selectedTimeSlot: String? = nil
    @State private var prescriptionImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var notes: String = ""
    
    enum BookingStep {
        case dateTime
        case prescription  // Only for Lab, Radiology, Pharmacy
        case summary
    }
    
    var requiresPrescription: Bool {
        ["Laboratory", "Radiology", "Pharmacy"].contains(serviceTitle)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                // Keep all views in hierarchy for stable photosPicker
                ServiceDateTimeView(
                    serviceTitle: serviceTitle,
                    serviceIcon: serviceIcon,
                    selectedDate: $selectedDate,
                    selectedTimeSlot: $selectedTimeSlot,
                    onContinue: {
                        if requiresPrescription {
                            currentStep = .prescription
                        } else {
                            currentStep = .summary
                        }
                    }
                )
                .opacity(currentStep == .dateTime ? 1 : 0)
                .zIndex(currentStep == .dateTime ? 1 : 0)
                
                PrescriptionUploadView(
                    serviceTitle: serviceTitle,
                    prescriptionImage: $prescriptionImage,
                    notes: $notes,
                    showingImagePicker: $showingImagePicker,
                    onContinue: {
                        currentStep = .summary
                    },
                    onBack: {
                        currentStep = .dateTime
                    }
                )
                .opacity(currentStep == .prescription ? 1 : 0)
                .zIndex(currentStep == .prescription ? 1 : 0)
                
                ServiceBookingSummaryView(
                    serviceTitle: serviceTitle,
                    serviceIcon: serviceIcon,
                    patientName: patientName,
                    selectedDate: selectedDate,
                    selectedTimeSlot: selectedTimeSlot ?? "",
                    prescriptionImage: prescriptionImage,
                    notes: notes,
                    onConfirm: {
                        bookAppointment()
                    },
                    onBack: {
                        if requiresPrescription {
                            currentStep = .prescription
                        } else {
                            currentStep = .dateTime
                        }
                    },
                    onEdit: { field in
                        handleEdit(field: field)
                    }
                )
                .opacity(currentStep == .summary ? 1 : 0)
                .zIndex(currentStep == .summary ? 1 : 0)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "16A34A"))
                            .frame(width: 36, height: 36)
                            .background(Color(hex: "16A34A").opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingImagePicker) {
            PhotoPickerView { image in
                prescriptionImage = image
            }
            .ignoresSafeArea()
        }
    }
    
    private func handleEdit(field: String) {
        switch field {
        case "date", "time":
            currentStep = .dateTime
        case "prescription":
            currentStep = .prescription
        default:
            break
        }
    }
    
    private func bookAppointment() {
        hapticsManager.playConfirmSound()
        
        let appointment = AppointmentData(
            tokenNumber: String(format: "%03d", Int.random(in: 1...150)),
            department: serviceTitle,
            doctorName: getAssignedStaff(),
            doctorRole: getStaffRole(),
            doctorRating: "4.5",
            roomNumber: getAssignedRoom(),
            floor: "2nd Floor",
            appointmentDate: formattedDate(),
            appointmentTime: selectedTimeSlot ?? "",
            consultationFee: "$50",
            patientName: patientName,
            patientsAhead: Int.random(in: 0...20),
            estimatedWait: "\(Int.random(in: 15...60)) mins",
            currentToken: String(format: "%03d", Int.random(in: 1...150))
        )
        
        // Send notification
        notificationManager.notifyAppointmentBooked(
            service: serviceTitle,
            doctorName: appointment.doctorName,
            time: appointment.appointmentTime,
            date: appointment.appointmentDate,
            tokenNumber: appointment.tokenNumber
        )
        
        onAppointmentBooked?(appointment)
        dismiss()
    }
    
    private func getAssignedStaff() -> String {
        switch serviceTitle {
        case "Laboratory": return "Lab Technician Emily"
        case "Pharmacy": return "Pharmacist John"
        case "Radiology": return "Radiologist Dr. Smith"
        case "Vaccination": return "Nurse Emily"
        case "OPD": return "Dr. Peter Thompson"
        default: return "Medical Staff"
        }
    }
    
    private func getStaffRole() -> String {
        switch serviceTitle {
        case "Laboratory": return "Senior Lab Technician"
        case "Pharmacy": return "Chief Pharmacist"
        case "Radiology": return "Radiologist"
        case "Vaccination": return "Vaccination Nurse"
        case "OPD": return "General Physician"
        default: return "Medical Professional"
        }
    }
    
    private func getAssignedRoom() -> String {
        switch serviceTitle {
        case "Laboratory": return "201"
        case "Pharmacy": return "G-05"
        case "Radiology": return "B-12"
        case "Vaccination": return "203"
        case "OPD": return "305"
        default: return "101"
        }
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: selectedDate)
    }
}

// MARK: - Photo Picker View
struct PhotoPickerView: UIViewControllerRepresentable {
    let onImagePicked: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: PhotoPickerView
        
        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}


