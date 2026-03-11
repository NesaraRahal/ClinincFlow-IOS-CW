import SwiftUI

// MARK: - Clinic Map Data
// Central data model for the indoor map. Every room, corridor, wall, and
// connection lives here so the floor-plan renderer, location picker, and
// route engine all share one source of truth.
//
// Coordinate system: normalised 0…1 within the building footprint.
// The renderer scales these to the actual pixel canvas.

// MARK: - MapRoom
struct MapRoom: Identifiable, Hashable {
    let id: String
    let name: String
    let shortName: String
    let icon: String
    let category: RoomCategory
    let floor: Int
    /// Normalised rect within the floor plan (0-1 coordinate space)
    let rect: CGRect
    /// Anchor point for the pin label (normalised 0-1)
    var center: CGPoint { CGPoint(x: rect.midX, y: rect.midY) }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: MapRoom, rhs: MapRoom) -> Bool { lhs.id == rhs.id }
}

// MARK: - Room Category
enum RoomCategory: String, CaseIterable, Identifiable {
    var id: String { rawValue }

    case entrance    = "Entrance"
    case reception   = "Reception"
    case waiting     = "Waiting"
    case pharmacy    = "Pharmacy"
    case opd         = "OPD"
    case vaccination = "Vaccination"
    case laboratory  = "Laboratory"
    case radiology   = "Radiology"
    case bloodBank   = "Blood Bank"
    case specialist  = "Specialist"
    case utility     = "Utility"

    var tint: Color {
        switch self {
        case .entrance:    return Color(hex: "8E8E93")
        case .reception:   return Color(hex: "007AFF")
        case .waiting:     return Color(hex: "FF9500")
        case .pharmacy:    return Color(hex: "34C759")
        case .opd:         return Color(hex: "007AFF")
        case .vaccination: return Color(hex: "5856D6")
        case .laboratory:  return Color(hex: "AF52DE")
        case .radiology:   return Color(hex: "FF9500")
        case .bloodBank:   return Color(hex: "FF2D55")
        case .specialist:  return Color(hex: "FF3B30")
        case .utility:     return Color(hex: "8E8E93")
        }
    }

    var fill: Color { tint.opacity(0.08) }

    /// Softer, pastel map fill for the architectural floor plan.
    var mapFill: Color {
        switch self {
        case .entrance:    return Color(hex: "E5E5EA").opacity(0.65)
        case .reception:   return Color(hex: "D6E4FF").opacity(0.72)
        case .waiting:     return Color(hex: "FFF0D6").opacity(0.72)
        case .pharmacy:    return Color(hex: "D4F5DD").opacity(0.72)
        case .opd:         return Color(hex: "D6E4FF").opacity(0.72)
        case .vaccination: return Color(hex: "E8E0FF").opacity(0.72)
        case .laboratory:  return Color(hex: "EFE0FF").opacity(0.72)
        case .radiology:   return Color(hex: "FFF0D6").opacity(0.72)
        case .bloodBank:   return Color(hex: "FFE0E6").opacity(0.72)
        case .specialist:  return Color(hex: "FFE0E0").opacity(0.72)
        case .utility:     return Color(hex: "F2F2F7").opacity(0.60)
        }
    }

    /// Wall color for rooms of this category.
    var wallColor: Color { tint.opacity(0.35) }
}

// MARK: - Corridor Segment
struct CorridorSegment: Identifiable {
    let id = UUID()
    let from: CGPoint
    let to: CGPoint
}

// MARK: - Wall Segment
struct WallSegment: Identifiable {
    let id = UUID()
    let from: CGPoint
    let to: CGPoint
}

// MARK: - Floor Data
struct FloorData {
    let floor: Int
    let label: String
    let rooms: [MapRoom]
    let corridors: [CorridorSegment]
    let walls: [WallSegment]

    init(floor: Int, label: String, rooms: [MapRoom], corridors: [CorridorSegment], walls: [WallSegment] = []) {
        self.floor = floor; self.label = label
        self.rooms = rooms; self.corridors = corridors; self.walls = walls
    }
}

