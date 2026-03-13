import SwiftUI

// MARK: - Accessibility Settings View
struct AccessibilitySettingsView: View {
    @EnvironmentObject var hapticsManager: HapticsManager
    @AppStorage("useDynamicType") private var useDynamicType = true
    
    var body: some View {
        List {
            // MARK: - Haptic Feedback
            Section {
                Toggle(isOn: $hapticsManager.hapticsEnabled) {
                    SettingsToggleLabel(
                        icon: "hand.tap.fill",
                        iconColor: .indigo,
                        title: "Haptic Feedback"
                    )
                }
                .tint(Color(hex: "16A34A"))
                .onChange(of: hapticsManager.hapticsEnabled) { newValue in
                    if newValue {
                        hapticsManager.mediumTap()
                    }
                }
            } header: {
                Text("Haptics")
            } footer: {
                Text("Provides tactile feedback when you interact with buttons, toggles, and other controls. Haptics require a physical device — they do not work on the Simulator.")
            }
            
            // MARK: - Sound Effects
            Section {
                Toggle(isOn: $hapticsManager.soundEnabled) {
                    SettingsToggleLabel(
                        icon: "speaker.wave.2.fill",
                        iconColor: .cyan,
                        title: "Sound Effects"
                    )
                }
                .tint(Color(hex: "16A34A"))
                .onChange(of: hapticsManager.soundEnabled) { newValue in
                    if newValue {
                        hapticsManager.playTapSound()
                    }
                }
                
                
            } header: {
                Text("Sound")
            } footer: {
                Text("Plays audio cues for actions like booking confirmations, navigation, and errors. Make sure your device is not in silent mode.")
            }
            
            // MARK: - Screen Reader
            Section {
                Toggle(isOn: $hapticsManager.screenReaderEnabled) {
                    SettingsToggleLabel(
                        icon: "speaker.badge.exclamationmark.fill",
                        iconColor: .orange,
                        title: "Screen Reader"
                    )
                }
                .tint(Color(hex: "16A34A"))
                .onChange(of: hapticsManager.screenReaderEnabled) { newValue in
                    if newValue {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            hapticsManager.speak("Screen reader is now enabled. The app will read out screen content to assist you.")
                        }
                    } else {
                        hapticsManager.stopSpeaking()
                    }
                }
                
                if hapticsManager.screenReaderEnabled {
                    // Preview / test
                    Button(action: {
                        hapticsManager.speak("This is ClinicFlow, your clinic appointment and queue management app. You can book appointments, check your queue status, and manage your profile.")
                    }) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.orange.opacity(0.15))
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: "play.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.orange)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Test Screen Reader")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Text("Tap to hear a sample announcement")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(.systemGray3))
                        }
                        .padding(.vertical, 4)
                    }
                }
            } header: {
                Text("Vision Assistance")
            } footer: {
                Text("When enabled, the app will read aloud key screen content, navigation actions, and booking details to assist users with vision impairments. Uses text-to-speech.")
            }

            // MARK: - Text & Display
            Section {
                Toggle(isOn: $useDynamicType) {
                    SettingsToggleLabel(
                        icon: "textformat.size",
                        iconColor: .purple,
                        title: "Dynamic Type"
                    )
                }
                .tint(Color(hex: "16A34A"))
            } header: {
                Text("Text & Display")
            } footer: {
                Text("Allow larger text scaling based on system text size preferences.")
            }
            
            // MARK: - System Accessibility
            Section {
                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("System Accessibility Settings")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Text("VoiceOver, Reduce Motion, AssistiveTouch & more")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 14))
                            .foregroundColor(Color(.systemGray3))
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text("System")
            } footer: {
                Text("Open iOS Accessibility settings for additional features like VoiceOver and Reduce Motion.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Accessibility")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Sound Preview Button
struct SoundPreviewButton: View {
    let label: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "16A34A"))
                    .frame(width: 20)
                
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "16A34A"))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    NavigationStack {
        AccessibilitySettingsView()
            .environmentObject(HapticsManager())
    }
}
