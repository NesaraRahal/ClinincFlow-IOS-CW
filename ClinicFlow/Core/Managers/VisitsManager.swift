//
//  VisitsManager.swift
//  ClinicFlow
//
//  Created by COBSCCOMP242P-052 on 2026-02-23.
//

import SwiftUI
import Combine

// MARK: - Visit Status
enum VisitStatus: String, Codable, Equatable {
    case active    = "Active"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

// MARK: - Visit Record
struct VisitRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let tokenNumber: String
    let department: String
    let doctorName: String
    let doctorRole: String
    let roomNumber: String
    let floor: String
    let appointmentDate: String
    let appointmentTime: String
    let patientName: String
    var status: VisitStatus

    init(
        id: UUID = UUID(),
        tokenNumber: String,
        department: String,
        doctorName: String,
        doctorRole: String = "",
        roomNumber: String,
        floor: String,
        appointmentDate: String = "",
        appointmentTime: String = "",
        patientName: String = "Self",
        status: VisitStatus = .active
    ) {
        self.id = id
        self.tokenNumber = tokenNumber
        self.department = department
        self.doctorName = doctorName
        self.doctorRole = doctorRole
        self.roomNumber = roomNumber
        self.floor = floor
        self.appointmentDate = appointmentDate
        self.appointmentTime = appointmentTime
        self.patientName = patientName
        self.status = status
    }
}

// MARK: - Visits Manager
class VisitsManager: ObservableObject {
    @Published var visits: [VisitRecord] = []

    /// Create a VisitRecord from an AppointmentData and append it to the list.
    func addVisit(from data: AppointmentData) {
        let record = VisitRecord(
            tokenNumber: data.tokenNumber,
            department: data.department,
            doctorName: data.doctorName,
            doctorRole: data.doctorRole,
            roomNumber: data.roomNumber,
            floor: data.floor,
            appointmentDate: data.appointmentDate,
            appointmentTime: data.appointmentTime,
            patientName: data.patientName,
            status: .active
        )
        visits.append(record)
    }

    /// Mark the visit with the given token as cancelled.
    func cancelVisitByToken(_ tokenNumber: String) {
        if let index = visits.firstIndex(where: { $0.tokenNumber == tokenNumber }) {
            visits[index].status = .cancelled
        }
    }

    /// Mark the visit with the given token as completed.
    func completeVisitByToken(_ tokenNumber: String) {
        if let index = visits.firstIndex(where: { $0.tokenNumber == tokenNumber }) {
            visits[index].status = .completed
        }
    }

    /// All currently active visits.
    var activeVisits: [VisitRecord] {
        visits.filter { $0.status == .active }
    }
}
