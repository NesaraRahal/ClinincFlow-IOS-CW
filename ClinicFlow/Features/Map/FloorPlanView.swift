import SwiftUI

// MARK: - Indoor Floor Plan View
// Displays a professional raster floor-plan image with an interactive overlay.
// Supports pinch-to-zoom, drag-to-pan, room tapping, and a Google-Maps–style
// corridor-highlighted navigation route.

struct FloorPlanView: View {
    let floorData: FloorData
    let originID: String?
    let destinationID: String?
    let isNavigating: Bool
    var onRoomTapped: ((MapRoom) -> Void)? = nil

    // MARK: Gesture state
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @GestureState private var magnifyBy: CGFloat = 1.0

    /// Single clinic floor plan image used for all floors.
    private let imageName = "clinic_floor_plan"

    var body: some View {
        GeometryReader { geo in
            let size = planSize(in: geo.size)

            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()

                planCanvas(size: size)
                    .frame(width: size.width, height: size.height)
                    .scaleEffect(scale * magnifyBy)
                    .offset(offset)
                    .gesture(dragGesture)
                    .gesture(pinchGesture)
                    .onTapGesture(count: 2) { resetView() }
            }
        }
    }

    // MARK: - Canvas
    @ViewBuilder
    private func planCanvas(size: CGSize) -> some View {
        ZStack {
            // Floor plan image
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.width, height: size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
            } else {
                // Fallback: draw a simple outline if image not found
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "F0F3F8"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(.systemGray4), lineWidth: 1.5)
                    )
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "map")
                                .font(.system(size: 32))
                                .foregroundColor(.secondary)
                            Text("Floor \(floorData.label)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    )
                    .frame(width: size.width, height: size.height)
            }

            // Tappable room hotspots + visible POI labels
            roomHotspots(in: size)

            // Visible POI pin markers
            poiLabels(in: size)

            // Navigation route overlay
            if isNavigating {
                routeLayer(in: size)
            }
        }
    }

    // MARK: - Room Hotspots
    private func roomHotspots(in size: CGSize) -> some View {
        let isCrossFloor = isCrossFloorRoute
        let elevID = ClinicMapStore.elevator(on: floorData.floor)?.id

        return ZStack {
            ForEach(floorData.rooms) { room in
                let frame = roomFrame(room, in: size)
                let isOrigin = room.id == originID
                let isDest   = room.id == destinationID
                let isElevWaypoint = isCrossFloor && isNavigating && room.id == elevID

                // Highlight border for origin / destination / elevator waypoint
                if isOrigin || isDest || isElevWaypoint {
                    RoomHighlight(
                        isOrigin: isOrigin,
                        isDestination: isDest || isElevWaypoint
                    )
                    .frame(width: frame.width, height: frame.height)
                    .position(x: frame.midX, y: frame.midY)
                }

                // Invisible tap target
                Color.clear
                    .contentShape(Rectangle())
                    .frame(width: frame.width, height: frame.height)
                    .position(x: frame.midX, y: frame.midY)
                    .onTapGesture {
                        onRoomTapped?(room)
                    }
            }
        }
    }

    private var isCrossFloorRoute: Bool {
        guard let oID = originID, let dID = destinationID,
              let o = ClinicMapStore.room(id: oID),
              let d = ClinicMapStore.room(id: dID) else { return false }
        return o.floor != d.floor
    }

    // MARK: - POI Labels (visible room markers on the map)
    private func poiLabels(in size: CGSize) -> some View {
        ZStack {
            ForEach(floorData.rooms) { room in
                let pt = CGPoint(x: room.center.x * size.width, y: room.center.y * size.height)
                let isOrigin = room.id == originID
                let isDest = room.id == destinationID

                POILabel(room: room, isOrigin: isOrigin, isDestination: isDest)
                    .position(pt)
                    .allowsHitTesting(false)
            }
        }
    }

    // MARK: - Route Layer
    private func routeLayer(in size: CGSize) -> some View {
        RouteOverlay(
            floorData: floorData,
            originID: originID ?? "",
            destinationID: destinationID ?? "",
            size: size
        )
        .allowsHitTesting(false)
    }

    // MARK: - Helpers
    private func planSize(in container: CGSize) -> CGSize {
        let w = container.width - 16
        return CGSize(width: w, height: w * 0.665) // match clinic_floor_plan aspect ratio (900:598)
    }

    private func roomFrame(_ room: MapRoom, in size: CGSize) -> CGRect {
        CGRect(
            x: room.rect.origin.x * size.width,
            y: room.rect.origin.y * size.height,
            width: room.rect.width * size.width,
            height: room.rect.height * size.height
        )
    }

    private func resetView() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            scale = 1.0; lastScale = 1.0
            offset = .zero; lastOffset = .zero
        }
    }

    // MARK: Gestures
    private var pinchGesture: some Gesture {
        MagnificationGesture()
            .updating($magnifyBy) { value, state, _ in state = value }
            .onEnded { value in scale = min(max(scale * value, 1.0), 5.0) }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in lastOffset = offset }
    }
}


