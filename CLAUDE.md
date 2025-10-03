# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a static website for **Posix Party** - a monthly GNU/Linux meetup held at The Inventor Center in Kingsport, TN. The site features:

- A terminal-style interface with POSIX-themed green/gold color scheme
- Dynamic article loading system built in vanilla JavaScript
- Custom markdown parsing and syntax highlighting
- Simulated terminal commands for navigation

## Architecture

### Core Components

- **index.html** - Single-page application containing all HTML, CSS, and JavaScript
- **articles/** - Directory containing markdown articles and metadata
- **articles/articles.json** - Metadata registry for all articles (title, date, tags, emoji)
- **deploy.sh** - Deployment script using rsync to push to server

### Article System

The site uses a lightweight article management system:

1. **Content Creation**: Articles are written in markdown format in the `articles/` directory
2. **Metadata Management**: Each article must be registered in `articles/articles.json` with:
   - title: Display title for the article
   - date: Publication date (YYYY-MM-DD format)
   - tags: Array of categorization tags
   - emoji: Icon to display next to the article
3. **Dynamic Loading**: Articles are fetched via JavaScript and parsed with custom markdown processor

### Terminal Interface

The site simulates a terminal environment with commands:
- `ls` - List files in current directory
- `cd [dir]` - Change directory (articles/ or ~)
- `cat [file]` - Display article content
- `tree` - Show directory structure with articles sorted by date
- `pwd`, `whoami`, `help`, `clear`, `back`

## Development Commands

### Deployment
```bash
./deploy.sh
```
Syncs the site to the production server via rsync, excluding .git/, archive/, and .well-known/ directories.

### Local Development
No build process required - open `index.html` directly in a browser or serve with any static file server:
```bash
python -m http.server 8000
```

## Adding New Articles

1. Create a new markdown file in `articles/` directory
2. Add article metadata to `articles/articles.json`:
   ```json
   "filename.md": {
     "title": "Article Title",
     "date": "YYYY-MM-DD",
     "tags": ["tag1", "tag2"],
     "emoji": "🐧"
   }
   ```
3. Deploy using `./deploy.sh`

## Branding & Theme

- **Color Scheme**: POSIX green (#3CB371) and gold (#FFD700) on dark background
- **Terminal Prompt**: `posixparty@kingsport:~$`
- **Focus**: Monthly meetup articles serving as basis for presentations/discussions

## Real Star System

The site features an astronomically accurate starfield background:

### Technical Implementation

- **Star Catalog**: Real star data loaded from `stars.json` (100+ bright stars with actual RA/Dec coordinates)
- **Procedural Stars**: 400 additional fainter stars with randomly generated but valid celestial coordinates
- **Projection**: Azimuthal equidistant (fisheye) projection, same as planetarium domes
  - Center of screen = Zenith (directly overhead)
  - Edges of screen = Horizon
  - Azimuth determines position around the circle
- **Real-time Calculations**:
  - Local Sidereal Time (LST) based on observer location and current time
  - Converts celestial coordinates (RA/Dec) to horizon coordinates (Alt/Az)
  - Only displays stars above the horizon
  - Updates every second

### Astronomical Accuracy

The system uses proper astronomical formulas:
- Greenwich Mean Sidereal Time (GMST) calculation
- Local Sidereal Time from longitude
- Coordinate transformation from equatorial (RA/Dec) to horizontal (Alt/Az)
- Geolocation API for observer position

### Visual Features

- Star size based on magnitude (brighter = larger)
- Color-coded by spectral type (emerald, sapphire, ruby, amethyst, topaz, aquamarine)
- Parallax scrolling with depth layers
- Twinkling animation with staggered delays
- Hover tooltips showing star names for cataloged stars

### Sky Info Display

Real-time astronomical data shown in bottom-left corner:
- **LST**: Local Sidereal Time (HH:MM:SS)
- **Location**: Observer coordinates (from geolocation)
- **Visible**: Count of stars currently above horizon

## Code Style Notes

- Vanilla JavaScript with no external dependencies
- CSS uses custom properties for theming
- Markdown parsing handles code blocks, headers, bold/italic, and links
- Terminal simulation includes loading animations and command history
