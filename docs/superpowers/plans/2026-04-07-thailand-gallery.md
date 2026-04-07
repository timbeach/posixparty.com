# Thailand 2026 Photo Gallery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a standalone photo gallery page at `thailand_2026/index.html` with responsive grid, lightbox viewer, and batch zip download.

**Architecture:** Single HTML file (no build step), reads `photos.json` manifest to render a CSS grid of lazy-loaded images. Lightbox modal for full-size viewing with keyboard nav. JSZip for client-side batch download. Dark theme matching posixparty.com aesthetic.

**Tech Stack:** Vanilla HTML/CSS/JS, JSZip (CDN), native lazy loading

---

### Task 1: File Structure & Photo Manifest

**Files:**
- Create: `thailand_2026/index.html`
- Create: `thailand_2026/photos.json`
- Create: `thailand_2026/photos/` (empty directory with .gitkeep)

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p /home/trashh_panda/code/PROJECTS/VULTR_0/sites/posixparty.com/thailand_2026/photos
touch /home/trashh_panda/code/PROJECTS/VULTR_0/sites/posixparty.com/thailand_2026/photos/.gitkeep
```

- [ ] **Step 2: Create photos.json manifest with sample data**

Create `thailand_2026/photos.json`:
```json
[
  { "file": "sample.jpg", "caption": "Sample photo" }
]
```

This will be replaced with real photos later. The gallery should handle an empty array gracefully.

- [ ] **Step 3: Create the HTML skeleton**

Create `thailand_2026/index.html` with:
- DOCTYPE, meta viewport, charset
- Title: "Thailand 2026 - Posix Party"
- Google Fonts link (Share Tech Mono)
- JSZip CDN script tag
- Empty `<style>` and `<script>` blocks
- Basic HTML structure:
  - `<header>` with title "Thailand 2026" and controls container
  - `<div id="gallery">` for the photo grid
  - `<div id="lightbox">` for the modal overlay
  - `<div id="download-bar">` sticky bottom bar (hidden by default)

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Thailand 2026 - Posix Party</title>
  <link rel="icon" type="image/png" sizes="32x32" href="../favicon-32x32.png" />
  <link href="https://fonts.googleapis.com/css2?family=Share+Tech+Mono&display=swap" rel="stylesheet" />
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>
  <style>
    /* styles added in Task 2 */
  </style>
</head>
<body>
  <header>
    <h1><a href="../" style="color: inherit; text-decoration: none;">Posix Party</a> / Thailand 2026</h1>
    <div class="controls">
      <button id="selectAllBtn" onclick="toggleSelectAll()">Select All</button>
      <button id="downloadBtn" onclick="downloadSelected()" disabled>Download Selected (0)</button>
    </div>
  </header>
  <div id="gallery"></div>
  <div id="lightbox" class="hidden">
    <button class="lb-close" onclick="closeLightbox()">&times;</button>
    <button class="lb-prev" onclick="navLightbox(-1)">&#8249;</button>
    <button class="lb-next" onclick="navLightbox(1)">&#8250;</button>
    <img id="lb-img" src="" alt="" />
    <div id="lb-caption"></div>
    <button class="lb-download" onclick="downloadCurrent()">Download</button>
  </div>
  <div id="download-bar" class="hidden">
    <span id="bar-count">0 photos selected</span>
    <button onclick="downloadSelected()">Download .zip</button>
  </div>
  <div id="zip-progress" class="hidden">
    <div id="zip-progress-text">Zipping...</div>
    <div id="zip-progress-bar"><div id="zip-progress-fill"></div></div>
  </div>
  <script>
    /* JS added in Tasks 3-6 */
  </script>
</body>
</html>
```

- [ ] **Step 4: Commit**

```bash
git add thailand_2026/
git commit -m "feat: scaffold Thailand gallery page"
```

---

### Task 2: CSS Styling

**Files:**
- Modify: `thailand_2026/index.html` (replace `<style>` block)

- [ ] **Step 1: Write all CSS**

Replace the `<style>` comment with complete styles:

