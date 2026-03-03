//
//  HapticsManager.swift
//  ClinicFlow
//
//  Created by COBSCCOMP24.2P-053 on 2026-03-03.
//

import SwiftUI
import AVFoundation
import Combine

// MARK: - Haptics & Sound Manager
class HapticsManager: ObservableObject {
    
    @Published var hapticsEnabled: Bool {
        didSet { UserDefaults.standard.set(hapticsEnabled, forKey: "hapticsEnabled") }
    }
    
    @Published var soundEnabled: Bool {
        didSet { UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled") }
    }
    
    @Published var screenReaderEnabled: Bool {
        didSet { UserDefaults.standard.set(screenReaderEnabled, forKey: "screenReaderEnabled") }
    }
    
    private let synthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer?
    
    // Pre-loaded sound IDs for instant playback
    private var tapSoundID: SystemSoundID = 0
    private var confirmSoundID: SystemSoundID = 0
    private var successSoundID: SystemSoundID = 0
    private var errorSoundID: SystemSoundID = 0
    private var navigationSoundID: SystemSoundID = 0
    
    init() {
        self.hapticsEnabled = UserDefaults.standard.object(forKey: "hapticsEnabled") as? Bool ?? true
        self.soundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        self.screenReaderEnabled = UserDefaults.standard.object(forKey: "screenReaderEnabled") as? Bool ?? false
        
        // Configure audio session so sounds play even in silent mode on simulator
        configureAudioSession()
        
        // Pre-load all bundled sound files
        preloadSounds()
    }
    
    deinit {
        // Clean up sound IDs
        if tapSoundID != 0 { AudioServicesDisposeSystemSoundID(tapSoundID) }
        if confirmSoundID != 0 { AudioServicesDisposeSystemSoundID(confirmSoundID) }
        if successSoundID != 0 { AudioServicesDisposeSystemSoundID(successSoundID) }
        if errorSoundID != 0 { AudioServicesDisposeSystemSoundID(errorSoundID) }
        if navigationSoundID != 0 { AudioServicesDisposeSystemSoundID(navigationSoundID) }
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }
    
    // MARK: - Haptic Feedback
    
    /// Light tap — for selections, toggles
    func lightTap() {
        guard hapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Medium tap — for confirmations, button presses
    func mediumTap() {
        guard hapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Heavy tap — for important actions
    func heavyTap() {
        guard hapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Success notification
    func success() {
        guard hapticsEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    /// Error notification
    func error() {
        guard hapticsEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    /// Warning notification
    func warning() {
        guard hapticsEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
    
    /// Selection changed
    func selectionChanged() {
        guard hapticsEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    // MARK: - Sound Effects (bundled .wav files for distinct, reliable sounds)
    
    /// Pre-load all sound files from the app bundle at init
    private func preloadSounds() {
        tapSoundID = loadSound(named: "tap", ext: "wav")
        confirmSoundID = loadSound(named: "confirm", ext: "wav")
        successSoundID = loadSound(named: "success", ext: "wav")
        errorSoundID = loadSound(named: "error", ext: "wav")
        navigationSoundID = loadSound(named: "navigation", ext: "wav")
    }
    
    /// Load a sound file from the bundle into a SystemSoundID
    private func loadSound(named name: String, ext: String) -> SystemSoundID {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("⚠️ Sound file not found: \(name).\(ext)")
            return 0
        }
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
        return soundID
    }
    
    /// Play a pre-loaded sound by its SystemSoundID
    private func playLoadedSound(_ soundID: SystemSoundID) {
        guard soundEnabled, soundID != 0 else { return }
        AudioServicesPlaySystemSound(soundID)
    }
    
    /// Tap — short crisp click (50ms)
    func playTapSound() {
        playLoadedSound(tapSoundID)
    }
    
    /// Confirm — ascending two-tone ding (200ms)
    func playConfirmSound() {
        playLoadedSound(confirmSoundID)
    }
    
    /// Success — cheerful three-note chime (450ms)
    func playSuccessSound() {
        playLoadedSound(successSoundID)
    }
    
    /// Error — low buzzy descending tone (300ms)
    func playErrorSound() {
        playLoadedSound(errorSoundID)
    }
    
    /// Navigation — soft whoosh sweep (150ms)
    func playNavigationSound() {
        playLoadedSound(navigationSoundID)
    }
    
    // MARK: - Screen Reader (Text-to-Speech)
    
    /// Speak text aloud using AVSpeechSynthesizer
    func speak(_ text: String) {
        guard screenReaderEnabled else { return }
        
        // Stop any current speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 0.8
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        synthesizer.speak(utterance)
    }
    
    /// Stop current speech
    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}
