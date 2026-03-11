import SwiftUI

// MARK: - Map Tab View
// Full-bleed indoor map screen inspired by Apple Maps / Situm.
// Floating controls: floor selector, search/route bottom sheet.
// Supports deep-link from PatientHomeView (initialOriginID/Dest).

struct MapTabView: View {
    let initialOriginID: String?
    let initialDestinationID: String?
    @EnvironmentObject var hapticsManager: HapticsManager

    // MARK: Navigation state
    @State private var currentFloor: Int = 0
    @State private var originID: String? = nil
    @State private var destinationID: String? = nil
    @State private var isNavigating: Bool = false
    @State private var hasAppliedInitial: Bool = false
    @State private var reachedElevator: Bool = false

    // MARK: Sheet state
    @State private var showOriginPicker = false
    @State private var showDestPicker = false
    @State private var routeSheetDetent: PresentationDetent = .height(210)

    // Quick department chips (most common destinations)
    private let quickChips: [(String, String, String)] = [
        ("Pharmacy", "cross.case.fill", "P-001"),
        ("OPD", "stethoscope", "O-101"),
        ("Lab", "flask.fill", "L-201"),
        ("Vaccination", "syringe.fill", "V-101"),
        ("Radiology", "waveform.path.ecg", "rad"),
        ("Specialist", "heart.fill", "S-301"),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            // ── Full-bleed floor plan ──
            FloorPlanView(
                floorData: ClinicMapStore.data(for: currentFloor),
                originID: originID,
                destinationID: destinationID,
                isNavigating: isNavigating,
                onRoomTapped: { room in handleRoomTap(room) }
            )
            .ignoresSafeArea()

            // ── Floating floor selector (leading) ──
            floorSelector
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.leading, 16)
                .padding(.top, 56)