// MARK: ─────────────────────────────────────────────
// MARK: Room Highlight  (border glow on origin / dest)
// MARK: ─────────────────────────────────────────────
struct RoomHighlight: View {
    let isOrigin: Bool
    let isDestination: Bool

    var body: some View {
        let color = isOrigin ? Color(hex: "4285F4") : Color(hex: "EA4335")
        RoundedRectangle(cornerRadius: 12)
            .stroke(color, lineWidth: 3)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.08))
            )
            .shadow(color: color.opacity(0.35), radius: 6, y: 0)
    }
}


// MARK: ─────────────────────────────────────────────
// MARK: POI Label  (visible room marker on the map)
// MARK: ─────────────────────────────────────────────
struct POILabel: View {
    let room: MapRoom
    let isOrigin: Bool
    let isDestination: Bool

    private var accentColor: Color {
        if isOrigin { return Color(hex: "4285F4") }
        if isDestination { return Color(hex: "EA4335") }
        return room.category.tint
    }

    var body: some View {
        VStack(spacing: 2) {
            // Icon bubble
            ZStack {
                Circle()
                    .fill(accentColor)
                    .frame(width: 22, height: 22)
                    .shadow(color: accentColor.opacity(0.4), radius: 3, y: 1)
                Image(systemName: room.icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
            }

            // Name tag
            Text(room.shortName)
                .font(.system(size: 7, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
                )
                .lineLimit(1)
                .fixedSize()
        }
    }
}


// MARK: ─────────────────────────────────────────────
// MARK: Route Overlay  (Google Maps–style highlighted path)
// Uses A* pathfinding through the corridor graph for realistic
// corridor-following routes, then renders a layered blue path
// with glow, border, fill, inner highlight, and animated chevrons.
// MARK: ─────────────────────────────────────────────
struct RouteOverlay: View {
    let floorData: FloorData
    let originID: String
    let destinationID: String
    let size: CGSize

    @State private var trimEnd: CGFloat = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var chevronPhase: CGFloat = 0

    private var allRooms: [MapRoom] { ClinicMapStore.floors.flatMap(\.rooms) }
    private var origin: MapRoom? { allRooms.first { $0.id == originID } }
    private var destination: MapRoom? { allRooms.first { $0.id == destinationID } }

    private var originOnFloor: Bool { origin?.floor == floorData.floor }
    private var destOnFloor: Bool { destination?.floor == floorData.floor }
    private var isCrossFloor: Bool { origin?.floor != destination?.floor }
    private var elevator: MapRoom? { ClinicMapStore.elevator(on: floorData.floor) }

    // Apple Maps-inspired route colours
    private let routeBlue   = Color(hex: "007AFF")
    private let routeBorder = Color(hex: "004ECC")
    private let routeGlow   = Color(hex: "007AFF")

    var body: some View {
        if let o = origin, let d = destination {
            let waypoints = buildWaypoints(from: o, to: d)
            let routePath = smoothPath(from: waypoints)

            ZStack {
                // ── Highlighted corridor segments used by route ──
                highlightedCorridors(waypoints: waypoints)

                // ── Route path layers (Google Maps style) ──
                // 1. Outer glow
                routePath
                    .trim(from: 0, to: trimEnd)
                    .stroke(routeGlow.opacity(0.18), lineWidth: 24)
                    .blur(radius: 6)

                // 2. Dark border
                routePath
                    .trim(from: 0, to: trimEnd)
                    .stroke(routeBorder, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))

                // 3. Main blue fill
                routePath
                    .trim(from: 0, to: trimEnd)
                    .stroke(routeBlue, style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round))

                // 4. Inner light highlight
                routePath
                    .trim(from: 0, to: trimEnd)
                    .stroke(Color.white.opacity(0.30), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                // 5. Animated walking chevrons
                if trimEnd >= 1.0 {
                    DirectionChevrons(waypoints: waypoints, phase: chevronPhase)
                }

                // ── Origin dot (start of this floor's segment) ──
                if let startPt = waypoints.first, (originOnFloor || (destOnFloor && isCrossFloor)) {
                    OriginDot(color: routeBlue, pulseScale: pulseScale)
                        .position(startPt)
                }

                // ── Destination pin (end of this floor's segment) ──
                if destOnFloor, let endPt = waypoints.last {
                    DestinationPin()
                        .position(x: endPt.x, y: endPt.y - 14)
                        .opacity(trimEnd > 0.85 ? 1 : 0)
                }

                // ── Elevator badge (shows on the elevator end of each segment) ──
                if isCrossFloor, let elev = elevator {
                    let elevPt = roomPt(elev)
                    ElevatorBadge()
                        .position(originOnFloor ? elevPt : elevPt)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) { trimEnd = 1.0 }
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                    pulseScale = 1.35
                }
                withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                    chevronPhase = 1.0
                }
            }
        }
    }

    // MARK: - Highlighted Corridor Segments
    @ViewBuilder
    private func highlightedCorridors(waypoints: [CGPoint]) -> some View {
        Canvas { ctx, _ in
            for seg in floorData.corridors {
                let from = CGPoint(x: seg.from.x * size.width, y: seg.from.y * size.height)
                let to = CGPoint(x: seg.to.x * size.width, y: seg.to.y * size.height)

                if routeUsesCorridor(from: from, to: to, waypoints: waypoints) {
                    var path = Path()
                    path.move(to: from)
                    path.addLine(to: to)

                    ctx.stroke(path, with: .color(Color(hex: "007AFF").opacity(0.14)),
                               style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    ctx.stroke(path, with: .color(Color(hex: "007AFF").opacity(0.08)),
                               style: StrokeStyle(lineWidth: 12, lineCap: .round))
                }
            }
        }
        .allowsHitTesting(false)
        .opacity(trimEnd > 0 ? 1 : 0)
    }

    private func routeUsesCorridor(from: CGPoint, to: CGPoint, waypoints: [CGPoint]) -> Bool {
        let threshold: CGFloat = 18
        for i in 0..<max(0, waypoints.count - 1) {
            let a = waypoints[i], b = waypoints[i + 1]
            let distA = ptSegDist(a, from, to)
            let distB = ptSegDist(b, from, to)
            if distA < threshold && distB < threshold { return true }
            let distF = ptSegDist(from, a, b)
            let distT = ptSegDist(to, a, b)
            if distF < threshold && distT < threshold { return true }
        }
        return false
    }

    private func ptSegDist(_ p: CGPoint, _ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = b.x - a.x, dy = b.y - a.y
        let lenSq = dx*dx + dy*dy
        guard lenSq > 0 else { return hypot(p.x - a.x, p.y - a.y) }
        let t = max(0, min(1, ((p.x - a.x)*dx + (p.y - a.y)*dy) / lenSq))
        return hypot(p.x - (a.x + t*dx), p.y - (a.y + t*dy))
    }

    // MARK: - Waypoint Construction (A* based)
    private func roomPt(_ room: MapRoom) -> CGPoint {
        if room.floor == floorData.floor {
            return CGPoint(x: room.rect.midX * size.width, y: room.rect.midY * size.height)
        }
        if let elev = elevator {
            return CGPoint(x: elev.rect.midX * size.width, y: elev.rect.midY * size.height)
        }
        return CGPoint(x: size.width * 0.5, y: size.height * 0.5)
    }

    /// Builds an A*-routed polyline appropriate for the current floor.
    /// - Same floor: origin → destination
    /// - Cross-floor, origin side: origin → elevator
    /// - Cross-floor, destination side: elevator → destination
    private func buildWaypoints(from o: MapRoom, to d: MapRoom) -> [CGPoint] {
        let startNorm: CGPoint
        let endNorm: CGPoint

        if o.floor == d.floor {
            // Same floor: direct route
            startNorm = CGPoint(x: o.rect.midX, y: o.rect.midY)
            endNorm   = CGPoint(x: d.rect.midX, y: d.rect.midY)
        } else if originOnFloor, let elev = elevator {
            // On origin floor → route from origin to elevator
            startNorm = CGPoint(x: o.rect.midX, y: o.rect.midY)
            endNorm   = CGPoint(x: elev.rect.midX, y: elev.rect.midY)
        } else if destOnFloor, let elev = elevator {
            // On destination floor → route from elevator to destination
            startNorm = CGPoint(x: elev.rect.midX, y: elev.rect.midY)
            endNorm   = CGPoint(x: d.rect.midX, y: d.rect.midY)
        } else {
            return [] // not on a relevant floor — no route to show
        }

        let normPath = ClinicMapStore.findPath(from: startNorm, to: endNorm)
        return normPath.map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) }
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat { hypot(a.x - b.x, a.y - b.y) }

    /// Smooth path with rounded corners at turns.
    private func smoothPath(from points: [CGPoint]) -> Path {
        guard points.count >= 2 else { return Path() }
        let r: CGFloat = 12
        return Path { p in
            p.move(to: points[0])
            for i in 1..<points.count {
                let prev = points[max(0, i - 1)]
                let curr = points[i]

                if i < points.count - 1 {
                    let dx1 = curr.x - prev.x, dy1 = curr.y - prev.y
                    let len1 = hypot(dx1, dy1)
                    if len1 > r * 2.5 {
                        let before = CGPoint(x: curr.x - (dx1/len1)*r, y: curr.y - (dy1/len1)*r)
                        p.addLine(to: before)
                        let next = points[i + 1]
                        let dx2 = next.x - curr.x, dy2 = next.y - curr.y
                        let len2 = hypot(dx2, dy2)
                        if len2 > r * 2.5 {
                            let after = CGPoint(x: curr.x + (dx2/len2)*r, y: curr.y + (dy2/len2)*r)
                            p.addQuadCurve(to: after, control: curr)
                        } else { p.addLine(to: curr) }
                    } else { p.addLine(to: curr) }
                } else { p.addLine(to: curr) }
            }
        }
    }
}


