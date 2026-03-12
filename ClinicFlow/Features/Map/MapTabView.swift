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
        ("Lab", "flask.fill", "L-101"),
        ("Vaccination", "syringe.fill", "V-101"),
        ("Radiology", "waveform.path.ecg", "rad"),
        ("Specialist", "heart.fill", "S-101"),
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

            // ── Floating floor selector (centred at top) ──
            floorSelector
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 58)
                .allowsHitTesting(true)

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
        HStack(spacing: 4) {
            ForEach([0, 1], id: \.self) { floor in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        currentFloor = floor
                    }
                    hapticsManager.lightTap()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: floor == 0 ? "building.2" : "stairs")
                            .font(.system(size: 11, weight: .semibold))
                            .opacity(currentFloor == floor ? 1 : 0.45)
                        Text(floor == 0 ? "Ground" : "Floor 1")
                            .font(.system(size: 13, weight: currentFloor == floor ? .semibold : .regular, design: .rounded))
                    }
                    .foregroundStyle(currentFloor == floor ? .white : Color.primary.opacity(0.6))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background {
                        if currentFloor == floor {
                            Capsule()
                                .fill(Color(hex: "16A34A"))
                                .shadow(color: Color(hex: "16A34A").opacity(0.4), radius: 6, y: 3)
                        }
                    }
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .animation(.spring(response: 0.3, dampingFraction: 0.75), value: currentFloor)
            }
        }
        .padding(4)
        .fixedSize()
        .background {
            Capsule()
                .fill(.regularMaterial)
            Capsule()
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 4)
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
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.regularMaterial)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.10), radius: 20, x: 0, y: -4)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: -1)
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
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                            }
                            .foregroundStyle(destinationID == chip.2 ? .white : Color.primary)
                            .padding(.horizontal, 13)
                            .padding(.vertical, 8)
                            .background {
                                if destinationID == chip.2 {
                                    Capsule().fill(Color(hex: "16A34A"))
                                } else {
                                    Capsule()
                                        .fill(Color(.secondarySystemBackground))
                                    Capsule()
                                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                                }
                            }
                        }
                        .buttonStyle(.plain)
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
                .padding(.vertical, 15)
                .background {
                    if originID != nil && destinationID != nil {
                        Capsule()
                            .fill(LinearGradient(
                                colors: [Color(hex: "22C55E"), Color(hex: "16A34A")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            .shadow(color: Color(hex: "16A34A").opacity(0.45), radius: 10, y: 4)
                    } else {
                        Capsule().fill(Color(.systemGray4))
                    }
                }
            }
            .disabled(originID == nil || destinationID == nil)
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
    }

    // MARK: ── Active Navigation Panel ──
    private var activeNavigationPanel: some View {
        let origin = originID.flatMap { ClinicMapStore.room(id: $0) }
        let dest   = destinationID.flatMap { ClinicMapStore.room(id: $0) }
        let isCross = (origin?.floor ?? 0) != (dest?.floor ?? 0)
        let totalSteps = isCross ? 2 : 1
        let currentStep = isCross ? (reachedElevator ? 2 : 1) : 1

        return VStack(spacing: 0) {
            // ── Header: route title + close ──────────────────────────
            HStack(alignment: .top, spacing: 12) {
                // Step badge
                if isCross {
                    Text("\(currentStep)/\(totalSteps)")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(reachedElevator ? Color(hex: "16A34A") : Color(hex: "7C3AED")))
                }

                VStack(alignment: .leading, spacing: 2) {
                    if let o = origin, let d = dest {
                        Text("\(o.shortName) → \(d.shortName)")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .lineLimit(1)
                        Text(estimatedTime(from: o, to: d))
                            .font(.system(size: 12))
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
            .padding(.bottom, 10)

            Divider().padding(.horizontal, 16)

            // ── Step instruction card ─────────────────────────────────
            if isCross {
                if !reachedElevator {
                    // STEP 1: Walk to elevator
                    stepCard(
                        icon: "arrow.up.arrow.down",
                        iconColor: Color(hex: "7C3AED"),
                        title: "Walk to the Elevator",
                        subtitle: "Follow the blue path to the elevator on \(origin?.floor == 0 ? "Ground" : "Floor \(origin!.floor)") floor",
                        actionLabel: "I\'m at the Elevator ✓",
                        actionColor: Color(hex: "7C3AED")
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            reachedElevator = true
                            if let d = dest { currentFloor = d.floor }
                        }
                        hapticsManager.mediumTap()
                    }
                } else {
                    // STEP 2: Walk to destination on upper floor
                    stepCard(
                        icon: "mappin.and.ellipse",
                        iconColor: Color(hex: "16A34A"),
                        title: "Walk to \(dest?.name ?? "Destination")",
                        subtitle: "Follow the blue path from the elevator on \(dest?.floor == 0 ? "Ground" : "Floor \(dest!.floor)") floor",
                        actionLabel: nil,
                        actionColor: .clear,
                        onAction: nil
                    )
                }
            } else {
                // Single floor — simple instruction
                stepCard(
                    icon: "figure.walk",
                    iconColor: Color(hex: "007AFF"),
                    title: "Walk to \(dest?.name ?? "Destination")",
                    subtitle: "Follow the blue path on the map above",
                    actionLabel: nil,
                    actionColor: .clear,
                    onAction: nil
                )
            }

            // ── Floor switcher pills (cross-floor only) ───────────────
            if isCross, let o = origin, let d = dest {
                crossFloorPills(from: o, to: d)
                    .padding(.bottom, 12)
            } else {
                Spacer().frame(height: 14)
            }
        }
    }

    // Reusable step instruction card
    private func stepCard(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        actionLabel: String?,
        actionColor: Color,
        onAction: (() -> Void)?
    ) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            if let label = actionLabel, let action = onAction {
                Button(action: action) {
                    Text(label)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(actionColor))
                }
            }
        }
        .padding(14)
        .background(iconColor.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(iconColor.opacity(0.10), lineWidth: 1))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
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
