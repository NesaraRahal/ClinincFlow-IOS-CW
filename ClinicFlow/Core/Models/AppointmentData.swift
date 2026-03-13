import SwiftUI

// MARK: - Appointment Data Model
// Shared model that carries all booking info from booking flow → PatientHomeView
struct AppointmentData {
    let tokenNumber: String
    let department: String
    let doctorName: String
    let doctorRole: String
    let doctorRating: String
    let roomNumber: String
    let floor: String
    let appointmentDate: String
    let appointmentTime: String
    let consultationFee: String
    
    // Patient info (who the booking is for)
    var patientName: String = "Self"
    
    // Queue simulation data
    let patientsAhead: Int
    let estimatedWait: String
    let currentToken: String
    
    // Generate random appointment data for non-specialist services (OPD, Lab, etc.)
    static func randomForService(_ serviceName: String) -> AppointmentData {
        let prefix: String
        let room: String
        let floor: String
        let doctor: (name: String, role: String, rating: String)
        let fee: String
        
        switch serviceName {
        case "OPD":
            prefix = "O"
            room = "\(Int.random(in: 101...110))"
            floor = "1st Floor"
            doctor = (
                name: ["Dr. John Carter", "Dr. Peter Adams", "Dr. David Clark"].randomElement()!,
                role: "General Physician",
                rating: String(format: "%.1f", Double.random(in: 4.3...4.9))
            )
            fee = "LKR 1,500"
            
        case "Laboratory":
            prefix = "L"
            room = "\(Int.random(in: 201...208))"
            floor = "2nd Floor"
            doctor = (
                name: ["Mr. John Harris", "Ms. Emily Scott", "Mr. Ryan Lewis"].randomElement()!,
                role: "Lab Technician",
                rating: String(format: "%.1f", Double.random(in: 4.2...4.8))
            )
            fee = "LKR 800"
            
        case "Pharmacy":
            prefix = "P"
            room = "\(Int.random(in: 001...005))"
            floor = "Ground Floor"
            doctor = (
                name: ["Mr. Peter Allen", "Ms. Grace Hall", "Mr. Daniel Young"].randomElement()!,
                role: "Pharmacist",
                rating: String(format: "%.1f", Double.random(in: 4.4...4.9))
            )
            fee = "N/A"
            
        case "Radiology":
            prefix = "R"
            room = "\(Int.random(in: 301...306))"
            floor = "3rd Floor"
            doctor = (
                name: ["Dr. Olivia Brooks", "Dr. Michael Turner", "Dr. Emma Walker"].randomElement()!,
                role: "Radiologist",
                rating: String(format: "%.1f", Double.random(in: 4.5...4.9))
            )
            fee = "LKR 2,500"
            
        case "Vaccination":
            prefix = "V"
            room = "\(Int.random(in: 101...104))"
            floor = "1st Floor"
            doctor = (
                name: ["Dr. Sophia King", "Dr. James Wright"].randomElement()!,
                role: "Immunization Nurse",
                rating: String(format: "%.1f", Double.random(in: 4.5...4.9))
            )
            fee = "LKR 1,200"
            
        default:
            prefix = "G"
            room = "\(Int.random(in: 100...400))"
            floor = "Ground Floor"
            doctor = (name: "Staff Member", role: "Healthcare Professional", rating: "4.5")
            fee = "LKR 1,000"
        }
        
        let tokenNum = Int.random(in: 10...50)
        let currentNum = max(1, tokenNum - Int.random(in: 3...10))
        let ahead = tokenNum - currentNum
        
        return AppointmentData(
            tokenNumber: "\(prefix)\(tokenNum)",
            department: serviceName,
            doctorName: doctor.name,
            doctorRole: doctor.role,
            doctorRating: doctor.rating,
            roomNumber: room,
            floor: floor,
            appointmentDate: "Today, Feb 25",
            appointmentTime: "Walk-in",
            consultationFee: fee,
            patientsAhead: ahead,
            estimatedWait: "\(ahead * 3) Mins",
            currentToken: "\(prefix)\(currentNum)"
        )
    }
    
    // Generate appointment data from specialist clinic booking flow
    static func fromSpecialistBooking(
        doctor: SpecialistDoctor,
        date: String,
        time: String,
        tokenNumber: String
    ) -> AppointmentData {
        let roomNum = "\(Int.random(in: 301...320))"
        let tokenNum = Int(tokenNumber.dropFirst()) ?? 30
        let currentNum = max(1, tokenNum - Int.random(in: 2...7))
        let ahead = tokenNum - currentNum
        let prefix = String(tokenNumber.prefix(1))
        
        return AppointmentData(
            tokenNumber: tokenNumber,
            department: "Specialist Clinic",
            doctorName: doctor.name,
            doctorRole: doctor.specialty,
            doctorRating: String(format: "%.1f", doctor.rating),
            roomNumber: roomNum,
            floor: "3rd Floor",
            appointmentDate: date,
            appointmentTime: time,
            consultationFee: doctor.consultationFee,
            patientsAhead: ahead,
            estimatedWait: "\(ahead * 5) Mins",
            currentToken: "\(prefix)\(currentNum)"
        )
    }
}