// MARK: ─────────────────────────────────────────────
// MARK: Origin Dot
// MARK: ─────────────────────────────────────────────
struct OriginDot: View {
    let color: Color
    let pulseScale: CGFloat

    var body: some View {
        ZStack {
            Circle().fill(color.opacity(0.12)).frame(width: 32, height: 32).scaleEffect(pulseScale)
            Circle().fill(.white).frame(width: 20, height: 20).shadow(color: .black.opacity(0.12), radius: 3, y: 1)
            Circle().fill(color).frame(width: 14, height: 14)
        }
    }
}


// MARK: ─────────────────────────────────────────────
// MARK: Destination Pin
// MARK: ─────────────────────────────────────────────
struct DestinationPin: View {
    private let red = Color(hex: "EA4335")

    var body: some View {
        ZStack {
            Ellipse().fill(.black.opacity(0.10)).frame(width: 14, height: 5).offset(y: 24).blur(radius: 2)
            VStack(spacing: 0) {
                ZStack {
                    Circle().fill(red).frame(width: 26, height: 26).shadow(color: red.opacity(0.4), radius: 5, y: 2)
                    Circle().fill(.white).frame(width: 10, height: 10)
                }
                PinTail().fill(red).frame(width: 12, height: 8).offset(y: -2)
            }
        }
    }
}

