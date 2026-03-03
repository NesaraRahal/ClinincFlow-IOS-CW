//
//  AppointmentSummaryView.swift
//  ClinicFlow
//
//  Created by COBSCCOMP24.2P-053 on 2026-03-03.
//

import SwiftUI

// MARK: - Appointment Summary View
struct AppointmentSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var hapticsManager: HapticsManager
    let doctor: SpecialistDoctor
    @State var selectedDate: Date
    @State var selectedTime: String
    var onAppointmentBooked: ((AppointmentData) -> Void)? = nil
    
    @State private var patientName = "Kavindu Perera"
    @State private var patientAge = "28"
    @State private var patientPhone = "+94 77 123 4567"
    @State private var symptoms = ""
    
    @State private var isEditingPatient = false
    @State private var isEditingDateTime = false
    @State private var showConfirmed = false
    
    // Editing temps
    @State private var tempDate = Date()
    @State private var tempTime = ""
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // MARK: - Doctor Info Card
                    SummaryCard(title: "Doctor", icon: "stethoscope") {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "16A34A").opacity(0.15), Color(hex: "22C55E").opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 52, height: 52)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(Color(hex: "16A34A"))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(doctor.name)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text(doctor.specialty)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text(doctor.qualification)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // MARK: - Date & Time Card
                    SummaryCard(title: "Date & Time", icon: "calendar.badge.clock", isEditable: true, onEdit: {
                        tempDate = selectedDate
                        tempTime = selectedTime
                        isEditingDateTime = true
                    }) {
                        VStack(spacing: 12) {
                            SummaryRow(icon: "calendar", label: "Date", value: formattedDate)
                            
                            Divider()
                            
                            SummaryRow(icon: "clock.fill", label: "Time", value: selectedTime)
                        }
                    }
                    
                    // MARK: - Patient Info Card
                    SummaryCard(title: "Patient Details", icon: "person.text.rectangle", isEditable: true, onEdit: {
                        isEditingPatient = true
                    }) {
                        VStack(spacing: 12) {
                            SummaryRow(icon: "person.fill", label: "Name", value: patientName)
                            
                            Divider()
                            
                            SummaryRow(icon: "number", label: "Age", value: patientAge)
                            
                            Divider()
                            
                            SummaryRow(icon: "phone.fill", label: "Phone", value: patientPhone)
                        }
                    }
                    
                    // MARK: - Symptoms / Notes
                    SummaryCard(title: "Symptoms / Notes", icon: "note.text") {
                        TextField("Describe your symptoms (optional)", text: $symptoms, axis: .vertical)
                            .font(.system(size: 14))
                            .lineLimit(3...6)
                            .textFieldStyle(.plain)
                    }
                    
                    // MARK: - Fee Breakdown
                    SummaryCard(title: "Fee Summary", icon: "creditcard.fill") {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Consultation Fee")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(doctor.consultationFee)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            
                            HStack {
                                Text("Service Charge")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("LKR 200")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Total")
                                    .font(.system(size: 16, weight: .semibold))
                                Spacer()
                                Text(totalFee)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(hex: "16A34A"))
                            }
                        }
                    }
                    
                    Spacer().frame(height: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Appointment Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: {
                    hapticsManager.playConfirmSound()
                    showConfirmed = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                        Text("Confirm Appointment")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(hex: "16A34A"))
                    .clipShape(Capsule())
                    .shadow(color: Color(hex: "16A34A").opacity(0.35), radius: 10, x: 0, y: 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 20)
                .background(
                    Color(.systemBackground)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: -4)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
            // Edit Date & Time Sheet
            .sheet(isPresented: $isEditingDateTime) {
                EditDateTimeSheet(
                    date: $tempDate,
                    time: $tempTime,
                    timeSlots: [
                        "09:00 AM", "09:30 AM", "10:00 AM", "10:30 AM",
                        "11:00 AM", "11:30 AM",
                        "02:00 PM", "02:30 PM", "03:00 PM", "03:30 PM",
                        "04:00 PM", "04:30 PM", "05:00 PM"
                    ],
                    onSave: {
                        selectedDate = tempDate
                        selectedTime = tempTime
                    }
                )
                .presentationDetents([.medium, .large])
            }
            // Edit Patient Sheet
            .sheet(isPresented: $isEditingPatient) {
                EditPatientSheet(
                    name: $patientName,
                    age: $patientAge,
                    phone: $patientPhone
                )
                .presentationDetents([.medium])
            }
            .fullScreenCover(isPresented: $showConfirmed) {
                AppointmentConfirmedView(
                    doctor: doctor,
                    date: formattedDate,
                    time: selectedTime,
                    patientName: patientName,
                    onAppointmentBooked: onAppointmentBooked
                )
            }
        }
    }
    
    private var totalFee: String {
        let feeString = doctor.consultationFee
            .replacingOccurrences(of: "LKR ", with: "")
            .replacingOccurrences(of: ",", with: "")
        let feeValue = Int(feeString) ?? 0
        let total = feeValue + 200
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: total)) ?? "\(total)"
        return "LKR \(formatted)"
    }
}

// MARK: - Summary Card Container
struct SummaryCard<Content: View>: View {
    let title: String
    let icon: String
    var isEditable: Bool = false
    var onEdit: (() -> Void)? = nil
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "16A34A"))
                    
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                if isEditable {
                    Button(action: { onEdit?() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Edit")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "16A34A"))
                    }
                }
            }
            
            content
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Summary Row
struct SummaryRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "16A34A").opacity(0.7))
                .frame(width: 20)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Edit Date & Time Sheet
struct EditDateTimeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var date: Date
    @Binding var time: String
    let timeSlots: [String]
    var onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                DatePicker("Date", selection: $date, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .tint(Color(hex: "16A34A"))
                    .padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Time Slot")
                        .font(.system(size: 15, weight: .semibold))
                        .padding(.horizontal, 20)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        ForEach(timeSlots, id: \.self) { slot in
                            Button(action: { time = slot }) {
                                Text(slot)
                                    .font(.system(size: 13, weight: time == slot ? .semibold : .medium))
                                    .foregroundColor(time == slot ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(time == slot ? Color(hex: "16A34A") : Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .padding(.top, 16)
            .navigationTitle("Edit Date & Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "16A34A"))
                }
            }
        }
    }
}

// MARK: - Edit Patient Sheet
struct EditPatientSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var name: String
    @Binding var age: String
    @Binding var phone: String
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Full Name")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    TextField("Enter your name", text: $name)
                        .font(.system(size: 15))
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Age")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    TextField("Enter your age", text: $age)
                        .font(.system(size: 15))
                        .keyboardType(.numberPad)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Phone")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    TextField("Enter phone number", text: $phone)
                        .font(.system(size: 15))
                        .keyboardType(.phonePad)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Edit Patient Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { dismiss() }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "16A34A"))
                }
            }
        }
    }
}

#Preview {
    AppointmentSummaryView(
        doctor: sampleDoctors[0],
        selectedDate: Date(),
        selectedTime: "09:30 AM"
    )
    .environmentObject(HapticsManager())
}