// MARK: - ClinicMapStore
struct ClinicMapStore {
    static let floors: [FloorData] = [ground, first, second, third]

    static func data(for floor: Int) -> FloorData {
        floors.first { $0.floor == floor } ?? ground
    }

    static func room(id: String) -> MapRoom? {
        floors.flatMap(\.rooms).first { $0.id == id }
    }

    static func allRooms(on floor: Int) -> [MapRoom] {
        data(for: floor).rooms
    }

    static func roomID(forDepartment dept: String, roomNumber: String) -> String? {
        let prefix: String
        switch dept {
        case "OPD":               prefix = "O"
        case "Laboratory":        prefix = "L"
        case "Pharmacy":          prefix = "P"
        case "Radiology":         prefix = "R"; return "rad"
        case "Vaccination":       prefix = "V"
        case "Specialist Clinic": prefix = "S"
        default:                  prefix = ""
        }
        let padded = String(repeating: "0", count: max(0, 3 - roomNumber.count)) + roomNumber
        let candidate = "\(prefix)-\(padded)"
        if room(id: candidate) != nil { return candidate }
        return floors.flatMap(\.rooms).first { $0.id.hasPrefix("\(prefix)-") }?.id
    }

    static func elevator(on floor: Int) -> MapRoom? {
        data(for: floor).rooms.first { $0.category == .utility && $0.name == "Elevator" }
    }

    // ═══════════════════════════════════════════════
    // MARK: Corridor graph nodes (normalised 0-1)
    // Named intersection nodes used for A* pathfinding.
    // ═══════════════════════════════════════════════
    struct Node: Hashable {
        let id: String
        let pt: CGPoint
        func hash(into hasher: inout Hasher) { hasher.combine(id) }
        static func == (l: Node, r: Node) -> Bool { l.id == r.id }
    }

    /// Shared corridor network used by every floor.
    /// Rooms connect to their nearest node → A* finds the shortest path
    /// through these intersections → route is drawn on screen.
    static let corridorNodes: [Node] = [
        // ── Far-left column ──
        Node(id: "N-A1", pt: CGPoint(x: 0.08, y: 0.18)),
        Node(id: "N-A2", pt: CGPoint(x: 0.08, y: 0.50)),
        Node(id: "N-A3", pt: CGPoint(x: 0.08, y: 0.82)),
        // ── Left-centre column ──
        Node(id: "N-B1", pt: CGPoint(x: 0.28, y: 0.18)),
        Node(id: "N-B2", pt: CGPoint(x: 0.28, y: 0.50)),
        Node(id: "N-B3", pt: CGPoint(x: 0.28, y: 0.82)),
        // ── Centre column ──
        Node(id: "N-C1", pt: CGPoint(x: 0.50, y: 0.18)),
        Node(id: "N-C2", pt: CGPoint(x: 0.50, y: 0.50)),
        Node(id: "N-C3", pt: CGPoint(x: 0.50, y: 0.82)),
        // ── Right-centre column ──
        Node(id: "N-D1", pt: CGPoint(x: 0.72, y: 0.18)),
        Node(id: "N-D2", pt: CGPoint(x: 0.72, y: 0.50)),
        Node(id: "N-D3", pt: CGPoint(x: 0.72, y: 0.82)),
        // ── Far-right column ──
        Node(id: "N-E1", pt: CGPoint(x: 0.92, y: 0.18)),
        Node(id: "N-E2", pt: CGPoint(x: 0.92, y: 0.50)),
        Node(id: "N-E3", pt: CGPoint(x: 0.92, y: 0.82)),
    ]

