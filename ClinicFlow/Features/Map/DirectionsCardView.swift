import SwiftUI

// MARK: - Directions Card View
// Turn-by-turn walking directions shown in the active navigation panel.
// Generates NavSteps from origin to destination and renders them as
// a compact step-by-step list with connecting lines and icons.

struct DirectionsCardView: View {
    let originID: String
    let destinationID: String
    let floor: Int

    private var steps: [NavStep] {
        NavStep.generate(from: originID, to: destinationID, currentFloor: floor)
    }

    var body: some View {
        if steps.isEmpty {
            Text("Select origin and destination to see directions")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)
        } else {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    StepRow(step: step, isFirst: index == 0, isLast: index == steps.count - 1)
                }
            }
        }
    }
}

// MARK: - NavStep Model
struct NavStep {
    enum Kind { case start, walk, elevator, approach, arrive }
    let kind: Kind
    let text: String
    let icon: String
    let floor: Int?

    static func generate(from originID: String, to destID: String, currentFloor: Int) -> [NavStep] {
        guard let origin = ClinicMapStore.room(id: originID),
              let dest = ClinicMapStore.room(id: destID) else { return [] }

        var steps: [NavStep] = []

        // 1. Start
        steps.append(NavStep(kind: .start, text: "Start at \(origin.shortName)", icon: "figure.stand", floor: origin.floor))

        // 2. Exit room and walk to corridor
        steps.append(NavStep(kind: .walk, text: "Exit and walk to the corridor", icon: "arrow.turn.right.up", floor: origin.floor))

        // 3. Cross-floor: take elevator
        if origin.floor != dest.floor {
            let direction = dest.floor > origin.floor ? "up" : "down"
            steps.append(NavStep(kind: .elevator, text: "Take elevator \(direction) to floor \(dest.floor == 0 ? "G" : "\(dest.floor)")", icon: "arrow.up.arrow.down", floor: nil))
            steps.append(NavStep(kind: .walk, text: "Exit elevator and follow corridor", icon: "arrow.turn.right.up", floor: dest.floor))
        } else {
            // Same floor: walk along corridor
            steps.append(NavStep(kind: .walk, text: "Follow the corridor", icon: "figure.walk", floor: origin.floor))
        }

        // 4. Approach destination
        steps.append(NavStep(kind: .approach, text: "Turn towards \(dest.category.rawValue) area", icon: "location.north.line.fill", floor: dest.floor))

        // 5. Arrive
        steps.append(NavStep(kind: .arrive, text: "Arrive at \(dest.shortName)", icon: "flag.checkered", floor: dest.floor))

        return steps
    }
}

// MARK: - Step Row
struct StepRow: View {
    let step: NavStep
    let isFirst: Bool
    let isLast: Bool

    private var iconColor: Color {
        switch step.kind {
        case .start:    return Color(hex: "007AFF")
        case .walk:     return Color(hex: "16A34A")
        case .elevator: return Color(hex: "7C3AED")
        case .approach: return Color(hex: "FF9500")
        case .arrive:   return Color(hex: "FF3B30")
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline indicator
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 2, height: 10)
                }

                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 28, height: 28)
                    Image(systemName: step.icon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(iconColor)
                }

                if !isLast {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 28)

            // Step text
            VStack(alignment: .leading, spacing: 2) {
                Text(step.text)
                    .font(.system(size: 14, weight: isFirst || isLast ? .semibold : .regular))
                    .foregroundColor(.primary)
                if let floor = step.floor {
                    Text("Floor \(floor == 0 ? "G" : "\(floor)")")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary.opacity(0.7))
                }
            }
            .padding(.vertical, 6)

            Spacer()
        }
        .padding(.horizontal, 4)
    }
}
