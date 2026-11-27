"""Draws the Assam Crossword app icon as PNG files (no extra packages).

A small crossword on forest green: ASSAM across the top in gold squares,
with cream squares crossing it. Run from the project folder:
    python3 tool/make_icon.py
"""
import os
import struct
import zlib

OUT = 'assets/icon'
SIZE = 1024

GREEN = (27, 94, 32, 255)       # forest green, the app's main colour
DARK = (20, 70, 24, 255)        # letters
CREAM = (255, 248, 231, 255)    # empty squares
GOLD = (242, 183, 5, 255)       # highlighted word
CLEAR = (0, 0, 0, 0)

# 5 x 7 pixel letters
FONT = {
    'A': ["01110", "10001", "10001", "11111", "10001", "10001", "10001"],
    'S': ["01111", "10000", "10000", "01110", "00001", "00001", "11110"],
    'M': ["10001", "11011", "10101", "10101", "10001", "10001", "10001"],
}

# The crossword: letters are gold squares, '.' is a cream square,
# ' ' is no square.
GRID = [
    "ASSAM",
    ". . .",
    ".....",
    ".   .",
    ".   .",
]


def blank(colour):
    return [[colour] * SIZE for _ in range(SIZE)]


def rounded_rect(img, x0, y0, w, h, r, colour):
    for y in range(max(0, y0), min(SIZE, y0 + h)):
        for x in range(max(0, x0), min(SIZE, x0 + w)):
            dx = max(x0 + r - x, 0, x - (x0 + w - 1 - r))
            dy = max(y0 + r - y, 0, y - (y0 + h - 1 - r))
            if dx * dx + dy * dy <= r * r:
                img[y][x] = colour


def letter(img, ch, cx, cy, scale, colour):
    rows = FONT[ch]
    w, h = 5 * scale, 7 * scale
    left, top = cx - w // 2, cy - h // 2
    for ry, row in enumerate(rows):
        for rx, bit in enumerate(row):
            if bit == '1':
                rounded_rect(img, left + rx * scale, top + ry * scale,
                             scale, scale, 0, colour)


def draw_grid(img, area):
    """Draws the crossword inside a square of side `area`, centred."""
    n = len(GRID)
    gap = area // 40
    cell = (area - gap * (n - 1)) // n
    start = (SIZE - (cell * n + gap * (n - 1))) // 2
    for r, row in enumerate(GRID):
        for c, ch in enumerate(row):
            if ch == ' ':
                continue
            x = start + c * (cell + gap)
            y = start + r * (cell + gap)
            fill = CREAM if ch == '.' else GOLD
            rounded_rect(img, x, y, cell, cell, cell // 7, fill)
            if ch in FONT:
                letter(img, ch, x + cell // 2, y + cell // 2,
                       max(2, cell // 8), DARK)


def save(img, name):
    os.makedirs(OUT, exist_ok=True)
    raw = b''.join(b'\x00' + b''.join(struct.pack('4B', *p) for p in row)
                   for row in img)

    def chunk(kind, data):
        body = kind + data
        return (struct.pack('>I', len(data)) + body
                + struct.pack('>I', zlib.crc32(body) & 0xffffffff))

    png = (b'\x89PNG\r\n\x1a\n'
           + chunk(b'IHDR', struct.pack('>IIBBBBB', SIZE, SIZE, 8, 6, 0, 0, 0))
           + chunk(b'IDAT', zlib.compress(raw, 9))
           + chunk(b'IEND', b''))
    path = os.path.join(OUT, name)
    with open(path, 'wb') as f:
        f.write(png)
    print('made', path, len(png) // 1024, 'KB')


# Full icon: green square with the crossword (used for older Android
# phones, the web app and the Play Store).
icon = blank(GREEN)
draw_grid(icon, 780)
save(icon, 'icon.png')

# Adaptive icon foreground: the crossword only, smaller, on a clear
# background, because Android crops adaptive icons into circles or
# rounded squares.
fore = blank(CLEAR)
draw_grid(fore, 560)
save(fore, 'foreground.png')