    /// Edges connecting corridor nodes (bidirectional).
    static let corridorEdges: [(String, String)] = [
        // Row 1 (top horizontal)
        ("N-A1","N-B1"), ("N-B1","N-C1"), ("N-C1","N-D1"), ("N-D1","N-E1"),
        // Row 2 (middle horizontal)
        ("N-A2","N-B2"), ("N-B2","N-C2"), ("N-C2","N-D2"), ("N-D2","N-E2"),
        // Row 3 (bottom horizontal)
        ("N-A3","N-B3"), ("N-B3","N-C3"), ("N-C3","N-D3"), ("N-D3","N-E3"),
        // Column A (vertical)
        ("N-A1","N-A2"), ("N-A2","N-A3"),
        // Column B
        ("N-B1","N-B2"), ("N-B2","N-B3"),
        // Column C
        ("N-C1","N-C2"), ("N-C2","N-C3"),
        // Column D
        ("N-D1","N-D2"), ("N-D2","N-D3"),
        // Column E
        ("N-E1","N-E2"), ("N-E2","N-E3"),
    ]

    // ═══════════════════════════════════════════════
    // MARK: A* Pathfinding
    // ═══════════════════════════════════════════════

    /// Returns the shortest path of normalised CGPoints from `start` to `end`
    /// walking only along the corridor graph.
    static func findPath(from start: CGPoint, to end: CGPoint) -> [CGPoint] {
        // Build adjacency
        let nodeMap = Dictionary(uniqueKeysWithValues: corridorNodes.map { ($0.id, $0) })
        var adj: [String: [(String, CGFloat)]] = [:]
        for edge in corridorEdges {
            guard let a = nodeMap[edge.0], let b = nodeMap[edge.1] else { continue }
            let d = hypot(a.pt.x - b.pt.x, a.pt.y - b.pt.y)
            adj[edge.0, default: []].append((edge.1, d))
            adj[edge.1, default: []].append((edge.0, d))
        }

        // Find nearest node to start and end
        func nearest(_ p: CGPoint) -> Node {
            corridorNodes.min(by: { hypot($0.pt.x - p.x, $0.pt.y - p.y) < hypot($1.pt.x - p.x, $1.pt.y - p.y) })!
        }
        let startNode = nearest(start)
        let endNode = nearest(end)

        guard startNode.id != endNode.id else {
            return [start, startNode.pt, end]
        }

        // A* search
        struct Entry: Comparable {
            let cost: CGFloat; let node: String; let path: [String]
            static func < (a: Entry, b: Entry) -> Bool { a.cost < b.cost }
        }

        var visited = Set<String>()
        var heap = [Entry(cost: 0, node: startNode.id, path: [startNode.id])]

        while !heap.isEmpty {
            heap.sort(by: >)  // simple min-heap via sort
            let cur = heap.removeLast()
            if cur.node == endNode.id {
                var pts: [CGPoint] = [start]
                for nid in cur.path {
                    if let n = nodeMap[nid] { pts.append(n.pt) }
                }
                pts.append(end)
                return pts
            }
            if visited.contains(cur.node) { continue }
            visited.insert(cur.node)
            for (next, edgeCost) in adj[cur.node] ?? [] where !visited.contains(next) {
                let g = cur.cost + edgeCost
                let h: CGFloat = {
                    guard let n = nodeMap[next] else { return 0 }
                    return hypot(n.pt.x - endNode.pt.x, n.pt.y - endNode.pt.y)
                }()
                heap.append(Entry(cost: g + h, node: next, path: cur.path + [next]))
            }
        }

        // Fallback: straight line
        return [start, startNode.pt, endNode.pt, end]
    }