struct PinTail: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            p.closeSubpath()
        }
    }
}


// MARK: ─────────────────────────────────────────────
// MARK: Elevator Badge
// MARK: ─────────────────────────────────────────────
struct ElevatorBadge: View {
    private let purple = Color(hex: "7C3AED")

    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                RoundedRectangle(cornerRadius: 9).fill(purple).frame(width: 34, height: 34)
                    .shadow(color: purple.opacity(0.4), radius: 5, y: 2)
                Image(systemName: "arrow.up.arrow.down").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
            }
            Text("Change floor")
                .font(.system(size: 7, weight: .bold)).foregroundColor(purple)
                .padding(.horizontal, 5).padding(.vertical, 2)
                .background(Capsule().fill(.white.opacity(0.92)).shadow(color: .black.opacity(0.06), radius: 2, y: 1))
        }
    }
}


// MARK: ─────────────────────────────────────────────
// MARK: Direction Chevrons
// MARK: ─────────────────────────────────────────────
struct DirectionChevrons: View {
    let waypoints: [CGPoint]
    let phase: CGFloat

    var body: some View {
        Canvas { ctx, _ in
            let positions = chevronPositions(spacing: 28)
            for pos in positions {
                ctx.drawLayer { inner in
                    inner.translateBy(x: pos.point.x, y: pos.point.y)
                    inner.rotate(by: .degrees(pos.angle))
                    var chev = Path()
                    chev.move(to: CGPoint(x: -3, y: -4))
                    chev.addLine(to: CGPoint(x: 2, y: 0))
                    chev.addLine(to: CGPoint(x: -3, y: 4))
                    inner.stroke(chev, with: .color(.white.opacity(0.85)),
                                 style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func chevronPositions(spacing: CGFloat) -> [(point: CGPoint, angle: Double)] {
        guard waypoints.count >= 2 else { return [] }
        var cumLen: [CGFloat] = [0]
        for i in 1..<waypoints.count {
            cumLen.append(cumLen.last! + hypot(waypoints[i].x - waypoints[i-1].x, waypoints[i].y - waypoints[i-1].y))
        }
        let total = cumLen.last!
        guard total > spacing * 2 else { return [] }
        let off = phase * spacing
        var result: [(CGPoint, Double)] = []
        var dist = spacing * 0.5 + off
        while dist < total - spacing * 0.3 {
            var idx = 1
            for i in 1..<cumLen.count { if cumLen[i] >= dist { idx = i; break } }
            let s = waypoints[idx - 1], e = waypoints[idx]
            let sL = cumLen[idx] - cumLen[idx - 1]
            guard sL > 0 else { dist += spacing; continue }
            let t = (dist - cumLen[idx - 1]) / sL
            let pt = CGPoint(x: s.x + (e.x - s.x) * t, y: s.y + (e.y - s.y) * t)
            let angle = atan2(e.y - s.y, e.x - s.x) * 180 / .pi
            result.append((pt, angle))
            dist += spacing
        }
        return result
    }
}
