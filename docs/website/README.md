# splyto.eu

The public home page. `index.html` stays in the repository root because the web server
serves it from there. Everything it loads lives in this folder. There is no build step.

```text
index.html              page content
site/css/base.css       tokens, reset, typography
site/css/components.css store badges, tick lists, ribbons, tiles
site/css/phone.css      the illustrated phone and its sample screens
site/css/sections.css   page sections, in page order
site/js/main.js         ribbon drift while scrolling
site/images/icons.svg   icon sprite, used with <use href="/site/images/icons.svg#name">
site/images/logo.svg    Splyto logo
site/images/map-*.svg   map artwork
site/images/ribbons/    decorative ribbons
```

## Changing things

- After changing `site/css` or `site/js`, raise the `?v=` number on those files in
  `index.html`, so visitors don't get a cached copy with the new page.
- Ribbons and maps are generated, so don't edit them by hand. Change
  `scripts/generate_site_assets.py`, or `mobile/tool/generate_quick_start_maps.py` for the
  maps, then run `python3 scripts/generate_site_assets.py` from the repository root.
- The phone screens are sample data. Map images must stay our own artwork: Mapbox terms
  don't allow distributing screenshots of their maps.
- Check feature claims against the app and `privacy.html` before publishing them.

## Preview

Start the `landing` server from `.claude/launch.json`, or run:

```bash
npx serve -p 5556 .
```

Paths start at the site root, so opening `index.html` directly from disk won't load them.