    // ══════════════════════════════════════════════════════════════
    // MARK: Ground Floor — Entrance, Reception, Waiting, Pharmacy
    // Rooms spread across full map: entrance far-right, pharmacy
    // upper-left, waiting centre, elevator bottom-left
    // ══════════════════════════════════════════════════════════════
    static let ground = FloorData(
        floor: 0, label: "Ground",
        rooms: [
            //            id            name                     short          icon                            cat          fl    ── position on map ──
            MapRoom(id: "entrance",  name: "Main Entrance",   shortName: "Entrance",   icon: "door.left.hand.open",   category: .entrance,  floor: 0, rect: CGRect(x: 0.82, y: 0.40, width: 0.12, height: 0.12)),
            MapRoom(id: "reception", name: "Reception",       shortName: "Reception",  icon: "person.crop.rectangle", category: .reception, floor: 0, rect: CGRect(x: 0.62, y: 0.40, width: 0.12, height: 0.12)),
            MapRoom(id: "wait-G",    name: "Waiting Area",    shortName: "Waiting",    icon: "person.2.fill",         category: .waiting,   floor: 0, rect: CGRect(x: 0.41, y: 0.40, width: 0.13, height: 0.12)),
            MapRoom(id: "P-001",     name: "Pharmacy 001",    shortName: "Pharm-1",    icon: "cross.case.fill",       category: .pharmacy,  floor: 0, rect: CGRect(x: 0.04, y: 0.06, width: 0.14, height: 0.16)),
            MapRoom(id: "P-002",     name: "Pharmacy 002",    shortName: "Pharm-2",    icon: "cross.case.fill",       category: .pharmacy,  floor: 0, rect: CGRect(x: 0.22, y: 0.06, width: 0.14, height: 0.16)),
            MapRoom(id: "P-003",     name: "Pharmacy 003",    shortName: "Pharm-3",    icon: "pills.fill",            category: .pharmacy,  floor: 0, rect: CGRect(x: 0.40, y: 0.06, width: 0.14, height: 0.16)),
            MapRoom(id: "elev-G",    name: "Elevator",        shortName: "Elevator",   icon: "arrow.up.arrow.down.square.fill", category: .utility, floor: 0, rect: CGRect(x: 0.04, y: 0.72, width: 0.10, height: 0.14)),
            MapRoom(id: "stairs-G",  name: "Stairs",          shortName: "Stairs",     icon: "figure.stairs",         category: .utility,   floor: 0, rect: CGRect(x: 0.82, y: 0.72, width: 0.10, height: 0.14)),
        ],
        corridors: [
            // Horizontal rows
            CorridorSegment(from: CGPoint(x: 0.08, y: 0.18), to: CGPoint(x: 0.92, y: 0.18)),
            CorridorSegment(from: CGPoint(x: 0.08, y: 0.50), to: CGPoint(x: 0.92, y: 0.50)),
            CorridorSegment(from: CGPoint(x: 0.08, y: 0.82), to: CGPoint(x: 0.92, y: 0.82)),
            // Vertical columns
            CorridorSegment(from: CGPoint(x: 0.08, y: 0.18), to: CGPoint(x: 0.08, y: 0.82)),
            CorridorSegment(from: CGPoint(x: 0.50, y: 0.18), to: CGPoint(x: 0.50, y: 0.82)),
            CorridorSegment(from: CGPoint(x: 0.92, y: 0.18), to: CGPoint(x: 0.92, y: 0.82)),
        ],
        walls: []
    )

