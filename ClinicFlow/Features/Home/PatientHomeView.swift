//
//  PatientHomeView.swift
//  ClinicFlow
//

import SwiftUI

struct PatientHomeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var profileManager: UserProfileManager
    @EnvironmentObject var hapticsManager: HapticsManager
    @EnvironmentObject var familyManager: FamilyMembersManager
    @EnvironmentObject var activeProfileManager: ActiveProfileManager
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var showMap = false
    @State private var showNotifications = false
    @State private var showProfileSwitcher = false
    @State private var showCancelAlert = false
    @State private var showDoctorDetail = false
    @State private var showProgressDetail = false
    @State private var showServiceSelection = false
    @State private var selectedIndex: Int = 0
    
    let appointments: [AppointmentData]
    var onCancelAppointment: ((_ tokenNumber: String) -> Void)? = nil
    var onNavigateToMap: ((_ originID: String, _ destinationID: String) -> Void)? = nil
    var onBookAnotherService: ((AppointmentData) -> Void)? = nil
    
    // Current appointment being viewed
    private var appointment: AppointmentData {
        let idx = min(selectedIndex, appointments.count - 1)
        return appointments[max(0, idx)]
    }
    
    var unreadNotificationCount: Int {
        notificationManager.unreadCount
    }
    
    // Dynamic visit progress steps based on department
    var visitSteps: [PatientVisitStep] {
        var steps: [PatientVisitStep] = [
            PatientVisitStep(title: "Check-in", isCompleted: true, isCurrent: false),
            PatientVisitStep(title: "Wait", isCompleted: false, isCurrent: true),
            PatientVisitStep(title: "Consult", isCompleted: false, isCurrent: false)
        ]
        
        // Add department-specific additional steps
        switch appointment.department {
        case "Laboratory":
            steps.append(PatientVisitStep(title: "Lab", isCompleted: false, isCurrent: false))
        case "Pharmacy":
            steps.append(PatientVisitStep(title: "Medicine", isCompleted: false, isCurrent: false))
        case "Radiology":
            steps.append(PatientVisitStep(title: "Scan", isCompleted: false, isCurrent: false))
        case "Vaccination":
            steps.append(PatientVisitStep(title: "Vaccine", isCompleted: false, isCurrent: false))
        default:
            break
        }
        
        // Always add Done as final step
        steps.append(PatientVisitStep(title: "Done", isCompleted: false, isCurrent: false))
        
        return steps
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // MARK: - Custom Header
                PatientHomeHeader(
                    unreadNotificationCount: unreadNotificationCount,
                    showNotifications: $showNotifications,
                    showProfileSwitcher: $showProfileSwitcher
                )
                
                // MARK: - Active Queues Switcher (when multiple)
                if appointments.count > 1 {
                    ActiveQueuesSwitcher(
                        appointments: appointments,
                        selectedIndex: $selectedIndex
                    )
                }
                
                // MARK: - Hero Token Card
                TokenCardView(appointment: appointment)
                
                // MARK: - Visit Progress
                Button(action: {
                    hapticsManager.playTapSound()
                    showProgressDetail = true
                }) {
                    ZStack(alignment: .topTrailing) {
                        VisitProgressView(visitSteps: visitSteps)
                        
                        // Chevron indicator inside card
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.secondary, Color(.systemGray6))
                            .padding([.top, .trailing], 32)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // MARK: - Location Card
                LocationCardView(appointment: appointment, showMap: $showMap)
                
                // MARK: - Assigned Staff Card
                AssignedStaffCardView(appointment: appointment, showDoctorDetail: $showDoctorDetail)
                
                // MARK: - Book Another Service
                BookAnotherServiceButton(showServiceSelection: $showServiceSelection)
                
                // MARK: - Cancel Appointment
                CancelAppointmentButton(
                    showCancelAlert: $showCancelAlert,
                    tokenNumber: appointment.tokenNumber
                )
                
                Spacer(minLength: 100)
            }
            .padding(.top, 4)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            announceAppointmentDetails()
            checkQueuePosition()
        }
        .onChange(of: appointments.count) { _, newCount in
            // If current index is now out of bounds, move to last
            if selectedIndex >= newCount {
                selectedIndex = max(0, newCount - 1)
            }
        }
        .alert("Cancel Appointment?", isPresented: $showCancelAlert) {
            Button("Keep Appointment", role: .cancel) { }
            Button("Yes, Cancel", role: .destructive) {
                let token = appointment.tokenNumber
                // If cancelling the currently viewed one, adjust index
                if selectedIndex > 0 && selectedIndex >= appointments.count - 1 {
                    selectedIndex = selectedIndex - 1
                }
                onCancelAppointment?(token)
            }
        } message: {
            Text("Are you sure you want to cancel your \(appointment.department) appointment? Your token \(appointment.tokenNumber) will be released.")
        }
        .sheet(isPresented: $showMap) {
            NavigationStack {
                MapTabView(
                    initialOriginID: "entrance",
                    initialDestinationID: ClinicMapStore.roomID(
                        forDepartment: appointment.department,
                        roomNumber: appointment.roomNumber
                    )
                )
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { showMap = false }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "16A34A"))
                    }
                }
            }
        }
        .sheet(isPresented: $showNotifications) {
            NotificationView()
        }
        .sheet(isPresented: $showProfileSwitcher) {
            NavigationStack {
                ProfileSwitcherView()
            }
        }
        .sheet(isPresented: $showDoctorDetail) {
            DoctorDetailSheet(appointment: appointment)
        }
        .sheet(isPresented: $showProgressDetail) {
            VisitProgressDetailView(appointment: appointment, patientSteps: visitSteps)
        }
        .sheet(isPresented: $showServiceSelection) {
            NavigationStack {
                HomeView(onAppointmentBooked: { data in
                    showServiceSelection = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onBookAnotherService?(data)
                    }
                })
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { showServiceSelection = false }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "16A34A"))
                    }
                }
            }
        }
    }
    
    private func announceAppointmentDetails() {
        let doctor = appointment.doctorName
        let token = appointment.tokenNumber
        let ahead = appointment.patientsAhead
        hapticsManager.speak("Appointment active. Doctor \(doctor). Your token number is \(token). \(ahead) patients ahead of you in the queue.")
    }
    
    private func checkQueuePosition() {
        // Notify if only 3 or fewer patients ahead
        if appointment.patientsAhead <= 3 {
            notificationManager.notifyQueuePosition(
                patientsAhead: appointment.patientsAhead,
                tokenNumber: appointment.tokenNumber,
                roomNumber: appointment.roomNumber
            )
        }
        
        // Notify if it's your turn (0 patients ahead)
        if appointment.patientsAhead == 0 {
            notificationManager.notifyYourTurn(
                tokenNumber: appointment.tokenNumber,
                roomNumber: appointment.roomNumber,
                doctorName: appointment.doctorName
            )
        }
    }
}

