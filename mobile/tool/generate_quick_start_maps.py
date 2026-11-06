#!/usr/bin/env python3
"""Generates the Quick Start map artwork. Run from mobile/.

The travel map comes only from bundled public-domain Natural Earth outlines. The city
map is an invented street plan. Neither uses or traces any Mapbox map content.
"""
import json
import math
import random

SEA, LAND, BORDER, VISITED = '#CDEBF1', '#F6F3EC', '#D5D0C5', '#8FD6BE'
OUT = 'assets/branding/'


def travel_map():
    w, h = 500, 460
    west, east, south, north = -14.0, 36.0, 28.0, 62.0

    def merc(lat):
        return math.log(math.tan(math.pi / 4 + math.radians(lat) / 2))

    top, bottom = merc(north), merc(south)

    def project(lng, lat):
        return ((lng - west) / (east - west) * w,
                (top - merc(lat)) / (top - bottom) * h)

    visited = {'Portugal', 'Spain', 'Italy', 'Latvia'}
    world = json.load(open('assets/maps/world.json', encoding='utf8'))
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">',
        f'<rect width="{w}" height="{h}" fill="{SEA}"/>',
    ]
    for feature in world['features']:
        geometry = feature['geometry']
        polygons = (geometry['coordinates'] if geometry['type'] == 'MultiPolygon'
                    else [geometry['coordinates']])
        d = []
        for polygon in polygons:
            for ring in polygon:
                lats = [p[1] for p in ring]
                lngs = [p[0] for p in ring]
                if max(lngs) < west - 5 or min(lngs) > east + 5:
                    continue
                if max(lats) < south - 5 or min(lats) > north + 5:
                    continue
                points = [project(p[0], max(min(p[1], 80), -80)) for p in ring]
                d.append('M' + 'L'.join(f'{x:.1f} {y:.1f}' for x, y in points) + 'Z')
        if d:
            fill = VISITED if feature['properties']['name'] in visited else LAND
            parts.append(f'<path d="{"".join(d)}" fill="{fill}" stroke="{BORDER}" '
                         'stroke-width="1" stroke-linejoin="round"/>')
    for lng, lat in [(-9.14, 38.72), (-3.7, 40.42), (12.5, 41.9), (24.1, 56.95)]:
        x, y = project(lng, lat)
        parts.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="15" fill="#00836B" '
                     'stroke="#FFFFFF" stroke-width="2"/>')
        parts.append(f'<path d="M{x - 6:.1f} {y:.1f}l4.5 4.5 8-9" fill="none" stroke="#FFFFFF" '
                     'stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>')
    parts.append('</svg>')
    open(OUT + 'quick_start_travel_map.svg', 'w').write('\n'.join(parts))


def city_map():
    w, h = 500, 572
    rng = random.Random(7)
    block, street, avenue = '#F4F1EA', '#FFFFFF', '#FFE6A8'
    park, water = '#C9EBD3', '#BCE3EE'
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">',
        f'<rect width="{w}" height="{h}" fill="{street}"/>',
        f'<g transform="rotate(-14 {w / 2} {h / 2})">',
    ]
    y = -160
    while y < h + 160:
        rh = rng.choice((46, 58, 70))
        x = -160
        while x < w + 160:
            bw = rng.choice((42, 56, 72))
            parts.append(f'<rect x="{x}" y="{y}" width="{bw - 7}" height="{rh - 7}" rx="3" '
                         f'fill="{park if rng.random() < .07 else block}"/>')
            x += bw
        y += rh
    for x in (70, 300):
        parts.append(f'<rect x="{x}" y="-200" width="13" height="{h + 400}" fill="{avenue}"/>')
    parts.append(f'<rect x="-200" y="250" width="{w + 400}" height="13" fill="{avenue}"/>')
    parts.append('</g>')
    parts.append(f'<path d="M-10 500C110 450 190 540 320 498S460 470 510 492V582H-10Z" fill="{water}"/>')
    parts.append('</svg>')
    open(OUT + 'quick_start_live_map.svg', 'w').write('\n'.join(parts))


travel_map()
city_map()