    // ══════════════════════════════════════════════════════════════
    // MARK: 1st Floor — OPD Clinics + Vaccination
    // OPD rooms spread left-to-right top row + bottom row,
    // Vaccination rooms along the right side
    // ══════════════════════════════════════════════════════════════
    static let first = FloorData(
        floor: 1, label: "1st",
        rooms: [
            MapRoom(id: "wait-1",   name: "Waiting Area",      shortName: "Waiting",    icon: "person.2.fill",   category: .waiting,     floor: 1, rect: CGRect(x: 0.41, y: 0.40, width: 0.13, height: 0.12)),
            // ── OPD top row ──
            MapRoom(id: "O-101",    name: "OPD Room 101",      shortName: "OPD-101",    icon: "stethoscope",     category: .opd,         floor: 1, rect: CGRect(x: 0.04, y: 0.06, width: 0.14, height: 0.16)),
            MapRoom(id: "O-102",    name: "OPD Room 102",      shortName: "OPD-102",    icon: "stethoscope",     category: .opd,         floor: 1, rect: CGRect(x: 0.22, y: 0.06, width: 0.14, height: 0.16)),
            MapRoom(id: "O-103",    name: "OPD Room 103",      shortName: "OPD-103",    icon: "stethoscope",     category: .opd,         floor: 1, rect: CGRect(x: 0.40, y: 0.06, width: 0.14, height: 0.16)),
            // ── OPD bottom row ──
            MapRoom(id: "O-104",    name: "OPD Room 104",      shortName: "OPD-104",    icon: "stethoscope",     category: .opd,         floor: 1, rect: CGRect(x: 0.04, y: 0.60, width: 0.14, height: 0.16)),
            MapRoom(id: "O-105",    name: "OPD Room 105",      shortName: "OPD-105",    icon: "stethoscope",     category: .opd,         floor: 1, rect: CGRect(x: 0.22, y: 0.60, width: 0.14, height: 0.16)),
            MapRoom(id: "O-106",    name: "OPD Room 106",      shortName: "OPD-106",    icon: "stethoscope",     category: .opd,         floor: 1, rect: CGRect(x: 0.40, y: 0.60, width: 0.14, height: 0.16)),
            // ── Vaccination right side ──
            MapRoom(id: "V-101",    name: "Vaccination 101",   shortName: "Vacc-101",   icon: "syringe.fill",    category: .vaccination, floor: 1, rect: CGRect(x: 0.62, y: 0.06, width: 0.14, height: 0.16)),
            MapRoom(id: "V-102",    name: "Vaccination 102",   shortName: "Vacc-102",   icon: "syringe.fill",    category: .vaccination, floor: 1, rect: CGRect(x: 0.80, y: 0.06, width: 0.14, height: 0.16)),
            MapRoom(id: "V-103",    name: "Vaccination 103",   shortName: "Vacc-103",   icon: "syringe.fill",    category: .vaccination, floor: 1, rect: CGRect(x: 0.62, y: 0.60, width: 0.14, height: 0.16)),
            MapRoom(id: "V-104",    name: "Vaccination 104",   shortName: "Vacc-104",   icon: "syringe.fill",    category: .vaccination, floor: 1, rect: CGRect(x: 0.80, y: 0.60, width: 0.14, height: 0.16)),
            // ── Utility ──
            MapRoom(id: "elev-1",   name: "Elevator",          shortName: "Elevator",   icon: "arrow.up.arrow.down.square.fill", category: .utility, floor: 1, rect: CGRect(x: 0.04, y: 0.40, width: 0.10, height: 0.12)),
            MapRoom(id: "stairs-1", name: "Stairs",            shortName: "Stairs",     icon: "figure.stairs",   category: .utility,     floor: 1, rect: CGRect(x: 0.84, y: 0.40, width: 0.10, height: 0.12)),
        ],
        corridors: [
            CorridorSegment(from: CGPoint(x: 0.08, y: 0.18), to: CGPoint(x: 0.92, y: 0.18)),
            CorridorSegment(from: CGPoint(x: 0.08, y: 0.50), to: CGPoint(x: 0.92, y: 0.50)),
            CorridorSegment(from: CGPoint(x: 0.08, y: 0.82), to: CGPoint(x: 0.92, y: 0.82)),
            CorridorSegment(from: CGPoint(x: 0.08, y: 0.18), to: CGPoint(x: 0.08, y: 0.82)),
            CorridorSegment(from: CGPoint(x: 0.50, y: 0.18), to: CGPoint(x: 0.50, y: 0.82)),
            CorridorSegment(from: CGPoint(x: 0.92, y: 0.18), to: CGPoint(x: 0.92, y: 0.82)),
        ],
        walls: []
    )