```css
* { margin: 0; padding: 0; box-sizing: border-box; }

body {
  background: #0a0e0a;
  color: #3CB371;
  font-family: 'Share Tech Mono', monospace;
  min-height: 100vh;
}

header {
  padding: 1.5rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 1rem;
  border-bottom: 1px solid rgba(60, 179, 113, 0.2);
}

header h1 {
  font-size: 1.4rem;
  color: #FFD700;
  font-weight: 400;
}

.controls {
  display: flex;
  gap: 0.75rem;
}

.controls button, .lb-download, #download-bar button {
  background: transparent;
  border: 1px solid #3CB371;
  color: #3CB371;
  padding: 0.5rem 1rem;
  font-family: inherit;
  font-size: 0.85rem;
  cursor: pointer;
  border-radius: 3px;
  transition: all 0.2s ease;
}

.controls button:hover, .lb-download:hover, #download-bar button:hover {
  background: rgba(60, 179, 113, 0.15);
  box-shadow: 0 0 8px rgba(60, 179, 113, 0.3);
}

.controls button:disabled {
  opacity: 0.4;
  cursor: default;
}

.controls button:disabled:hover {
  background: transparent;
  box-shadow: none;
}

/* Gallery Grid */
#gallery {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1rem;
  padding: 1.5rem 2rem;
}

.photo-card {
  position: relative;
  overflow: hidden;
  border-radius: 4px;
  border: 1px solid rgba(60, 179, 113, 0.15);
  cursor: pointer;
  transition: border-color 0.2s ease, box-shadow 0.2s ease;
}

.photo-card:hover {
  border-color: #3CB371;
  box-shadow: 0 0 12px rgba(60, 179, 113, 0.2);
}

.photo-card.selected {
  border-color: #FFD700;
  box-shadow: 0 0 12px rgba(255, 215, 0, 0.3);
}

.photo-card img {
  width: 100%;
  height: 250px;
  object-fit: cover;
  display: block;
  transition: transform 0.3s ease;
}

.photo-card:hover img {
  transform: scale(1.03);
}

.photo-card .checkbox {
  position: absolute;
  top: 8px;
  right: 8px;
  width: 24px;
  height: 24px;
  border: 2px solid rgba(255, 255, 255, 0.6);
  border-radius: 3px;
  background: rgba(0, 0, 0, 0.5);
  cursor: pointer;
  z-index: 2;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.2s ease;
}

.photo-card:hover .checkbox,
.photo-card.selected .checkbox {
  opacity: 1;
}

.photo-card.selected .checkbox {
  background: #FFD700;
  border-color: #FFD700;
}

.photo-card.selected .checkbox::after {
  content: '\2713';
  color: #0a0e0a;
  font-size: 14px;
  font-weight: 700;
}

.photo-card .caption {
  padding: 0.5rem 0.75rem;
  font-size: 0.8rem;
  color: rgba(255, 255, 255, 0.6);
  background: rgba(0, 0, 0, 0.3);
}

/* Lightbox */
#lightbox {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0, 0, 0, 0.95);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  flex-direction: column;
  gap: 1rem;
}

#lightbox.hidden { display: none; }

#lb-img {
  max-width: 90vw;
  max-height: 80vh;
  object-fit: contain;
  border-radius: 4px;
}

#lb-caption {
  color: rgba(255, 255, 255, 0.7);
  font-size: 0.9rem;
  text-align: center;
  min-height: 1.2em;
}

.lb-close {
  position: absolute;
  top: 1rem;
  right: 1.5rem;
  background: none;
  border: none;
  color: white;
  font-size: 2.5rem;
  cursor: pointer;
  z-index: 10000;
  line-height: 1;
}

.lb-prev, .lb-next {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  color: rgba(255, 255, 255, 0.7);
  font-size: 3rem;
  cursor: pointer;
  padding: 1rem;
  z-index: 10000;
  transition: color 0.2s;
}

.lb-prev:hover, .lb-next:hover { color: white; }
.lb-prev { left: 1rem; }
.lb-next { right: 1rem; }

.lb-download {
  margin-top: 0.5rem;
}

/* Download bar */
#download-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: rgba(10, 14, 10, 0.95);
  border-top: 1px solid #FFD700;
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  z-index: 9000;
}

#download-bar.hidden { display: none; }

#bar-count {
  color: #FFD700;
  font-size: 0.9rem;
}

/* Zip progress */
#zip-progress {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: #1a1a1a;
  border: 1px solid #3CB371;
  border-radius: 6px;
  padding: 2rem;
  z-index: 10001;
  text-align: center;
  min-width: 300px;
}

#zip-progress.hidden { display: none; }

#zip-progress-text {
  margin-bottom: 1rem;
  font-size: 0.9rem;
}

#zip-progress-bar {
  height: 4px;
  background: rgba(60, 179, 113, 0.2);
  border-radius: 2px;
  overflow: hidden;
}

#zip-progress-fill {
  height: 100%;
  background: #3CB371;
  width: 0%;
  transition: width 0.3s ease;
}

/* Mobile */
@media (max-width: 768px) {
  header { padding: 1rem; flex-direction: column; align-items: flex-start; }
  header h1 { font-size: 1.1rem; }
  #gallery { grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); padding: 1rem; gap: 0.75rem; }
  .photo-card img { height: 150px; }
  .photo-card .checkbox { opacity: 1; }
  .lb-prev, .lb-next { font-size: 2rem; }
}
```

