import SwiftUI
import UIKit
import UniformTypeIdentifiers

// MARK: - Waypoint Editor (Debug Tool)
// HOW TO USE:
//  1. Tap the purple "Trace" button on the Map tab (DEBUG builds only).
//  2. Type the route key at the top, e.g.  entrance→elev-G
//  3. Tap along every corridor turn on the image from start → end.
//     Dots + a dashed line appear as you tap.
//  4. Tap "Generate Code" — a panel slides up with the Swift snippet.
//  5. Tap "Share" or "Copy" to export, then paste into IndoorMapData.swift.

#if DEBUG
struct WaypointEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var routeKey: String = ""
    @State private var points: [CGPoint] = []
    @State private var generatedCode: String = ""
    @State private var showCodePanel: Bool = false
    @State private var justCopied: Bool = false

    private let imageAspect: CGFloat = 900.0 / 598.0

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // ── Main layout ──────────────────────────────────────
                VStack(spacing: 0) {
                    routeKeyBar

                    GeometryReader { geo in
                        let size = canvasSize(in: geo.size)

                        ZStack(alignment: .topLeading) {
                            // Floor plan image
                            Image("clinic_floor_plan")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .allowsHitTesting(false)

                            // Drawn path
                            if points.count >= 2 {
                                let scaled = points.map {
                                    CGPoint(x: $0.x * size.width, y: $0.y * size.height)
                                }
                                Path { p in
                                    p.move(to: scaled[0])
                                    scaled.dropFirst().forEach { p.addLine(to: $0) }
                                }
                                .stroke(
                                    Color(hex: "007AFF"),
                                    style: StrokeStyle(lineWidth: 3, lineCap: .round,
                                                       lineJoin: .round, dash: [6, 4])
                                )
                                .allowsHitTesting(false)
                            }

                            // Waypoint dots
                            ForEach(Array(points.enumerated()), id: \.offset) { i, pt in
                                ZStack {
                                    Circle()
                                        .fill(i == 0 ? Color(hex: "16A34A") : Color(hex: "007AFF"))
                                        .frame(width: 22, height: 22)
                                        .shadow(color: .black.opacity(0.25), radius: 2)
                                    Text("\(i + 1)")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .position(CGPoint(x: pt.x * size.width, y: pt.y * size.height))
                                .allowsHitTesting(false)
                            }

                            // ── Tap-capture overlay ──
                            // Uses DragGesture(minimumDistance:0) which is more
                            // reliable than onTapGesture for coordinate capture.
                            Color.clear
                                .contentShape(Rectangle())
                                .frame(width: size.width, height: size.height)
                                .gesture(
                                    DragGesture(minimumDistance: 0,
                                                coordinateSpace: .local)
                                        .onEnded { value in
                                            let loc = value.startLocation
                                            let nx = min(max(loc.x / size.width,  0), 1)
                                            let ny = min(max(loc.y / size.height, 0), 1)
                                            withAnimation(.spring(response: 0.2)) {
                                                points.append(CGPoint(x: nx, y: ny))
                                            }
                                        }
                                )
                        }
                        .frame(width: size.width, height: size.height)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .padding(12)

                    bottomBar
                }

                // ── Inline code panel (no nested sheet) ─────────────
                if showCodePanel {
                    codePanel
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(10)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Waypoint Tracer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: undo) {
                        Image(systemName: "arrow.uturn.backward.circle")
                    }
                    .disabled(points.isEmpty)
                }
            }
        }
    }

    // MARK: - Route key bar
    private var routeKeyBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                .foregroundColor(Color(hex: "16A34A"))
                .font(.system(size: 18))
            TextField("Route key  e.g.  entrance→elev-G", text: $routeKey)
                .font(.system(size: 13, design: .monospaced))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .overlay(Rectangle().frame(height: 1)
            .foregroundColor(Color(.systemGray5)), alignment: .bottom)
    }

    // MARK: - Bottom bar
    private var bottomBar: some View {
        HStack(spacing: 14) {
            HStack(spacing: 5) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(Color(hex: "007AFF"))
                    .font(.system(size: 15))
                Text("\(points.count) pt\(points.count == 1 ? "" : "s")")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(points.isEmpty ? .secondary : Color(hex: "007AFF"))
            }

            Spacer()

            Button(action: { withAnimation { points.removeAll(); showCodePanel = false } }) {
                Image(systemName: "trash")
                    .font(.system(size: 15))
                    .foregroundColor(.red)
            }
            .disabled(points.isEmpty)

            Button(action: generateCode) {
                Label("Generate Code", systemImage: "curlybraces")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(Capsule().fill(
                        points.count >= 2 ? Color(hex: "16A34A") : Color(.systemGray3)
                    ))
            }
            .disabled(points.count < 2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(Rectangle().frame(height: 1)
            .foregroundColor(Color(.systemGray5)), alignment: .top)
    }

    // MARK: - Inline code panel
    private var codePanel: some View {
        VStack(spacing: 0) {
            // Handle + header
            VStack(spacing: 6) {
                Capsule()
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 36, height: 4)

                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "16A34A"))
                        Text("Ready to paste")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    Spacer()
                    Button(action: { withAnimation { showCodePanel = false } }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 20))
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 8)
            .padding(.bottom, 6)

            // Code preview — selectable so you can long-press copy too
            ScrollView([.horizontal, .vertical]) {
                Text(generatedCode)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.primary)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
            .frame(maxHeight: 180)
            .background(Color(.systemGray6))

            // Action buttons
            HStack(spacing: 0) {
                ShareLink(
                    item: generatedCode,
                    subject: Text("RouteStore entry"),
                    message: Text("Paste into IndoorMapData.swift → RouteStore.routes")
                ) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Share")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color(hex: "16A34A"))
                }

                Divider().frame(width: 1)

                Button {
                    UIPasteboard.general.setValue(
                        generatedCode,
                        forPasteboardType: UTType.plainText.identifier
                    )
                    withAnimation { justCopied = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { justCopied = false }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: justCopied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 14, weight: .semibold))
                        Text(justCopied ? "Copied!" : "Copy")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(justCopied ? Color(hex: "16A34A") : Color(hex: "007AFF"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color(.systemBackground))
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.18), radius: 20, y: -4)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }

    // MARK: - Helpers
    private func undo() {
        withAnimation(.spring(response: 0.2)) {
            if !points.isEmpty { points.removeLast() }
            if points.count < 2 { showCodePanel = false }
        }
    }

    private func generateCode() {
        let key = routeKey.trimmingCharacters(in: .whitespaces).isEmpty
            ? "UNNAMED"
            : routeKey.trimmingCharacters(in: .whitespaces)
        var lines: [String] = []
        lines.append("// \(key)  (\(points.count) points)")
        lines.append("\"\(key)\": [")
        for (i, p) in points.enumerated() {
            let comma = i < points.count - 1 ? "," : ""
            lines.append(String(format: "    CGPoint(x: %.4f, y: %.4f)\(comma)", p.x, p.y))
        }
        lines.append("],")
        generatedCode = lines.joined(separator: "\n")

        // Pre-copy immediately; also available via Share / Copy buttons
        UIPasteboard.general.setValue(generatedCode,
                                      forPasteboardType: UTType.plainText.identifier)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showCodePanel = true
        }
    }

    private func canvasSize(in container: CGSize) -> CGSize {
        guard container.width > 0, container.height > 0 else {
            return CGSize(width: 300, height: 300 / imageAspect)
        }
        let byWidth = CGSize(width: container.width, height: container.width / imageAspect)
        if byWidth.height <= container.height { return byWidth }
        return CGSize(width: container.height * imageAspect, height: container.height)
    }
}

#Preview {
    WaypointEditorView()
}
#endif
