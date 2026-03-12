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

// MARK: - Floor Data
struct FloorData {
    let floor: Int
    let label: String
    let rooms: [MapRoom]
}

// MARK: - ClinicMapStore
struct ClinicMapStore {
    static let floors: [FloorData] = [ground, first]

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
        let n = Int(roomNumber) ?? 1
        func firstOf(_ cat: RoomCategory) -> String? {
            floors.flatMap(\.rooms).first { $0.category == cat }?.id
        }
        switch dept {
        case "Pharmacy":
            let id = "P-\(String(format: "%03d", n))"
            return room(id: id) != nil ? id : firstOf(.pharmacy)
        case "OPD":
            let ids = ["O-\(roomNumber)", "O-1\(String(format: "%02d", n))"]
            return ids.first { room(id: $0) != nil } ?? firstOf(.opd)
        case "Laboratory":
            let ids = ["L-\(roomNumber)", "L-1\(String(format: "%02d", n))"]
            return ids.first { room(id: $0) != nil } ?? firstOf(.laboratory)
        case "Radiology":         return "rad"
        case "Vaccination":
            let ids = ["V-\(roomNumber)", "V-1\(String(format: "%02d", n))"]
            return ids.first { room(id: $0) != nil } ?? firstOf(.vaccination)
        case "Specialist Clinic":
            let ids = ["S-\(roomNumber)", "S-1\(String(format: "%02d", n))"]
            return ids.first { room(id: $0) != nil } ?? firstOf(.specialist)
        default: return nil
        }
    }

    static func elevator(on floor: Int) -> MapRoom? {
        data(for: floor).rooms.first { $0.category == .utility && $0.name == "Elevator" }
    }

    // ══════════════════════════════════════════════════════════════
    // MARK: Ground Floor — Entrance, Reception, Waiting, Pharmacy
    // Rooms spread across full map: entrance far-right, pharmacy
    // upper-left, waiting centre, elevator bottom-left
    // ══════════════════════════════════════════════════════════════
    static let ground = FloorData(
        floor: 0, label: "Ground",
        rooms: [
            MapRoom(id: "entrance",  name: "Main Entrance",   shortName: "Entrance",   icon: "door.left.hand.open",   category: .entrance,  floor: 0, rect: CGRect(x: 0.82, y: 0.40, width: 0.12, height: 0.12)),
            MapRoom(id: "reception", name: "Reception",       shortName: "Reception",  icon: "person.crop.rectangle", category: .reception, floor: 0, rect: CGRect(x: 0.62, y: 0.40, width: 0.12, height: 0.12)),
            MapRoom(id: "wait-G",    name: "Waiting Area",    shortName: "Waiting",    icon: "person.2.fill",         category: .waiting,   floor: 0, rect: CGRect(x: 0.41, y: 0.40, width: 0.13, height: 0.12)),
            MapRoom(id: "P-001",     name: "Pharmacy 001",    shortName: "Pharm-1",    icon: "cross.case.fill",       category: .pharmacy,  floor: 0, rect: CGRect(x: 0.04, y: 0.06, width: 0.14, height: 0.16)),
            MapRoom(id: "P-002",     name: "Pharmacy 002",    shortName: "Pharm-2",    icon: "pills.fill",            category: .pharmacy,  floor: 0, rect: CGRect(x: 0.22, y: 0.06, width: 0.14, height: 0.16)),
            MapRoom(id: "elev-G",    name: "Elevator",        shortName: "Elevator",   icon: "arrow.up.arrow.down.square.fill", category: .utility, floor: 0, rect: CGRect(x: 0.04, y: 0.72, width: 0.10, height: 0.14)),
        ]
    )

    // ══════════════════════════════════════════════════════════════
    // MARK: 1st Floor — OPD · Vaccination · Lab · Radiology · Blood Bank · Specialist
    // All clinical departments consolidated on one floor.
    // Top row: OPD (left) + Vaccination (right)
    // Middle: Elevator — Waiting — Stairs
    // Bottom row: Lab · Radiology · Blood Bank · Specialist Clinics
    // ══════════════════════════════════════════════════════════════
    static let first = FloorData(
        floor: 1, label: "1st",
        rooms: [
            // ── OPD (top-left) ──
            MapRoom(id: "O-101",    name: "OPD Room 101",      shortName: "OPD-101",    icon: "stethoscope",                      category: .opd,         floor: 1, rect: CGRect(x: 0.04, y: 0.05, width: 0.13, height: 0.16)),
            MapRoom(id: "O-102",    name: "OPD Room 102",      shortName: "OPD-102",    icon: "stethoscope",                      category: .opd,         floor: 1, rect: CGRect(x: 0.21, y: 0.05, width: 0.13, height: 0.16)),
            MapRoom(id: "O-103",    name: "OPD Room 103",      shortName: "OPD-103",    icon: "stethoscope",                      category: .opd,         floor: 1, rect: CGRect(x: 0.38, y: 0.05, width: 0.13, height: 0.16)),
            // ── Vaccination (top-right) ──
            MapRoom(id: "V-101",    name: "Vaccination 101",   shortName: "Vacc-101",   icon: "syringe.fill",                     category: .vaccination, floor: 1, rect: CGRect(x: 0.62, y: 0.05, width: 0.13, height: 0.16)),
            MapRoom(id: "V-102",    name: "Vaccination 102",   shortName: "Vacc-102",   icon: "syringe.fill",                     category: .vaccination, floor: 1, rect: CGRect(x: 0.79, y: 0.05, width: 0.13, height: 0.16)),
            // ── Waiting + Utility (middle) ──
            MapRoom(id: "wait-1",   name: "Orthopedic Surgery", shortName: "Orthopedic", icon: "figure.walk",                       category: .specialist,  floor: 1, rect: CGRect(x: 0.38, y: 0.38, width: 0.15, height: 0.12)),
            MapRoom(id: "elev-1",   name: "Elevator",          shortName: "Elevator",   icon: "arrow.up.arrow.down.square.fill",  category: .utility,     floor: 1, rect: CGRect(x: 0.04, y: 0.38, width: 0.10, height: 0.12)),
            // ── Laboratory (bottom-left) ──
            MapRoom(id: "L-101",    name: "Lab Room 101",      shortName: "Lab-101",    icon: "flask.fill",                       category: .laboratory,  floor: 1, rect: CGRect(x: 0.04, y: 0.62, width: 0.13, height: 0.16)),
            MapRoom(id: "L-102",    name: "Lab Room 102",      shortName: "Lab-102",    icon: "testtube.2",                       category: .laboratory,  floor: 1, rect: CGRect(x: 0.21, y: 0.62, width: 0.13, height: 0.16)),
            // ── Radiology + Dermatology (bottom-centre) ──
            MapRoom(id: "rad",      name: "Radiology",         shortName: "Radiology",  icon: "waveform.path.ecg",               category: .radiology,   floor: 1, rect: CGRect(x: 0.38, y: 0.62, width: 0.13, height: 0.16)),
            MapRoom(id: "blood",    name: "Dermatology",       shortName: "Dermatology", icon: "hand.raised.fill",                    category: .specialist,  floor: 1, rect: CGRect(x: 0.55, y: 0.62, width: 0.12, height: 0.16)),
            // ── Specialist Clinics (bottom-right) ──
            MapRoom(id: "S-101",    name: "Cardiology",        shortName: "Cardiology", icon: "heart.fill",                      category: .specialist,  floor: 1, rect: CGRect(x: 0.69, y: 0.62, width: 0.11, height: 0.16)),
            MapRoom(id: "S-102",    name: "Neurology",         shortName: "Neurology",  icon: "brain.head.profile",              category: .specialist,  floor: 1, rect: CGRect(x: 0.82, y: 0.62, width: 0.11, height: 0.16)),
        ]
    )
}