- [ ] **Step 2: Commit**

```bash
git add thailand_2026/index.html
git commit -m "feat: add gallery CSS styling"
```

---

### Task 3: Gallery Grid Rendering

**Files:**
- Modify: `thailand_2026/index.html` (add JS in `<script>` block)

- [ ] **Step 1: Write gallery initialization and rendering JS**

Replace the `<script>` comment with:

```javascript
let photos = [];
let selected = new Set();
let currentLightboxIndex = -1;

async function init() {
  try {
    const res = await fetch('photos.json');
    photos = await res.json();
  } catch (e) {
    photos = [];
  }
  renderGallery();
}

function renderGallery() {
  const gallery = document.getElementById('gallery');
  if (photos.length === 0) {
    gallery.innerHTML = '<p style="color: rgba(255,255,255,0.4); grid-column: 1/-1; text-align: center; padding: 4rem 0;">Photos coming soon...</p>';
    return;
  }
  gallery.innerHTML = photos.map((photo, i) => `
    <div class="photo-card${selected.has(i) ? ' selected' : ''}" data-index="${i}">
      <div class="checkbox" onclick="event.stopPropagation(); toggleSelect(${i})"></div>
      <img src="photos/${photo.file}" alt="${photo.caption || ''}" loading="lazy" onclick="openLightbox(${i})" />
      ${photo.caption ? `<div class="caption">${photo.caption}</div>` : ''}
    </div>
  `).join('');
}

function updateSelectionUI() {
  const count = selected.size;
  const downloadBtn = document.getElementById('downloadBtn');
  const downloadBar = document.getElementById('download-bar');
  const barCount = document.getElementById('bar-count');
  const selectAllBtn = document.getElementById('selectAllBtn');

  downloadBtn.disabled = count === 0;
  downloadBtn.textContent = `Download Selected (${count})`;
  barCount.textContent = `${count} photo${count !== 1 ? 's' : ''} selected`;

  if (count > 0) {
    downloadBar.classList.remove('hidden');
  } else {
    downloadBar.classList.add('hidden');
  }

  selectAllBtn.textContent = count === photos.length ? 'Deselect All' : 'Select All';

  // Update card visual state
  document.querySelectorAll('.photo-card').forEach(card => {
    const idx = parseInt(card.dataset.index);
    card.classList.toggle('selected', selected.has(idx));
  });
}

function toggleSelect(index) {
  if (selected.has(index)) {
    selected.delete(index);
  } else {
    selected.add(index);
  }
  updateSelectionUI();
}

function toggleSelectAll() {
  if (selected.size === photos.length) {
    selected.clear();
  } else {
    photos.forEach((_, i) => selected.add(i));
  }
  updateSelectionUI();
}

init();
```

- [ ] **Step 2: Commit**

```bash
git add thailand_2026/index.html
git commit -m "feat: add gallery grid rendering and selection"
```

---

### Task 4: Lightbox Viewer

**Files:**
- Modify: `thailand_2026/index.html` (append to `<script>` block)

- [ ] **Step 1: Write lightbox functions**

Append after `init()` call:

