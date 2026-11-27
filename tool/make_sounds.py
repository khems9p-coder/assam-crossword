"""Makes the game's sound effects as small WAV files.

Every sound is generated here from simple tones and noise, so they are
original and free to use. Run from the project folder:
    python3 tool/make_sounds.py
"""
import math
import os
import random
import struct
import wave

RATE = 22050
OUT = 'assets/sounds'
rng = random.Random(7)  # fixed, so the sounds are the same every time


# ---------- Building blocks ----------

def note(freq, seconds, volume, decay, attack=0.004, glide=1.0, bell=False):
    """A tone that fades out. glide bends the pitch (2.0 = up an octave).
    bell=True adds bell-like overtones for a bright 'ding'."""
    n = int(RATE * seconds)
    out = []
    phase = 0.0
    for i in range(n):
        t = i / RATE
        f = freq * (glide ** (i / n))
        phase += 2 * math.pi * f / RATE
        s = math.sin(phase)
        if bell:
            s += 0.35 * math.sin(2.0 * phase) * math.exp(-4 * t)
            s += 0.15 * math.sin(3.01 * phase) * math.exp(-8 * t)
        env = math.exp(-decay * t) * min(1.0, t / attack)
        release = min(1.0, (n - i) / (RATE * 0.02))
        out.append(s * env * release * volume)
    return out


def noise(seconds, volume, low, high=None, decay=0.0, swell=False):
    """Filtered noise. The filter cutoff moves from low to high (Hz).
    swell=True fades in then out (for a whoosh)."""
    n = int(RATE * seconds)
    high = high or low
    out = []
    y = 0.0
    y2 = 0.0
    for i in range(n):
        t = i / RATE
        fc = low + (high - low) * (i / n)
        a = 1 - math.exp(-2 * math.pi * fc / RATE)
        y += a * (rng.uniform(-1, 1) - y)
        y2 += a * (y - y2)
        if swell:
            env = math.sin(math.pi * i / n) ** 2
        else:
            env = math.exp(-decay * t) * min(1.0, t / 0.002)
        out.append(y2 * env * volume * 3)
    return out


def mix(parts, seconds):
    """Lays sounds on top of each other. parts = [(start_seconds, samples)]."""
    out = [0.0] * int(RATE * seconds)
    for start, samples in parts:
        k = int(RATE * start)
        for i, s in enumerate(samples):
            if k + i < len(out):
                out[k + i] += s
    return out


def echo(samples, delay=0.09, strength=0.25, extra=0.3):
    d = int(RATE * delay)
    out = samples + [0.0] * int(RATE * extra)
    for i in range(d, len(out)):
        out[i] += out[i - d] * strength
    return out


def save(name, samples):
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, name)
    with wave.open(path, 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b''.join(
            struct.pack('<h', int(max(-1.0, min(1.0, s)) * 32767))
            for s in samples))
    print('made', path, os.path.getsize(path) // 1024, 'KB')


# Notes (Hz)
G5, C6, D6, E6, G6, A6, B6, C7, E7 = (
    784.0, 1046.5, 1174.7, 1318.5, 1568.0, 1760.0, 1975.5, 2093.0, 2637.0)

# ---------- Movement and UI ----------

# Snap: crisp click when a letter is placed in a square.
save('snap.wav', mix([
    (0.000, noise(0.012, 0.22, 6000, decay=400)),
    (0.000, note(1900, 0.03, 0.18, 120)),
], 0.04))

# Bubble pop: light "select" when a square is tapped.
save('select.wav', note(420, 0.07, 0.25, 35, glide=2.2))

# Whoosh: moving to another clue, clearing a word.
save('whoosh.wav', noise(0.26, 0.20, 400, 3500, swell=True))

# Shuffle / rattle: restarting the puzzle.
save('shuffle.wav', mix(
    [(i * 0.045 + rng.uniform(0, 0.015),
      noise(0.03, rng.uniform(0.12, 0.22), rng.uniform(2500, 5000), decay=150))
     for i in range(9)],
    0.45))

# ---------- Correct moves and progress ----------

# Success ding, rising with each word solved in a row (combo).
for level, pitch in enumerate([C6, D6, E6, G6, A6], start=1):
    save(f'ding{level}.wav', echo(mix([
        (0.0, noise(0.01, 0.10, 5000, decay=300)),   # little "pop" at the start
        (0.0, note(pitch, 0.5, 0.22, 6, bell=True)),
    ], 0.5), strength=0.2))

# Unlock / power-up sparkle: using a hint.
save('sparkle.wav', echo(mix(
    [(i * 0.045, note(f, 0.25, 0.13, 12, bell=True))
     for i, f in enumerate([E6, G6, B6, E7, B6, E7])],
    0.5), delay=0.07, strength=0.3))

# Level complete stinger.
save('complete.wav', echo(mix([
    (0.00, note(G5, 0.30, 0.16, 6, bell=True)),
    (0.10, note(C6, 0.30, 0.16, 6, bell=True)),
    (0.20, note(E6, 0.30, 0.16, 6, bell=True)),
    (0.30, note(G6, 0.30, 0.16, 6, bell=True)),
    (0.45, note(C6, 1.4, 0.13, 2.5, bell=True)),
    (0.45, note(E6, 1.4, 0.11, 2.5, bell=True)),
    (0.45, note(G6, 1.4, 0.11, 2.5, bell=True)),
    (0.45, note(C7, 1.4, 0.08, 2.5, bell=True)),
], 1.9), delay=0.12, strength=0.25, extra=0.4))

# ---------- Mistakes ----------

# Error buzzer: low, dull and slightly out of tune.
buzz = mix([
    (0.0, note(146, 0.35, 0.16, 5, attack=0.01)),
    (0.0, note(155, 0.35, 0.16, 5, attack=0.01)),
    (0.0, note(438, 0.35, 0.05, 9, attack=0.01)),
], 0.35)
save('buzzer.wav', buzz)

# Thud / boing: a move that is not allowed (locked square).
save('thud.wav', mix([
    (0.0, note(190, 0.18, 0.35, 14, glide=0.45)),
    (0.0, noise(0.03, 0.10, 300, decay=80)),
], 0.2))