// MARK: - Patient Home Header
struct PatientHomeHeader: View {
    @EnvironmentObject var hapticsManager: HapticsManager
    let unreadNotificationCount: Int
    @Binding var showNotifications: Bool
    @Binding var showProfileSwitcher: Bool
    
    var body: some View {
        HStack {
                    // Logo
                    HStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "16A34A"), Color(hex: "22C55E")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "cross.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text("ClinicFlow")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Notification & Profile Icons
                    HStack(spacing: 12) {
                        // Notification Button
                        Button(action: {
                            hapticsManager.playTapSound()
                            showNotifications = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 42, height: 42)
                                
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 17))
                                    .foregroundColor(.primary)
                            }
                            .overlay(alignment: .topTrailing) {
                        if unreadNotificationCount > 0 {
                            ZStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 18, height: 18)
                                
                                Text("\(unreadNotificationCount)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .offset(x: 4, y: -4)
                        }
                    }
                }
                .frame(width: 42, height: 42)
                
                // Profile Button
                ActiveProfileButton(size: 42) {
                    hapticsManager.playTapSound()
                    showProfileSwitcher = true
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

// MARK: - Active Queues Switcher
struct ActiveQueuesSwitcher: View {
    @EnvironmentObject var hapticsManager: HapticsManager
    let appointments: [AppointmentData]
    @Binding var selectedIndex: Int
    
    private let greenPrimary = Color(hex: "16A34A")
    
    private func iconForDepartment(_ dept: String) -> String {
        switch dept {
        case "Laboratory": return "flask.fill"
        case "Pharmacy": return "cross.case.fill"
        case "Radiology": return "waveform.path.ecg"
        case "Vaccination": return "syringe.fill"
        case "OPD": return "stethoscope"
        case "Specialist Clinic": return "heart.text.square.fill"
        default: return "cross.fill"
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Active Queues")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(appointments.count) services")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(appointments.enumerated()), id: \.offset) { index, appt in
                        Button(action: {
                            hapticsManager.playTapSound()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedIndex = index
                            }
                        }) {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(selectedIndex == index ? greenPrimary : Color(.systemGray5))
                                        .frame(width: 32, height: 32)
                                    
                                    Image(systemName: iconForDepartment(appt.department))
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(selectedIndex == index ? .white : .secondary)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(appt.department)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(selectedIndex == index ? greenPrimary : .primary)
                                    
                                    Text("Token #\(appt.tokenNumber)")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(selectedIndex == index ? greenPrimary.opacity(0.08) : Color(.systemBackground))
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        selectedIndex == index ? greenPrimary.opacity(0.4) : Color(.systemGray5),
                                        lineWidth: selectedIndex == index ? 1.5 : 1
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Book Another Service Button
struct BookAnotherServiceButton: View {
    @EnvironmentObject var hapticsManager: HapticsManager
    @Binding var showServiceSelection: Bool
    
    var body: some View {
        Button(action: {
            hapticsManager.playTapSound()
            showServiceSelection = true
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "16A34A").opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "16A34A"))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Book Another Service")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Add X-Ray, Lab, Pharmacy & more to your visit")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "16A34A").opacity(0.3), Color(hex: "22C55E").opacity(0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Cancel Appointment Button
struct CancelAppointmentButton: View {
    @EnvironmentObject var hapticsManager: HapticsManager
    @Binding var showCancelAlert: Bool
    let tokenNumber: String
    
    var body: some View {
        Button(action: {
            hapticsManager.playErrorSound()
            showCancelAlert = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                
                Text("Cancel Appointment")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.red.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.red.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Indoor Map Placeholder View
struct IndoorMapView: View {
    @Environment(\.dismiss) private var dismiss
    let roomNumber: String
    let department: String
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Map Placeholder
                ZStack {
                    Color(.systemGray6)
                    
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "map")
                                .font(.system(size: 40))
                                .foregroundColor(Color(.systemGray3))
                        }
                        
                        VStack(spacing: 8) {
                            Text("Indoor Map")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Coming Soon")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 320)
                
                // Direction Details
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
                        DirectionStep(
                            step: 1,
                            instruction: "Head towards the main elevator",
                            detail: "From the waiting area"
                        )
                        
                        DirectionStep(
                            step: 2,
                            instruction: "Go to 3rd Floor",
                            detail: "Take the elevator"
                        )
                        
                        DirectionStep(
                            step: 3,
                            instruction: "Turn left from elevator",
                            detail: "Walk ~30 meters"
                        )
                        
                        DirectionStep(
                            step: 4,
                            instruction: "Room \(roomNumber) on your right",
                            detail: "\(department) Wing",
                            isLast: true
                        )
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding(20)
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Directions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "16A34A"))
                }
            }
        }
    }
}

// MARK: - Direction Step
struct DirectionStep: View {
    let step: Int
    let instruction: String
    let detail: String
    var isLast: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "16A34A"))
                        .frame(width: 28, height: 28)
                    
                    Text("\(step)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                if !isLast {
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(instruction)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(detail)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, isLast ? 0 : 20)
            
            Spacer()
        }
    }
}



#Preview {
    PatientHomeView(
        appointments: [AppointmentData.randomForService("OPD")]
    )
    .environmentObject(UserProfileManager())
    .environmentObject(HapticsManager())
    .environmentObject(FamilyMembersManager())
    .environmentObject(ActiveProfileManager())
}