```javascript
function openLightbox(index) {
  currentLightboxIndex = index;
  const photo = photos[index];
  const lb = document.getElementById('lightbox');
  const img = document.getElementById('lb-img');
  const caption = document.getElementById('lb-caption');

  img.src = `photos/${photo.file}`;
  img.alt = photo.caption || '';
  caption.textContent = photo.caption || '';
  lb.classList.remove('hidden');
  document.body.style.overflow = 'hidden';
}

function closeLightbox() {
  document.getElementById('lightbox').classList.add('hidden');
  document.body.style.overflow = '';
  currentLightboxIndex = -1;
}

function navLightbox(direction) {
  if (photos.length === 0) return;
  currentLightboxIndex = (currentLightboxIndex + direction + photos.length) % photos.length;
  const photo = photos[currentLightboxIndex];
  document.getElementById('lb-img').src = `photos/${photo.file}`;
  document.getElementById('lb-img').alt = photo.caption || '';
  document.getElementById('lb-caption').textContent = photo.caption || '';
}

function downloadCurrent() {
  if (currentLightboxIndex < 0) return;
  const photo = photos[currentLightboxIndex];
  const a = document.createElement('a');
  a.href = `photos/${photo.file}`;
  a.download = photo.file;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
}

// Keyboard navigation
document.addEventListener('keydown', (e) => {
  if (document.getElementById('lightbox').classList.contains('hidden')) return;
  if (e.key === 'Escape') closeLightbox();
  if (e.key === 'ArrowLeft') navLightbox(-1);
  if (e.key === 'ArrowRight') navLightbox(1);
});

// Close lightbox on backdrop click
document.getElementById('lightbox').addEventListener('click', (e) => {
  if (e.target === document.getElementById('lightbox')) closeLightbox();
});
```

- [ ] **Step 2: Add touch swipe support**

Append after backdrop click handler:

```javascript
// Touch swipe support for lightbox
let touchStartX = 0;
let touchEndX = 0;

document.getElementById('lightbox').addEventListener('touchstart', (e) => {
  touchStartX = e.changedTouches[0].screenX;
}, { passive: true });

document.getElementById('lightbox').addEventListener('touchend', (e) => {
  touchEndX = e.changedTouches[0].screenX;
  const diff = touchStartX - touchEndX;
  if (Math.abs(diff) > 50) {
    navLightbox(diff > 0 ? 1 : -1);
  }
});
```

- [ ] **Step 3: Commit**

```bash
git add thailand_2026/index.html
git commit -m "feat: add lightbox viewer with keyboard and swipe nav"
```

---

### Task 5: Batch Zip Download

**Files:**
- Modify: `thailand_2026/index.html` (append to `<script>` block)

- [ ] **Step 1: Write batch download function**

Append to script:

```javascript
async function downloadSelected() {
  if (selected.size === 0) return;

  // Check if JSZip is available
  if (typeof JSZip === 'undefined') {
    alert('Zip library not loaded. Please try again or download photos individually from the lightbox.');
    return;
  }

  const progress = document.getElementById('zip-progress');
  const progressText = document.getElementById('zip-progress-text');
  const progressFill = document.getElementById('zip-progress-fill');
  progress.classList.remove('hidden');

  const zip = new JSZip();
  const selectedPhotos = [...selected].map(i => photos[i]);
  let completed = 0;

  for (const photo of selectedPhotos) {
    progressText.textContent = `Zipping ${completed + 1} of ${selectedPhotos.length}...`;
    progressFill.style.width = `${(completed / selectedPhotos.length) * 100}%`;

    try {
      const response = await fetch(`photos/${photo.file}`);
      const blob = await response.blob();
      zip.file(photo.file, blob);
    } catch (e) {
      console.error(`Failed to fetch ${photo.file}:`, e);
    }
    completed++;
  }

  progressText.textContent = 'Creating zip file...';
  progressFill.style.width = '100%';

  try {
    const blob = await zip.generateAsync({ type: 'blob' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'thailand_2026_photos.zip';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  } catch (e) {
    alert('Failed to create zip file. Try downloading photos individually.');
    console.error(e);
  }

  progress.classList.add('hidden');
  progressFill.style.width = '0%';
}
```

- [ ] **Step 2: Commit**

```bash
git add thailand_2026/index.html
git commit -m "feat: add batch zip download with progress"
```

---

### Task 6: Deploy and Verify

**Files:**
- No new files

- [ ] **Step 1: Update photos.json to empty array for clean deploy**

Update `thailand_2026/photos.json` to:
```json
[]
```

This shows the "Photos coming soon..." message until real photos are added.

- [ ] **Step 2: Deploy**

```bash
cd /home/trashh_panda/code/PROJECTS/VULTR_0/sites/posixparty.com && ./deploy.sh
```

- [ ] **Step 3: Commit and push**

```bash
git add thailand_2026/
git commit -m "feat: Thailand 2026 photo gallery - complete"
git push
```
