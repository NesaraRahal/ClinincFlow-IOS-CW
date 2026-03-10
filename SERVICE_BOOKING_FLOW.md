# Service Booking Flow Documentation

## Overview
The service booking flow provides a comprehensive multi-step booking experience for non-specialist services (Pharmacy, OPD, Laboratory, Radiology, and Vaccination).

## Flow Architecture

### Services
1. **Pharmacy** - Requires prescription
2. **Laboratory** - Requires prescription
3. **Radiology** - Requires prescription
4. **Vaccination** - No prescription required
5. **OPD** - No prescription required

### Booking Steps

#### For Services Requiring Prescription (Lab, Radiology, Pharmacy):
1. **Date & Time Selection** → 2. **Prescription Upload** → 3. **Review & Confirm**

#### For Services Not Requiring Prescription (Vaccination, OPD):
1. **Date & Time Selection** → 2. **Review & Confirm**

## Components

### 1. ServiceBookingFlow.swift (Coordinator)
- **Purpose**: Orchestrates the multi-step booking process
- **Key Features**:
  - `BookingStep` enum manages navigation (dateTime → prescription → summary)
  - `requiresPrescription` property determines if prescription step is shown
  - `handleEdit(field:)` allows navigation back to specific steps from summary
  - `bookAppointment()` creates appointment with service-specific staff/room assignments
  - ImagePicker wrapper for prescription photo library access

### 2. ServiceDateTimeView.swift (Step 1)
- **Purpose**: Date and time slot selection
- **Key Features**:
  - Graphical DatePicker with minimum date validation (today onwards)
  - Time slots separated into Morning (8:00 AM - 11:30 AM) and Afternoon (2:00 PM - 5:30 PM)
  - FlowLayout custom layout for wrapping time slot buttons
  - Booked slot simulation (shows which slots are unavailable)
  - Continue button disabled until both date and time are selected
- **Reuses**: Similar pattern from AppointmentDateTimeView

### 3. PrescriptionUploadView.swift (Step 2 - Conditional)
- **Purpose**: Upload prescription from doctor
- **When Shown**: Only for Laboratory, Radiology, and Pharmacy services
- **Key Features**:
  - Upload placeholder with dashed border and tap gesture
  - Image preview with Change/Remove actions
  - Optional notes TextEditor for additional information
  - Info banner with upload guidelines
  - Continue button disabled until image is uploaded
  - Back button to return to date/time selection

### 4. ServiceBookingSummaryView.swift (Step 3)
- **Purpose**: Review all booking details before confirmation
- **Key Features**:
  - Service information display with icon
  - Patient name (if booking for family member)
  - Date & time with Edit button → navigates back to ServiceDateTimeView
  - Prescription preview with Edit button → navigates back to PrescriptionUploadView
  - Notes display (if provided)
  - Important information banner
  - Back button and Confirm Booking button
  - Edit functionality for all fields

## Integration with HomeView

### ServiceCard Component
```swift
// User taps on service card
// If "Specialist Clinic" → DoctorListView
// Otherwise → ServiceBookingFlow

.fullScreenCover(isPresented: $showServiceBooking) {
    ServiceBookingFlow(
        serviceTitle: service.title,
        serviceIcon: service.icon,
        patientName: patientName,
        onAppointmentBooked: wrappedCallback
    )
}
```

## Staff & Room Assignments

| Service | Assigned Staff | Role | Room |
|---------|---------------|------|------|
| Laboratory | Lab Technician Sarah | Senior Lab Technician | 201 |
| Pharmacy | Pharmacist John | Chief Pharmacist | G-05 |
| Radiology | Radiologist Dr. Smith | Radiologist | B-12 |
| Vaccination | Nurse Emily | Vaccination Nurse | 203 |
| OPD | Dr. Ahmed Khan | General Physician | 305 |

## User Experience Flow

### Example: Booking Laboratory Service

1. **User Action**: Tap "Laboratory" card in HomeView
2. **Screen 1**: ServiceDateTimeView
   - Select date: "Friday, Dec 27, 2024"
   - Select time slot: "09:00 AM"
   - Tap "Continue"
3. **Screen 2**: PrescriptionUploadView (shown because Lab requires prescription)
   - Tap "Tap to Upload Prescription"
   - Select image from photo library
   - Optionally add notes: "Blood test as prescribed"
   - Tap "Continue"
4. **Screen 3**: ServiceBookingSummaryView
   - Review: Laboratory service, selected date/time, prescription preview
   - Can tap "Edit" on any section to go back
   - Tap "Confirm Booking"
5. **Result**: Navigate to PatientHomeView with token number

### Example: Booking Vaccination Service

1. **User Action**: Tap "Vaccination" card in HomeView
2. **Screen 1**: ServiceDateTimeView
   - Select date: "Monday, Dec 30, 2024"
   - Select time slot: "10:00 AM"
   - Tap "Continue"
3. **Screen 2**: ServiceBookingSummaryView (prescription step skipped)
   - Review: Vaccination service, selected date/time
   - Can tap "Edit" to modify date/time
   - Tap "Confirm Booking"
4. **Result**: Navigate to PatientHomeView with token number

## Design Consistency
- Uses brand green color (#16A34A, #22C55E)
- Follows SwiftUI best practices with component composition
- Haptic feedback for button taps and confirmations
- Consistent button styles across all screens
- Safe area handling with bottom toolbars
- Shadow effects for depth and visual hierarchy

## State Management
- `@State` for local component state
- `@Binding` for parent-child data flow
- `@Environment(\.dismiss)` for navigation
- `@EnvironmentObject` for HapticsManager
- Enum-based step navigation for clarity

## Validation Rules
1. Date must be today or later
2. Time slot must be selected (not booked)
3. Prescription image required for Lab/Radiology/Pharmacy
4. All fields validated before allowing booking confirmation