            // ── Floor label badge (trailing) ──
            floorLabel
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.trailing, 16)
                .padding(.top, 60)

            // ── Bottom route panel ──
            routePanel
                .transition(.move(edge: .bottom))
        }
        .onAppear { applyInitialNavigation() }
        .sheet(isPresented: $showOriginPicker) {
            LocationPickerView(title: "Start Location", selectedRoomID: $originID, selectedFloor: $currentFloor)
        }
        .sheet(isPresented: $showDestPicker) {
            LocationPickerView(title: "Destination", selectedRoomID: $destinationID, selectedFloor: $currentFloor)
        }
    }

    // MARK: - Floor Selector
    private var floorSelector: some View {
        VStack(spacing: 0) {
            ForEach([3, 2, 1, 0], id: \.self) { floor in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        currentFloor = floor
                    }
                    hapticsManager.lightTap()
                } label: {
                    Text(floor == 0 ? "G" : "\(floor)")
                        .font(.system(size: 14, weight: currentFloor == floor ? .bold : .medium, design: .rounded))
                        .foregroundColor(currentFloor == floor ? .white : .secondary)
                        .frame(width: 38, height: 38)
                        .background {
                            if currentFloor == floor {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: "16A34A"))
                            }
                        }
                }
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
    }

    // MARK: - Floor Label
    private var floorLabel: some View {
        HStack(spacing: 6) {
            Image(systemName: "building.2.fill")
                .font(.system(size: 11, weight: .semibold))
            Text(currentFloor == 0 ? "Ground Floor" : "Floor \(currentFloor)")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
        }
        .foregroundColor(.primary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }

    // MARK: - Route Panel (bottom card)
    private var routePanel: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)

            if isNavigating {
                activeNavigationPanel
            } else {
                routeInputPanel
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.12), radius: 16, y: -4)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 8)
        .padding(.bottom, 100) // above tab bar
    }

    // MARK: ── Route Input (idle mode) ──
    private var routeInputPanel: some View {
        VStack(spacing: 12) {
            // Origin / Destination fields
            HStack(spacing: 10) {
                // Route dots indicator
                VStack(spacing: 4) {
                    Circle().fill(Color(hex: "007AFF")).frame(width: 10, height: 10)
                    ForEach(0..<3, id: \.self) { _ in
                        Circle().fill(Color.secondary.opacity(0.3)).frame(width: 3, height: 3)
                    }
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "FF3B30"))
                }
                .padding(.leading, 4)

                VStack(spacing: 8) {
                    routeField(label: "From", roomID: originID, placeholder: "Choose start…") {
                        showOriginPicker = true
                    }
                    Divider()
                    routeField(label: "To", roomID: destinationID, placeholder: "Choose destination…") {
                        showDestPicker = true
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)

            // Quick chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickChips, id: \.0) { chip in
                        Button {
                            destinationID = chip.2
                            if let room = ClinicMapStore.room(id: chip.2) {
                                withAnimation(.spring(response: 0.35)) { currentFloor = room.floor }
                            }
                            hapticsManager.lightTap()
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: chip.1)
                                    .font(.system(size: 10, weight: .semibold))
                                Text(chip.0)
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(destinationID == chip.2 ? .white : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background {
                                Capsule().fill(destinationID == chip.2
                                    ? Color(hex: "16A34A")
                                    : Color(.systemGray6)
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            // GO button
            Button {
                guard originID != nil, destinationID != nil else { return }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    reachedElevator = false
                    isNavigating = true
                    adjustFloorForOrigin()
                }
                hapticsManager.mediumTap()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 14, weight: .bold))
                    Text("Start Navigation")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background {
                    Capsule().fill(
                        (originID != nil && destinationID != nil)
                            ? Color(hex: "16A34A")
                            : Color(.systemGray4)
                    )
                }
            }
            .disabled(originID == nil || destinationID == nil)
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
    }

    // MARK: ── Active Navigation Panel ──
    private var activeNavigationPanel: some View {
        VStack(spacing: 10) {
            // Route summary header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    if let o = originID.flatMap({ ClinicMapStore.room(id: $0) }),
                       let d = destinationID.flatMap({ ClinicMapStore.room(id: $0) }) {
                        Text("\(o.shortName) → \(d.shortName)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Text(estimatedTime(from: o, to: d))
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.35)) {
                        isNavigating = false
                        originID = nil
                        destinationID = nil
                        reachedElevator = false
                    }
                    hapticsManager.lightTap()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 26))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)

            // Floor route pills (for cross-floor navigation)
            if let o = originID.flatMap({ ClinicMapStore.room(id: $0) }),
               let d = destinationID.flatMap({ ClinicMapStore.room(id: $0) }),
               o.floor != d.floor {
                crossFloorPills(from: o, to: d)

                // Elevator checkpoint — tap when you arrive at the elevator
                if !reachedElevator {
                    elevatorCheckpoint(destFloor: d.floor)
                }
            }

            // Turn-by-turn directions
            DirectionsCardView(
                originID: originID ?? "",
                destinationID: destinationID ?? "",
                floor: currentFloor
            )
            .padding(.horizontal, 12)
            .padding(.bottom, 14)
        }
    }

    // MARK: - Subviews
    private func routeField(label: String, roomID: String?, placeholder: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                    .frame(width: 32, alignment: .leading)
                if let id = roomID, let room = ClinicMapStore.room(id: id) {
                    Text(room.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                } else {
                    Text(placeholder)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary.opacity(0.6))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .padding(.vertical, 6)
        }
    }

    private func crossFloorPills(from origin: MapRoom, to dest: MapRoom) -> some View {
        let floors = floorSequence(from: origin.floor, to: dest.floor)
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(floors, id: \.self) { floor in
                    let isCompleted = floor == origin.floor && reachedElevator
                    Button {
                        withAnimation(.spring(response: 0.3)) { currentFloor = floor }
                        hapticsManager.lightTap()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: isCompleted
                                  ? "checkmark.circle.fill"
                                  : (floor == origin.floor ? "figure.walk" : (floor == dest.floor ? "flag.fill" : "arrow.up.arrow.down")))
                                .font(.system(size: 10, weight: .bold))
                            Text(floor == 0 ? "Ground" : "Floor \(floor)")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(currentFloor == floor ? .white : (isCompleted ? Color(hex: "16A34A") : .primary))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            Capsule().fill(currentFloor == floor
                                ? Color(hex: "16A34A")
                                : (isCompleted ? Color(hex: "16A34A").opacity(0.12) : Color(.systemGray5)))
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Elevator Checkpoint
    private func elevatorCheckpoint(destFloor: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                reachedElevator = true
                currentFloor = destFloor
            }
            hapticsManager.mediumTap()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "7C3AED").opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "7C3AED"))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Arrived at Elevator?")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    Text("Tap to see the route on Floor \(destFloor == 0 ? "G" : "\(destFloor)")")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "checkmark.circle")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color(hex: "16A34A"))
            }
            .padding(14)
            .background(Color(hex: "7C3AED").opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hex: "7C3AED").opacity(0.12), lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Logic
    private func handleRoomTap(_ room: MapRoom) {
        hapticsManager.lightTap()
        if originID == nil {
            withAnimation(.spring(response: 0.3)) { originID = room.id }
        } else if destinationID == nil {
            withAnimation(.spring(response: 0.3)) { destinationID = room.id }
        } else {
            withAnimation(.spring(response: 0.3)) { destinationID = room.id }
        }
    }

    private func adjustFloorForOrigin() {
        if let oID = originID, let o = ClinicMapStore.room(id: oID) {
            currentFloor = o.floor
        }
    }

    private func applyInitialNavigation() {
        guard !hasAppliedInitial else { return }
        hasAppliedInitial = true
        if let oID = initialOriginID {
            originID = oID
            if let room = ClinicMapStore.room(id: oID) { currentFloor = room.floor }
        }
        if let dID = initialDestinationID {
            destinationID = dID
        }
        if originID != nil && destinationID != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isNavigating = true
                }
            }
        }
    }

    private func floorSequence(from: Int, to: Int) -> [Int] {
        if from <= to { return Array(from...to) }
        return Array(stride(from: from, through: to, by: -1))
    }

    private func estimatedTime(from o: MapRoom, to d: MapRoom) -> String {
        let dx = o.rect.midX - d.rect.midX
        let dy = o.rect.midY - d.rect.midY
        let dist = sqrt(dx * dx + dy * dy)
        let floorPenalty = abs(o.floor - d.floor) * 1
        let mins = max(1, Int(dist * 8) + floorPenalty)
        return "~\(mins) min walk · \(Int(dist * 120)) m"
    }
}
