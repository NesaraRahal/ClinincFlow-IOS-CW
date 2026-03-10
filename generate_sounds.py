#!/usr/bin/env python3
"""Generate 5 distinct sound effect .wav files for ClinicFlow app."""
import wave, struct, math, os

SAMPLE_RATE = 44100
OUTPUT_DIR = "ClinicFlow/Sounds"

def write_wav(filename, samples):
    path = os.path.join(OUTPUT_DIR, filename)
    with wave.open(path, 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(SAMPLE_RATE)
        for s in samples:
            f.writeframes(struct.pack('<h', max(-32767, min(32767, int(s)))))
    print(f"  Created {path} ({len(samples)} samples, {len(samples)/SAMPLE_RATE:.2f}s)")

def generate_tap():
    """Short crisp click - 50ms"""
    duration = 0.05
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = max(0, 1.0 - t / duration)  # linear decay
        val = math.sin(2 * math.pi * 800 * t) * env * 24000
        samples.append(val)
    return samples

def generate_confirm():
    """Two-tone ascending ding - 200ms (like a doorbell)"""
    n = int(SAMPLE_RATE * 0.2)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = max(0, 1.0 - t / 0.25) ** 1.5
        if t < 0.1:
            freq = 880  # A5
        else:
            freq = 1109  # C#6
        val = math.sin(2 * math.pi * freq * t) * env * 22000
        # Add a harmonic for richness
        val += math.sin(2 * math.pi * freq * 2 * t) * env * 8000
        samples.append(val)
    return samples

def generate_success():
    """Cheerful ascending three-note chime - 400ms"""
    notes = [(523, 0.0, 0.15), (659, 0.12, 0.15), (784, 0.24, 0.18)]  # C5, E5, G5
    total = int(SAMPLE_RATE * 0.45)
    samples = [0.0] * total
    for freq, start, dur in notes:
        s_start = int(start * SAMPLE_RATE)
        s_dur = int(dur * SAMPLE_RATE)
        for i in range(s_dur):
            if s_start + i < total:
                t = i / SAMPLE_RATE
                env = max(0, 1.0 - t / dur) ** 1.2
                val = math.sin(2 * math.pi * freq * t) * env * 20000
                val += math.sin(2 * math.pi * freq * 2 * t) * env * 6000
                samples[s_start + i] += val
    # Clamp
    samples = [max(-32767, min(32767, s)) for s in samples]
    return samples

def generate_error():
    """Low buzzy two-tone descending - 300ms"""
    n = int(SAMPLE_RATE * 0.3)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = max(0, 1.0 - t / 0.35) ** 1.3
        if t < 0.15:
            freq = 440  # A4
        else:
            freq = 330  # E4
        # Main tone + harsh harmonics for "error" feel
        val = math.sin(2 * math.pi * freq * t) * env * 18000
        val += math.sin(2 * math.pi * freq * 3 * t) * env * 7000  # 3rd harmonic (dissonant)
        val += math.sin(2 * math.pi * (freq * 1.05) * t) * env * 5000  # slight detune
        samples.append(val)
    return samples

def generate_navigation():
    """Soft whoosh / slide - 150ms"""
    duration = 0.15
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        progress = t / duration
        env = math.sin(math.pi * progress) ** 0.5  # bell curve
        # Frequency sweep from 600 to 1200 Hz
        freq = 600 + 600 * progress
        val = math.sin(2 * math.pi * freq * t) * env * 16000
        # Add noise-like component for whoosh feel
        val += math.sin(2 * math.pi * (freq * 1.5) * t) * env * 5000
        val += math.sin(2 * math.pi * (freq * 0.5) * t) * env * 4000
        samples.append(val)
    return samples

print("Generating sound effects...")
write_wav("tap.wav", generate_tap())
write_wav("confirm.wav", generate_confirm())
write_wav("success.wav", generate_success())
write_wav("error.wav", generate_error())
write_wav("navigation.wav", generate_navigation())
print("Done!")
