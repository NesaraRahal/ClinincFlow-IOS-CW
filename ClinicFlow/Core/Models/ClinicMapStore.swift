//
//  ClinicMapStore.swift
//  ClinicFlow
//

import Foundation

// MARK: - Clinic Map Store
// Maps departments and rooms to location IDs for the indoor navigation system
struct ClinicMapStore {
    
    /// Convert department + room number into a map location ID
    static func roomID(forDepartment department: String, roomNumber: String) -> String {
        let deptKey: String
        switch department.lowercased() {
        case "opd":
            deptKey = "opd"
        case "laboratory":
            deptKey = "lab"
        case "pharmacy":
            deptKey = "pharmacy"
        case "radiology":
            deptKey = "radiology"
        case "vaccination":
            deptKey = "vaccination"
        case "specialist clinic":
            deptKey = "specialist"
        default:
            deptKey = department.lowercased().replacingOccurrences(of: " ", with: "_")
        }
        return "\(deptKey)_room_\(roomNumber)"
    }
    
    /// All known floor names
    static let floors = ["Ground Floor", "1st Floor", "2nd Floor", "3rd Floor"]
    
    /// Entrance location ID
    static let entranceID = "entrance"
}
