import SwiftUI

// MARK: - Appearance Settings View
struct AppearanceSettingsView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    @State private var useDynamicType = true
    
    let appearances = ["Light", "Dark", "System"]
    
    var body: some View {
        List {
            Section("Theme") {
                ForEach(appearances, id: \.self) { appearance in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            appearanceManager.appearance = appearance
                        }
                    }) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(appearanceColor(for: appearance).opacity(0.15))
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: appearanceIcon(for: appearance))
                                    .font(.system(size: 14))
                                    .foregroundColor(appearanceColor(for: appearance))
                            }
                            
                            Text(appearance)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if appearanceManager.appearance == appearance {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: "16A34A"))
                            }
                        }
                    }
                }
            }
            
            Section {
                Toggle(isOn: $useDynamicType) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dynamic Type")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("Adjust text size based on system settings")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                }
                .tint(Color(hex: "16A34A"))
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func appearanceIcon(for appearance: String) -> String {
        switch appearance {
        case "Light": return "sun.max.fill"
        case "Dark": return "moon.fill"
        default: return "circle.lefthalf.filled"
        }
    }
    
    private func appearanceColor(for appearance: String) -> Color {
        switch appearance {
        case "Light": return .orange
        case "Dark": return .purple
        default: return .blue
        }
    }
}

#Preview {
    NavigationStack {
        AppearanceSettingsView()
            .environmentObject(AppearanceManager())
    }
}