// MARK: - RouteStore
// Pre-defined corridor paths for every navigable route.
// Keys are "originID→destinationID" (alphabetical order doesn't matter —
// lookup checks both directions). Points are normalised (0-1) coordinates
// on the 900×598 floor plan image.
//
// HOW TO ADD A ROUTE:
//  1. Open MapTabView in DEBUG, tap the "✏️ Trace" button.
//  2. Enter the route key exactly as shown below (e.g. "entrance→P-001").
//  3. Tap along the corridor centre-line from start to end.
//  4. Tap "Done" — copy the printed array from the Xcode console.
//  5. Paste it into the routes dictionary below.

struct RouteStore {

    // ── Lookup: returns the path for a given origin/destination pair ──
    // Returns nil if no pre-defined path exists yet (route won't be drawn).
    static func path(from originID: String, to destID: String) -> [CGPoint]? {
        let key      = "\(originID)→\(destID)"
        let keyRev   = "\(destID)→\(originID)"
        if let pts = routes[key]      { return pts }
        if let pts = routes[keyRev]   { return pts.reversed() }
        return nil
    }

    // ─────────────────────────────────────────────────────────────────────
    // MARK: Pre-defined paths (manually traced only)
    // ─────────────────────────────────────────────────────────────────────
    // ⭐ = REAL manually traced path
    private static let routes: [String: [CGPoint]] = [

        // ══ GROUND FLOOR ════════════════════════════════════════════════

        // ⭐ entrance → reception
        "entrance→reception": [
            CGPoint(x: 0.8977, y: 0.4433),
            CGPoint(x: 0.7998, y: 0.4406),
            CGPoint(x: 0.7981, y: 0.3225),
            CGPoint(x: 0.6896, y: 0.3238),
            CGPoint(x: 0.6931, y: 0.3836),
        ],

        // ⭐ entrance → P-001
        "entrance→P-001": [
            CGPoint(x: 0.8986, y: 0.4287),
            CGPoint(x: 0.7963, y: 0.4220),
            CGPoint(x: 0.7848, y: 0.3106),
            CGPoint(x: 0.0979, y: 0.2999),
            CGPoint(x: 0.0935, y: 0.2469),
        ],

        // ⭐ entrance → P-002  (real traced)
        "entrance→P-002": [
            CGPoint(x: 0.9012, y: 0.4419),
            CGPoint(x: 0.8095, y: 0.4406),
            CGPoint(x: 0.7901, y: 0.3106),
            CGPoint(x: 0.2901, y: 0.3119),
            CGPoint(x: 0.2937, y: 0.2163),
        ],

        // ⭐ entrance → elev-G  (real traced)
        "entrance→elev-G": [
            CGPoint(x: 0.8986, y: 0.4419),
            CGPoint(x: 0.8175, y: 0.4393),
            CGPoint(x: 0.8175, y: 0.6357),
            CGPoint(x: 0.1190, y: 0.6397),
            CGPoint(x: 0.1173, y: 0.7193),
        ],

        // ⭐ reception → wait-G  (real traced)
        "reception→wait-G": [
            CGPoint(x: 0.6940, y: 0.3796),
            CGPoint(x: 0.6861, y: 0.3119),
            CGPoint(x: 0.5891, y: 0.3198),
            CGPoint(x: 0.5335, y: 0.3185),
            CGPoint(x: 0.5247, y: 0.4605),
            CGPoint(x: 0.4912, y: 0.4632),
        ],

        // ⭐ wait-G → P-001
        "wait-G→P-001": [
            CGPoint(x: 0.4709, y: 0.4353),
            CGPoint(x: 0.5229, y: 0.4380),
            CGPoint(x: 0.5247, y: 0.3265),
            CGPoint(x: 0.1217, y: 0.3212),
            CGPoint(x: 0.1199, y: 0.2575),
        ],

        // ⭐ wait-G → P-002  (real traced)
        "wait-G→P-002": [
            CGPoint(x: 0.4788, y: 0.4619),
            CGPoint(x: 0.5388, y: 0.4619),
            CGPoint(x: 0.5423, y: 0.3039),
            CGPoint(x: 0.3104, y: 0.2999),
            CGPoint(x: 0.3175, y: 0.2070),
        ],

        // ⭐ wait-G → elev-G  (real traced)
        "wait-G→elev-G": [
            CGPoint(x: 0.4718, y: 0.4565),
            CGPoint(x: 0.5176, y: 0.4632),
            CGPoint(x: 0.5220, y: 0.6516),
            CGPoint(x: 0.1296, y: 0.6503),
            CGPoint(x: 0.1305, y: 0.7313),
        ],

        // ══ 1ST FLOOR ════════════════════════════════════════════════════

        // ⭐ elev-1 → wait-1 (Orthopedic Surgery)
        "elev-1→wait-1": [
            CGPoint(x: 0.0802, y: 0.3982),
            CGPoint(x: 0.2134, y: 0.4021),
            CGPoint(x: 0.2196, y: 0.3252),
            CGPoint(x: 0.5132, y: 0.3185),
            CGPoint(x: 0.5159, y: 0.4327),
            CGPoint(x: 0.4850, y: 0.4300),
        ],

        // ⭐ elev-1 → O-101  (real traced)
        "elev-1→O-101": [
            CGPoint(x: 0.0776, y: 0.4287),
            CGPoint(x: 0.1102, y: 0.4327),
            CGPoint(x: 0.1111, y: 0.2548),
        ],

        // ⭐ elev-1 → O-102  (real traced)
        "elev-1→O-102": [
            CGPoint(x: 0.0891, y: 0.4154),
            CGPoint(x: 0.2319, y: 0.4220),
            CGPoint(x: 0.2284, y: 0.3172),
            CGPoint(x: 0.2743, y: 0.3132),
            CGPoint(x: 0.2840, y: 0.2376),
        ],

        // ⭐ elev-1 → O-103  (real traced)
        "elev-1→O-103": [
            CGPoint(x: 0.0811, y: 0.4074),
            CGPoint(x: 0.2354, y: 0.4101),
            CGPoint(x: 0.2399, y: 0.3185),
            CGPoint(x: 0.4612, y: 0.3092),
            CGPoint(x: 0.4586, y: 0.1526),
        ],

        // ⭐ elev-1 → V-101  (real traced)
        "elev-1→V-101": [
            CGPoint(x: 0.0935, y: 0.4220),
            CGPoint(x: 0.2055, y: 0.4260),
            CGPoint(x: 0.2222, y: 0.3291),
            CGPoint(x: 0.6464, y: 0.3318),
            CGPoint(x: 0.6490, y: 0.2548),
        ],

        // ⭐ elev-1 → V-102  (real traced)
        "elev-1→V-102": [
            CGPoint(x: 0.0873, y: 0.4274),
            CGPoint(x: 0.2231, y: 0.4247),
            CGPoint(x: 0.2319, y: 0.3252),
            CGPoint(x: 0.8536, y: 0.3198),
            CGPoint(x: 0.8563, y: 0.2256),
        ],

        // ⭐ elev-1 → L-101  (real traced)
        "elev-1→L-101": [
            CGPoint(x: 0.0926, y: 0.4207),
            CGPoint(x: 0.1217, y: 0.4194),
            CGPoint(x: 0.1217, y: 0.6384),
            CGPoint(x: 0.0855, y: 0.6397),
        ],

        // ⭐ elev-1 → L-102  (real traced)
        "elev-1→L-102": [
            CGPoint(x: 0.0785, y: 0.4128),
            CGPoint(x: 0.2319, y: 0.4101),
            CGPoint(x: 0.2372, y: 0.6331),
            CGPoint(x: 0.2813, y: 0.6596),
            CGPoint(x: 0.2892, y: 0.7538),
        ],

        // ⭐ elev-1 → rad  (real traced)
        "elev-1→rad": [
            CGPoint(x: 0.0847, y: 0.4101),
            CGPoint(x: 0.2240, y: 0.4128),
            CGPoint(x: 0.2328, y: 0.6384),
            CGPoint(x: 0.4674, y: 0.6437),
            CGPoint(x: 0.4603, y: 0.7140),
        ],

        // ⭐ elev-1 → blood (Dermatology)  (real traced)
        "elev-1→blood": [
            CGPoint(x: 0.0838, y: 0.4220),
            CGPoint(x: 0.2222, y: 0.4194),
            CGPoint(x: 0.2275, y: 0.6516),
            CGPoint(x: 0.6305, y: 0.6609),
            CGPoint(x: 0.6384, y: 0.7246),
        ],

        // ⭐ elev-1 → S-101 (Cardiology)  (real traced)
        "elev-1→S-101": [
            CGPoint(x: 0.0820, y: 0.4128),
            CGPoint(x: 0.2205, y: 0.4101),
            CGPoint(x: 0.2266, y: 0.6609),
            CGPoint(x: 0.7302, y: 0.6702),
            CGPoint(x: 0.7363, y: 0.6092),
        ],

        // ⭐ elev-1 → S-102 (Neurology)  (real traced)
        "elev-1→S-102": [
            CGPoint(x: 0.0864, y: 0.4141),
            CGPoint(x: 0.2196, y: 0.4048),
            CGPoint(x: 0.2249, y: 0.6516),
            CGPoint(x: 0.8042, y: 0.6689),
            CGPoint(x: 0.8078, y: 0.7260),
        ],
    ]
}
