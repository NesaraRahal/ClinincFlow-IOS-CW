//
//  VisitsManager.swift
//  ClinicFlow
//
//  Created by COBSCCOMP242P-052 on 2026-02-27.
//

import SwiftUI
import Combine

// MARK: - Visit Step (Dynamic)
struct VisitStep: Identifiable, Codable, Equatable {
    let id: UUID
    let label: String
    let icon: String
    let department: String
    let room: String
    let floor: String
    var isCompleted: Bool
    var isCurrent: Bool
    var isAdditional: Bool
    
    init(
        label: String,
        icon: String,
        department: String = "",
        room: String = "",
        floor: String = "",
        isCompleted: Bool = false,
        isCurrent: Bool = false,
        isAdditional: Bool = false
    ) {
        self.id = UUID()
        self.label = label
        self.icon = icon
        self.department = department
        self.room = room
        self.floor = floor
        self.isCompleted = isCompleted
        self.isCurrent = isCurrent
        self.isAdditional = isAdditional
    }
}

// MARK: - Visit Model
struct Visit: Identifiable, Codable, Equatable {
    let id: UUID
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
    let patientsAhead: Int
    let estimatedWait: String
    let currentToken: String
    let patientName: String
    let bookedAt: Date
    var status: VisitStatus
    var steps: [VisitStep]
    
    // MARK: - Visit Status
    enum VisitStatus: String, Codable {
        case active
        case completed
        case cancelled
        
        var label: String {
            switch self {
            case .active: return "Active"
            case .completed: return "Completed"
            case .cancelled: return "Cancelled"
            }
        }
        
        var color: Color {
            switch self {
            case .active: return Color(hex: "16A34A")
            case .completed: return .blue
            case .cancelled: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .active: return "clock.fill"
            case .completed: return "checkmark.circle.fill"
            case .cancelled: return "xmark.circle.fill"
            }
        }
    }
    
    // MARK: - Computed Progress
    var progress: Double {
        guard !steps.isEmpty else { return 0 }
        let completed = steps.filter { $0.isCompleted }.count
        return Double(completed) / Double(steps.count)
    }
    
    var currentStepIndex: Int {
        steps.firstIndex(where: { $0.isCurrent }) ?? 0
    }
    
    var currentStepLabel: String {
        steps.first(where: { $0.isCurrent })?.label ?? (status == .completed ? "Completed" : "Booked")
    }
    
    // MARK: - Department Icon Helper
    var departmentIcon: String {
        switch department {
        case "OPD": return "stethoscope"
        case "Laboratory": return "flask.fill"
        case "Radiology": return "waveform.path.ecg"
        case "Pharmacy": return "cross.case.fill"
        case "Vaccination": return "syringe.fill"
        case "Specialist Clinic": return "heart.text.square.fill"
        default: return "cross.case.fill"
        }
    }
    
    var departmentColor: Color {
        switch department {
        case "OPD": return Color(hex: "16A34A")
        case "Laboratory": return .purple
        case "Radiology": return .orange
        case "Pharmacy": return .blue
        case "Vaccination": return .teal
        case "Specialist Clinic": return .pink
        default: return Color(hex: "16A34A")
        }
    }
    
    // MARK: - Default Steps for a Department
    static func defaultSteps(for department: String, room: String, floor: String) -> [VisitStep] {
        [
            VisitStep(label: "Booked", icon: "calendar.badge.checkmark", department: department, room: room, floor: floor, isCompleted: false, isCurrent: true),
            VisitStep(label: "Checked In", icon: "person.badge.shield.checkmark.fill", department: department, room: room, floor: floor),
            VisitStep(label: "Waiting", icon: "hourglass", department: department, room: room, floor: floor),
            VisitStep(label: "In Consultation", icon: "stethoscope", department: department, room: room, floor: floor),
            VisitStep(label: "Completed", icon: "checkmark.seal.fill", department: department, room: room, floor: floor),
        ]
    }
    
    // MARK: - Additional Step Templates (Doctor referrals)
    static func labTestStep() -> VisitStep {
        VisitStep(label: "Lab Test", icon: "flask.fill", department: "Laboratory", room: "\(Int.random(in: 201...208))", floor: "2nd Floor", isAdditional: true)
    }
    
    static func pharmacyStep() -> VisitStep {
        VisitStep(label: "Collect Medicine", icon: "cross.case.fill", department: "Pharmacy", room: "\(Int.random(in: 1...5))", floor: "Ground Floor", isAdditional: true)
    }
    
    static func radiologyStep() -> VisitStep {
        VisitStep(label: "Radiology Scan", icon: "waveform.path.ecg", department: "Radiology", room: "\(Int.random(in: 301...306))", floor: "3rd Floor", isAdditional: true)
    }
    
    static func bloodTestStep() -> VisitStep {
        VisitStep(label: "Blood Test", icon: "drop.fill", department: "Laboratory", room: "\(Int.random(in: 201...205))", floor: "2nd Floor", isAdditional: true)
    }
    
    static func followUpStep() -> VisitStep {
        VisitStep(label: "Follow-up Consultation", icon: "arrow.triangle.2.circlepath", department: "OPD", room: "", floor: "", isAdditional: true)
    }
    