    // ══════════════════════════════════════════════════════════════
    // MARK: 2nd Floor — Laboratory + Radiology + Blood Bank
    // Labs along left/top, Radiology bottom-right, Blood Bank right
    // ══════════════════════════════════════════════════════════════
    static let second = FloorData(
        floor: 2, label: "2nd",
        rooms: [
            MapRoom(id: "wait-2",   name: "Waiting Area",     shortName: "Waiting",     icon: "person.2.fill",       category: .waiting,    floor: 2, rect: CGRect(x: 0.41, y: 0.40, width: 0.13, height: 0.12)),
            // ── Labs top row ──
            MapRoom(id: "L-201",    name: "Lab Room 201",     shortName: "Lab-201",     icon: "flask.fill",          category: .laboratory, floor: 2, rect: CGRect(x: 0.04, y: 0.06, width: 0.14, height: 0.16)),
            MapRoom(id: "L-202",    name: "Lab Room 202",     shortName: "Lab-202",     icon: "flask.fill",          category: .laboratory, floor: 2, rect: CGRect(x: 0.22, y: 0.06, width: 0.14, height: 0.16)),
            MapRoom(id: "L-203",    name: "Lab Room 203",     shortName: "Lab-203",     icon: "testtube.2",          category: .laboratory, floor: 2, rect: CGRect(x: 0.40, y: 0.06, width: 0.14, height: 0.16)),
            // ── Labs bottom row ──
            MapRoom(id: "L-204",    name: "Lab Room 204",     shortName: "Lab-204",     icon: "testtube.2",          category: .laboratory, floor: 2, rect: CGRect(x: 0.04, y: 0.60, width: 0.14, height: 0.16)),
            MapRoom(id: "L-205",    name: "Lab Room 205",     shortName: "Lab-205",     icon: "flask.fill",          category: .laboratory, floor: 2, rect: CGRect(x: 0.22, y: 0.60, width: 0.14, height: 0.16)),
            MapRoom(id: "L-206",    name: "Lab Room 206",     shortName: "Lab-206",     icon: "flask.fill",          category: .laboratory, floor: 2, rect: CGRect(x: 0.40, y: 0.60, width: 0.14, height: 0.16)),
            // ── Radiology right side ──
            MapRoom(id: "rad",      name: "Radiology",        shortName: "Radiology",   icon: "waveform.path.ecg",   category: .radiology,  floor: 2, rect: CGRect(x: 0.62, y: 0.60, width: 0.14, height: 0.16)),
            // ── Blood Bank upper-right ──
            MapRoom(id: "blood",    name: "Blood Bank",       shortName: "Blood Bank",  icon: "drop.fill",           category: .bloodBank,  floor: 2, rect: CGRect(x: 0.62, y: 0.06, width: 0.14, height: 0.16)),
            MapRoom(id: "collect",  name: "Collection Room",  shortName: "Collection",  icon: "syringe.fill",        category: .bloodBank,  floor: 2, rect: CGRect(x: 0.80, y: 0.06, width: 0.14, height: 0.16)),
            // ── Utility ──
            MapRoom(id: "elev-2",   name: "Elevator",         shortName: "Elevator",    icon: "arrow.up.arrow.down.square.fill", category: .utility, floor: 2, rect: CGRect(x: 0.80, y: 0.40, width: 0.10, height: 0.12)),
            MapRoom(id: "stairs-2", name: "Stairs",           shortName: "Stairs",      icon: "figure.stairs",       category: .utility,    floor: 2, rect: CGRect(x: 0.80, y: 0.60, width: 0.10, height: 0.16)),
        ],
        corridors: [
            CorridorSegment(from: CGPoint(x: 0.08, y: 0.18), to: CGPoint(x: 0.92, y: 0.18)),
            CorridorSegment(from: CGPoint(x: 0.08, y: 0.50), to: CGPoint(x: 0.92, y: 0.50)),
            CorridorSegment(from: CGPoint(x: 0.08, y: 0.82), to: CGPoint(x: 0.92, y: 0.82)),
            CorridorSegment(from: CGPoint(x: 0.08, y: 0.18), to: CGPoint(x: 0.08, y: 0.82)),
            CorridorSegment(from: CGPoint(x: 0.50, y: 0.18), to: CGPoint(x: 0.50, y: 0.82)),
            CorridorSegment(from: CGPoint(x: 0.92, y: 0.18), to: CGPoint(x: 0.92, y: 0.82)),
        ],
        walls: []
    )

