#!/usr/bin/env python3
"""Generates the splyto.eu ribbon images and copies the map artwork. Run from the repo root.

The web server does not expose mobile/, so the site keeps its own copy of the maps.
The ribbon shape matches the app's Quick Start painter (quick_start_background.dart).
"""
import math
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
IMAGES = ROOT / 'site/images'
WIDTH, HEIGHT = 1440, 900
SAMPLES = 44
COLORS = {
    'teal': ('#7FD8D2', '#2FB8B0', '#2AA39C'),
    'pink': ('#F27DB6', '#E8388F', '#CC317E'),
    'green': ('#80D6B6', '#3DBB8C', '#36A57B'),
}


def band(start, control1, control2, end, width, phase):
    """Returns the path of a band that narrows along a cubic curve, so it reads as a twist."""
    p0, p1, p2, p3 = [(x * WIDTH, y * HEIGHT) for x, y in (start, control1, control2, end)]
    upper, lower = [], []
    for i in range(SAMPLES + 1):
        t = i / SAMPLES
        u = 1 - t
        x = u**3 * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t**3 * p3[0]
        y = u**3 * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t**3 * p3[1]
        dx = 3 * u * u * (p1[0] - p0[0]) + 6 * u * t * (p2[0] - p1[0]) + 3 * t * t * (p3[0] - p2[0])
        dy = 3 * u * u * (p1[1] - p0[1]) + 6 * u * t * (p2[1] - p1[1]) + 3 * t * t * (p3[1] - p2[1])
        length = math.hypot(dx, dy)
        half = width * WIDTH * (.28 + .72 * abs(math.cos(t * math.pi * 2.2 + phase))) / 2
        upper.append((x - dy / length * half, y + dx / length * half))
        lower.append((x + dy / length * half, y - dx / length * half))
    return 'M' + 'L'.join(f'{x:.0f} {y:.0f}' for x, y in upper + lower[::-1]) + 'Z'


def gradient(name):
    light, base, dark = COLORS[name]
    return (f'<linearGradient id="{name}"><stop offset="0" stop-color="{light}"/>'
            f'<stop offset=".3" stop-color="{base}"/><stop offset=".5" stop-color="{dark}"/>'
            f'<stop offset=".7" stop-color="{base}"/><stop offset="1" stop-color="{light}"/>'
            '</linearGradient>')


def write_ribbons(name, bands):
    used = sorted({color for color, *_ in bands})
    defs = ''.join(gradient(color) for color in used)
    paths = '\n'.join(f'  <path fill="url(#{color})" d="{band(*shape)}"/>' for color, *shape in bands)
    (IMAGES / f'ribbons/{name}.svg').write_text(
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {WIDTH} {HEIGHT}" '
        f'width="{WIDTH}" height="{HEIGHT}">\n  <defs>{defs}</defs>\n{paths}\n</svg>\n')


def feature_bands(main, accent):
    return [
        (main, (-.1, .78), (.3, .62), (.65, 1.0), (1.1, .78), .08, 2.1),
        (accent, (1.1, .4), (.8, .3), (.35, .62), (-.1, .56), .05, 4.0),
        (main, (-.1, .2), (.25, .14), (.45, .5), (1.1, .16), .1, .4),
    ]


def main():
    (IMAGES / 'ribbons').mkdir(parents=True, exist_ok=True)
    write_ribbons('hero', [
        ('teal', (.45, 1.1), (.72, .95), (.75, .55), (1.1, .62), .09, 2.1),
        ('pink', (1.1, .34), (.92, .3), (.68, .62), (.42, 1.05), .05, 4.0),
        ('teal', (.5, -.25), (.56, .1), (.74, .34), (1.1, .16), .1, .4),
    ])
    write_ribbons('privacy', [
        ('pink', (.55, 1.15), (.8, .9), (.86, .7), (1.1, .78), .05, 4.0),
        ('teal', (.5, 1.2), (.78, .72), (.86, .95), (1.1, .5), .08, .4),
    ])
    for name, colors in {
        'trips': ('teal', 'pink'),
        'expenses': ('green', 'teal'),
        'settle': ('teal', 'pink'),
        'budget': ('pink', 'teal'),
        'travel-map': ('green', 'pink'),
        'live-map': ('teal', 'green'),
    }.items():
        write_ribbons(name, feature_bands(*colors))

    branding = ROOT / 'mobile/assets/branding'
    shutil.copyfile(branding / 'quick_start_travel_map.svg', IMAGES / 'map-travel.svg')
    shutil.copyfile(branding / 'quick_start_live_map.svg', IMAGES / 'map-live.svg')


main()
