import SwiftUI

// MARK: - Language Settings View
struct LanguageSettingsView: View {
    @State private var selectedLanguage = "English"
    
    let languages = [
        ("English", "en"),
        ("සිංහල", "si"),
        ("தமிழ்", "ta"),
        ("हिंदी", "hi"),
        ("中文", "zh"),
        ("العربية", "ar")
    ]
    
    var body: some View {
        List {
            Section {
                ForEach(languages, id: \.1) { language in
                    Button(action: {
                        selectedLanguage = language.0
                    }) {
                        HStack {
                            Text(language.0)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedLanguage == language.0 {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: "16A34A"))
                            }
                        }
                    }
                }
            } footer: {
                Text("Select your preferred language for the app interface")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Language")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        LanguageSettingsView()
    }
}
