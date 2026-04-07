# Thailand 2026 Photo Gallery — Design Spec

## Overview

A standalone photo gallery page at `posixparty.com/thailand_2026/` for sharing curated Thailand trip photos with friends. Flat responsive grid, lightbox viewer, and batch zip download.

## URL & Architecture

- **Path:** `thailand_2026/index.html` — standalone page, not part of the main SPA
- **No build step** — vanilla HTML/CSS/JS like the rest of the site
- **One external dependency:** JSZip (~100KB) for client-side zip generation
- **Photo manifest:** `thailand_2026/photos.json` — array of `{ "file": "filename.jpg", "caption": "optional caption" }`
- **Photo storage:** `thailand_2026/photos/` directory containing the full-size images

## Visual Design

- Dark background matching posixparty.com aesthetic (#0a0e0a or similar)
- Green/gold accent colors consistent with the main site
- Minimal chrome — the photos are the focus
- Share Tech Mono for any text elements (title, captions, controls)
- Mobile-responsive

## Grid View

- Responsive CSS grid — uniform cells, 3-4 columns on desktop, 2 on tablet, 1 on mobile
- Images displayed with `object-fit: cover` for uniform sizing
- Native `loading="lazy"` on all `<img>` tags for performance
- No thumbnails — serve originals, CSS-sized
- Each photo has a checkbox overlay (top-right corner), hidden until hover on desktop, always visible on mobile
- Optional caption below each photo (from photos.json)

## Selection & Controls

- Top bar with: page title, "Select All" toggle, "Download Selected (X)" button
- "Download Selected" button disabled when nothing selected, shows count when active
- When 1+ photos selected, sticky bottom bar appears: "X photos selected — Download .zip"
- Clicking a checkbox toggles selection without opening lightbox

## Lightbox

- Click photo (not checkbox) opens full-size modal overlay
- Dark semi-transparent backdrop
- Left/right arrow navigation (click + keyboard arrow keys)
- Close with X button, Escape key, or clicking backdrop
- Single-image download button in lightbox
- Caption displayed below image if available
- Swipe support on mobile (touch events)

## Batch Download

- JSZip loaded from CDN or vendored locally
- On "Download Selected": fetch each selected photo, add to zip, trigger download
- Progress bar during zip creation: "Zipping X of Y..."
- Resulting file: `thailand_2026_photos.zip`
- Falls back gracefully if JSZip fails to load (individual downloads still work)

## File Structure

```
thailand_2026/
  index.html        # Standalone gallery page
  photos.json       # Photo manifest
  photos/           # Directory of full-size images
    img_001.jpg
    img_002.jpg
    ...
```

## What This Does NOT Include

- No login or authentication
- No upload functionality
- No categories, albums, or grouping
- No comments or social features
- No integration with the main SPA terminal/article system
- No thumbnail generation — originals only, lazy loaded
- No analytics or tracking

## Dependencies

- JSZip (CDN: `https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js`) — zip generation only
- Everything else is vanilla HTML/CSS/JS