    // ══════════════════════════════════════════════════════════════
    // MARK: 3rd Floor — Specialist Clinics
    // 8 specialist rooms spread evenly across the full map
    // ══════════════════════════════════════════════════════════════
    static let third = FloorData(
        floor: 3, label: "3rd",
        rooms: [
            MapRoom(id: "wait-3",   name: "Waiting Area",             shortName: "Waiting",      icon: "person.2.fill",           category: .waiting,    floor: 3, rect: CGRect(x: 0.41, y: 0.40, width: 0.13, height: 0.12)),
            // ── Top row: 4 clinics ──
            MapRoom(id: "S-301",    name: "Cardiology 301",           shortName: "Cardiology",   icon: "heart.fill",              category: .specialist, floor: 3, rect: CGRect(x: 0.04, y: 0.06, width: 0.14, height: 0.16)),
            MapRoom(id: "S-302",    name: "Neurology 302",            shortName: "Neurology",    icon: "brain.head.profile",      category: .specialist, floor: 3, rect: CGRect(x: 0.22, y: 0.06, width: 0.14, height: 0.16)),
            MapRoom(id: "S-303",    name: "Dermatology 303",          shortName: "Dermatology",  icon: "hand.raised.fill",        category: .specialist, floor: 3, rect: CGRect(x: 0.62, y: 0.06, width: 0.14, height: 0.16)),
            MapRoom(id: "S-304",    name: "ENT 304",                  shortName: "ENT",          icon: "ear.fill",                category: .specialist, floor: 3, rect: CGRect(x: 0.80, y: 0.06, width: 0.14, height: 0.16)),
            // ── Bottom row: 4 clinics ──
            MapRoom(id: "S-305",    name: "Orthopedics 305",          shortName: "Orthopedics",  icon: "figure.walk",             category: .specialist, floor: 3, rect: CGRect(x: 0.04, y: 0.60, width: 0.14, height: 0.16)),
            MapRoom(id: "S-306",    name: "Gynecology 306",           shortName: "Gynecology",   icon: "staroflife.fill",         category: .specialist, floor: 3, rect: CGRect(x: 0.22, y: 0.60, width: 0.14, height: 0.16)),
            MapRoom(id: "S-307",    name: "Pediatrics 307",           shortName: "Pediatrics",   icon: "figure.and.child.holdinghands", category: .specialist, floor: 3, rect: CGRect(x: 0.62, y: 0.60, width: 0.14, height: 0.16)),
            MapRoom(id: "S-308",    name: "Ophthalmology 308",        shortName: "Eye Clinic",   icon: "eye.fill",                category: .specialist, floor: 3, rect: CGRect(x: 0.80, y: 0.60, width: 0.14, height: 0.16)),
            // ── Utility ──
            MapRoom(id: "elev-3",   name: "Elevator",                 shortName: "Elevator",     icon: "arrow.up.arrow.down.square.fill", category: .utility, floor: 3, rect: CGRect(x: 0.40, y: 0.06, width: 0.10, height: 0.16)),
            MapRoom(id: "stairs-3", name: "Stairs",                   shortName: "Stairs",       icon: "figure.stairs",           category: .utility,    floor: 3, rect: CGRect(x: 0.40, y: 0.60, width: 0.10, height: 0.16)),
        ],
        corridors: [
            CorridorSegment(from: CGPoint(x: 0.08, y: 0.18), to: CGPoint(x: 0.92, y: 0.18)),
            CorridorSegment(from: CGPoint(x: 0.08, y: 0.50), to: CGPoint(x: 0.92, y: 0.50)),
            CorridorSegment(from: CGPoint(x: 0.08, y: 0.82), to: CGPoint(x: 0.92, y: 0.82)),
            CorridorSegment(from: CGPoint(x: 0.08, y: 0.18), to: CGPoint(x: 0.08, y: 0.82)),
            CorridorSegment(from: CGPoint(x: 0.50, y: 0.18), to: CGPoint(x: 0.50, y: 0.82)),
            CorridorSegment(from: CGPoint(x: 0.92, y: 0.18), to: CGPoint(x: 0.92, y: 0.82)),
        ],
        walls: []
    )
}
