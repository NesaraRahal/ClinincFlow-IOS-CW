//
//  NotificationManager.swift
//  ClinicFlow
//

import SwiftUI
import Combine

class NotificationManager: ObservableObject {
    @Published var notifications: [NotificationItem] = []
    
    // Add a new notification
    func addNotification(type: NotificationItem.NotificationType, title: String, message: String) {
        let notification = NotificationItem(
            type: type,
            title: title,
            message: message,
            time: "Just now",
            isRead: false,
            timestamp: Date()
        )
        notifications.insert(notification, at: 0)
    }
    
    // Mark notification as read
    func markAsRead(_ notificationId: UUID) {
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            notifications[index].isRead = true
        }
    }
    
    // Mark all as read
    func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }
    
    // Clear all notifications
    func clearAll() {
        notifications.removeAll()
    }
    
    // Appointment booked notification
    func notifyAppointmentBooked(service: String, doctorName: String, time: String, date: String, tokenNumber: String) {
        addNotification(
            type: .appointment,
            title: "Appointment Confirmed",
            message: "\(service) appointment with \(doctorName) scheduled for \(date) at \(time). Token: \(tokenNumber)"
        )
    }
    
    // Queue position update - 3 patients ahead
    func notifyQueuePosition(patientsAhead: Int, tokenNumber: String, roomNumber: String) {
        if patientsAhead <= 3 {
            addNotification(
                type: .tokenUpdate,
                title: "Your turn is approaching!",
                message: "Only \(patientsAhead) patient\(patientsAhead == 1 ? "" : "s") ahead. Token \(tokenNumber) - Please proceed to Room \(roomNumber)."
            )
        }
    }
    
    // Position changed due to cancellation
    func notifyPositionChanged(oldPosition: Int, newPosition: Int, tokenNumber: String) {
        let change = oldPosition - newPosition
        addNotification(
            type: .tokenUpdate,
            title: "Queue Position Updated",
            message: "You moved up \(change) position\(change == 1 ? "" : "s")! Now \(newPosition) patient\(newPosition == 1 ? "" : "s") ahead. Token: \(tokenNumber)"
        )
    }
    
    // Check-in success
    func notifyCheckInSuccess(tokenNumber: String, roomNumber: String) {
        addNotification(
            type: .system,
            title: "Check-in Successful",
            message: "You've been checked in. Token: \(tokenNumber), Room: \(roomNumber). Please wait for your turn."
        )
    }
    
    // Your turn
    func notifyYourTurn(tokenNumber: String, roomNumber: String, doctorName: String) {
        addNotification(
            type: .tokenUpdate,
            title: "🎉 It's Your Turn!",
            message: "Token \(tokenNumber) - Please proceed to Room \(roomNumber). \(doctorName) is ready to see you."
        )
    }
    
    // Appointment reminder (1 hour before)
    func notifyAppointmentReminder(doctorName: String, time: String, roomNumber: String) {
        addNotification(
            type: .appointment,
            title: "Appointment Reminder",
            message: "Your appointment with \(doctorName) is in 1 hour at \(time). Room: \(roomNumber)"
        )
    }
    
    // Cancellation success
    func notifyCancellationSuccess(service: String, refundAmount: String) {
        addNotification(
            type: .system,
            title: "Appointment Cancelled",
            message: "\(service) appointment cancelled successfully. Refund of \(refundAmount) will be processed within 3-5 business days."
        )
    }
    
    // Prescription ready
    func notifyPrescriptionReady(doctorName: String) {
        addNotification(
            type: .system,
            title: "Prescription Ready",
            message: "Your prescription from \(doctorName) is ready for pickup at the pharmacy."
        )
    }
    
    // Lab results ready
    func notifyLabResultsReady(testName: String, date: String) {
        addNotification(
            type: .appointment,
            title: "Lab Results Available",
            message: "Your \(testName) results from \(date) are now ready to view."
        )
    }
    
    // Get unread count
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    // Format relative time
    func updateNotificationTimes() {
        for index in notifications.indices {
            notifications[index].time = relativeTime(from: notifications[index].timestamp)
        }
    }
    
    private func relativeTime(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) min\(minutes == 1 ? "" : "s") ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else if interval < 172800 {
            return "Yesterday"
        } else {
            let days = Int(interval / 86400)
            return "\(days) days ago"
        }
    }
}

// MARK: - Enhanced Notification Item Model
struct NotificationItem: Identifiable {
    let id = UUID()
    let type: NotificationType
    let title: String
    let message: String
    var time: String
    var isRead: Bool
    let timestamp: Date
    
    enum NotificationType {
        case tokenUpdate
        case appointment
        case system
        case promotion
        case cancellation
        case labResults
        case prescription
        
        var icon: String {
            switch self {
            case .tokenUpdate: return "ticket.fill"
            case .appointment: return "calendar.badge.clock"
            case .system: return "checkmark.circle.fill"
            case .promotion: return "heart.fill"
            case .cancellation: return "xmark.circle.fill"
            case .labResults: return "doc.text.fill"
            case .prescription: return "pill.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .tokenUpdate: return Color(hex: "16A34A")
            case .appointment: return .blue
            case .system: return .green
            case .promotion: return .pink
            case .cancellation: return .orange
            case .labResults: return .purple
            case .prescription: return .cyan
            }
        }
    }
}
