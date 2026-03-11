//
//  VisitsManager.swift
//  ClinicFlow
//

import SwiftUI
import Combine

// MARK: - Visit Status
enum VisitStatus: String, Codable {
    case active
    case completed
    case cancelled
}

// MARK: - Visit Record
struct VisitRecord: Identifiable, Equatable {
    let id = UUID()
    let tokenNumber: String
    let department: String
    let doctorName: String
    let roomNumber: String
    let floor: String
    let bookedAt: Date
    var status: VisitStatus
}

// MARK: - Visits Manager
class VisitsManager: ObservableObject {
    @Published var visits: [VisitRecord] = []
    
    /// Add a new visit from appointment data
    func addVisit(from data: AppointmentData) {
        let record = VisitRecord(
            tokenNumber: data.tokenNumber,
            department: data.department,
            doctorName: data.doctorName,
            roomNumber: data.roomNumber,
            floor: data.floor,
            bookedAt: Date(),
            status: .active
        )
        visits.append(record)
    }
    
    /// Cancel a visit by token number
    func cancelVisitByToken(_ token: String) {
        if let index = visits.firstIndex(where: { $0.tokenNumber == token && $0.status == .active }) {
            visits[index].status = .cancelled
        }
    }
    
    /// Mark a visit as completed
    func completeVisitByToken(_ token: String) {
        if let index = visits.firstIndex(where: { $0.tokenNumber == token && $0.status == .active }) {
            visits[index].status = .completed
        }
    }
    
    /// Active visits count
    var activeVisitsCount: Int {
        visits.filter { $0.status == .active }.count
    }
}
