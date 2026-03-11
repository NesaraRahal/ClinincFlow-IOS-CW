import SwiftUI

// MARK: - Location Picker View
// Sheet-based room picker with floor tabs, category-grouped list,
// and search. Apple HIG-aligned with clear visual hierarchy.

struct LocationPickerView: View {
    let title: String
    @Binding var selectedRoomID: String?
    @Binding var selectedFloor: Int
    @Environment(\.dismiss) private var dismiss

    @State private var searchText: String = ""
    @State private var activeFloorTab: Int? = nil  // nil = All

    private let floorTabs: [(String, Int?)] = [
        ("All", nil), ("G", 0), ("1", 1), ("2", 2), ("3", 3)
    ]

    private var filteredRooms: [MapRoom] {
        var rooms: [MapRoom]
        if let floor = activeFloorTab {
            rooms = ClinicMapStore.allRooms(on: floor)
        } else {
            rooms = ClinicMapStore.floors.flatMap(\.rooms)
        }
        // Exclude utility rooms from picker
        rooms = rooms.filter { $0.category != .utility }
        if !searchText.isEmpty {
            rooms = rooms.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.shortName.localizedCaseInsensitiveContains(searchText)
            }
        }
        return rooms
    }

    private var groupedRooms: [(RoomCategory, [MapRoom])] {
        let dict = Dictionary(grouping: filteredRooms, by: \.category)
        return RoomCategory.allCases.compactMap { cat in
            guard let rooms = dict[cat], !rooms.isEmpty else { return nil }
            return (cat, rooms)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Floor tab bar
                floorTabBar
                    .padding(.top, 4)

                // Room list
                if groupedRooms.isEmpty {
                    emptyState
                } else {
                    roomList
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search rooms…")
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Floor Tab Bar
    private var floorTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(floorTabs, id: \.0) { tab in
                    Button {
                        withAnimation(.spring(response: 0.3)) { activeFloorTab = tab.1 }
                    } label: {
                        Text(tab.0)
                            .font(.system(size: 14, weight: activeFloorTab == tab.1 ? .bold : .medium, design: .rounded))
                            .foregroundColor(activeFloorTab == tab.1 ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background {
                                Capsule().fill(
                                    activeFloorTab == tab.1
                                        ? Color(hex: "16A34A")
                                        : Color(.systemGray5)
                                )
                            }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Room List
    private var roomList: some View {
        List {
            ForEach(groupedRooms, id: \.0) { category, rooms in
                Section {
                    ForEach(rooms) { room in
                        roomRow(room)
                    }
                } header: {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(category.tint)
                            .frame(width: 8, height: 8)
                        Text(category.rawValue)
                            .font(.system(size: 13, weight: .semibold))
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func roomRow(_ room: MapRoom) -> some View {
        Button {
            selectedRoomID = room.id
            selectedFloor = room.floor
            dismiss()
        } label: {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: room.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(room.category.tint)
                    .frame(width: 32, height: 32)
                    .background(room.category.fill)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                // Details
                VStack(alignment: .leading, spacing: 2) {
                    Text(room.name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                    Text("Floor \(room.floor == 0 ? "G" : "\(room.floor)") · \(room.shortName)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Selected check
                if selectedRoomID == room.id {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "16A34A"))
                }
            }
            .contentShape(Rectangle())
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36))
                .foregroundColor(.secondary.opacity(0.6))
            Text("No rooms found")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            if !searchText.isEmpty {
                Text("Try a different search term")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