    // MARK: - Init from AppointmentData
    init(from appointment: AppointmentData) {
        self.id = UUID()
        self.tokenNumber = appointment.tokenNumber
        self.department = appointment.department
        self.doctorName = appointment.doctorName
        self.doctorRole = appointment.doctorRole
        self.doctorRating = appointment.doctorRating
        self.roomNumber = appointment.roomNumber
        self.floor = appointment.floor
        self.appointmentDate = appointment.appointmentDate
        self.appointmentTime = appointment.appointmentTime
        self.consultationFee = appointment.consultationFee
        self.patientsAhead = appointment.patientsAhead
        self.estimatedWait = appointment.estimatedWait
        self.currentToken = appointment.currentToken
        self.patientName = appointment.patientName
        self.bookedAt = Date()
        self.status = .active
        self.steps = Visit.defaultSteps(for: appointment.department, room: appointment.roomNumber, floor: appointment.floor)
    }
    
    var formattedBookedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return formatter.string(from: bookedAt)
    }
    
    var shortBookedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: bookedAt)
    }
    
    // "Mar 11, 2026" → "Mar 11" — compact display on cards
    var shortAppointmentDate: String {
        if let commaRange = appointmentDate.range(of: ",") {
            return String(appointmentDate[..<commaRange.lowerBound])
        }
        return appointmentDate
    }
    
    // Parse appointmentDate string to Date for date-range filtering
    var appointmentDateParsed: Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM dd, yyyy"
        if let d = formatter.date(from: appointmentDate) { return d }
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.date(from: appointmentDate)
    }
}

// MARK: - Visits Manager
class VisitsManager: ObservableObject {
    @Published var visits: [Visit] = []
    
    private let storageKey = "clinic_flow_visits"
    
    init() {
        loadVisits()
    }
    
    // MARK: - Computed Properties
    var activeVisits: [Visit] {
        visits
            .filter { $0.status == .active }
            .sorted { $0.bookedAt > $1.bookedAt }
    }
    
    var pastVisits: [Visit] {
        visits
            .filter { $0.status == .completed || $0.status == .cancelled }
            .sorted { $0.bookedAt > $1.bookedAt }
    }
    
    var hasActiveVisits: Bool {
        !activeVisits.isEmpty
    }
    
    // MARK: - Get live visit by ID
    func visit(byID id: UUID) -> Visit? {
        visits.first(where: { $0.id == id })
    }
    
    // MARK: - Actions
    func addVisit(from appointment: AppointmentData) {
        let visit = Visit(from: appointment)
        visits.insert(visit, at: 0)
        saveVisits()
    }
    
    func cancelVisit(_ visit: Visit) {
        if let index = visits.firstIndex(where: { $0.id == visit.id }) {
            visits[index].status = .cancelled
            saveVisits()
        }
    }
    
    func completeVisit(_ visit: Visit) {
        if let index = visits.firstIndex(where: { $0.id == visit.id }) {
            visits[index].status = .completed
            for i in visits[index].steps.indices {
                visits[index].steps[i].isCompleted = true
                visits[index].steps[i].isCurrent = false
            }
            saveVisits()
        }
    }
    
    @discardableResult
    func advanceStep(for visitID: UUID) -> String? {
        guard let index = visits.firstIndex(where: { $0.id == visitID }) else { return nil }
        guard let currentIdx = visits[index].steps.firstIndex(where: { $0.isCurrent }) else { return nil }
        
        visits[index].steps[currentIdx].isCompleted = true
        visits[index].steps[currentIdx].isCurrent = false
        
        let nextIdx = currentIdx + 1
        if nextIdx < visits[index].steps.count {
            visits[index].steps[nextIdx].isCurrent = true
            
            if visits[index].steps[nextIdx].label == "Completed" {
                visits[index].steps[nextIdx].isCompleted = true
                visits[index].steps[nextIdx].isCurrent = false
                visits[index].status = .completed
            }
            
            saveVisits()
            return visits[index].steps[nextIdx].label
        } else {
            visits[index].status = .completed
            saveVisits()
            return nil
        }
    }
    
    func addReferralStep(_ step: VisitStep, to visitID: UUID) {
        guard let index = visits.firstIndex(where: { $0.id == visitID }) else { return }
        
        if let completedIdx = visits[index].steps.lastIndex(where: { $0.label == "Completed" }) {
            visits[index].steps.insert(step, at: completedIdx)
        } else {
            visits[index].steps.append(step)
        }
        
        saveVisits()
    }
    
    func cancelVisitByToken(_ tokenNumber: String) {
        if let index = visits.firstIndex(where: { $0.tokenNumber == tokenNumber && $0.status == .active }) {
            visits[index].status = .cancelled
            saveVisits()
        }
    }
    
    func deleteVisit(_ visit: Visit) {
        visits.removeAll { $0.id == visit.id }
        saveVisits()
    }
    
    // MARK: - Persistence
    private func saveVisits() {
        if let data = try? JSONEncoder().encode(visits) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func loadVisits() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Visit].self, from: data) {
            visits = decoded
        }
    }
}
