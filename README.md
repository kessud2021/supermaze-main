# SuperMaze v1.3.1

A fast-paced, feature-rich maze game with **Daily Challenges**, **Leaderboards**, **XP Progression**, and **100% Offline Support (PWA)**.

## 🚀 Quick Start

### Online
Visit: [SuperMaze Demo](https://kessud2021.github.io/supermaze-main/) (if hosted)

### Local Development
```bash
# Simply open index.html in a browser
# No build step required - vanilla JavaScript/HTML/CSS
open index.html
```

### Install as App
1. Load the game in a browser
2. Click the "Install" button (address bar) or use browser menu → "Install app"
3. Play offline immediately!

## 🎮 Core Features

### Gameplay
- **🎲 Random Mazes** - Procedurally generated with multiple algorithms
- **📅 Daily Challenge** - Same seed-based maze for all players each day
- **⚡ Continuous Movement** - Hold keys to move smoothly (VROOOOM mode!)
- **🏆 Victory System** - Particle effects, achievements, and leaderboards
- **📊 Replay System** - Watch your moves replayed or export/share replays

### Challenge Links
Share exact mazes via URL parameters:
```
https://domain.com/?seed=12345&size=hard
```
Friends click the link and **auto-load** the exact same maze (no menu clicks!)

### Mobile Support
- ✅ **Touch/Swipe Controls** - Full touch navigation
- ✅ **On-Screen D-Pad** - Optional overlay buttons
- ✅ **Responsive Design** - Optimized for all devices
- ✅ **PWA** - Install to home screen, play offline

## 💰 Progression System

### XP & Leveling
- Earn XP for completing mazes
- Unlock cosmetics and themes in the Shop
- Track total steps and achievements

### Achievements
- 🏃 **Speed Demon** - Complete hard maze in <30s (+100 XP)
- 🎖️ **Marathon** - Accumulate 10,000 steps (+50 XP)
- 🤐 **Pacifist** - Win without using power-ups

### Shop
Unlock with XP:
- 🎨 **Gold Theme** (1000 XP)
- 👤 **Player Skins** (500 XP each)
- 👻 **Ghost Enemy Pack** (750 XP)

## 🎨 Customization

### Themes
- 6 preset themes (Light, Dark, Blue, Green, Pink, Red)
- Custom theme creator with color picker
- Persistent localStorage storage

### Settings
- Difficulty: Easy, Medium, Hard
- Graphics: Low, Mid, High, Advanced
- Audio: Toggle all sounds on/off
- Game behavior: Pause, restart, keybinds

## 🔧 Technical Stack

| Layer | Tech |
|-------|------|
| **Frontend** | Vanilla JavaScript, HTML5, CSS3 |
| **Icons** | Bootstrap Icons v1.13.1 (1000+ icons) |
| **UI Framework** | Bootstrap 5.3.8 |
| **Storage** | LocalStorage (all data saved locally) |
| **PWA** | Service Worker + manifest.json |
| **Build** | Zero build - pure HTML/JS/CSS |

### Architecture Highlights
- **Seeded RNG** - Linear Congruential Generator for reproducible daily mazes
- **Game Loop** - 33 FPS continuous movement system
- **Canvas Rendering** - Minimap for large mazes
- **Responsive Grid** - CSS Grid-based maze display
- **Event-Driven** - Keyboard + touch event handling

## 📁 Files

```
supermaze-main/
├── index.html              # Single-file app (manifest + service worker embedded)
├── service-worker.js       # (Optional - for development/fallback)
├── manifest.json           # (Optional - for development/fallback)
├── features.txt            # Complete feature documentation
├── README.md              # This file
└── LICENSE                # MIT License
```

**Note:** The main app is completely self-contained in `index.html`:
- ✅ Manifest.json embedded as data URI in `<head>`
- ✅ Service Worker code embedded as JavaScript Blob
- ✅ All styles and logic inline
- ✅ Can be deployed as single file

## 🌐 PWA Support

### Offline Play
- **Embedded Service Worker** - Created as Blob at runtime
- **Smart Caching** - Network-first with cache fallback
- **100% Offline** - Works completely offline after first load
- **Bootstrap Icons** - Also cached for offline use

### Installation
- Add to home screen on mobile (iOS 14.5+, Android)
- Desktop shortcut on Windows/Mac/Linux
- Standalone fullscreen mode
- App icon on home screen

### App Metadata
- **Manifest** - Embedded in HTML `<head>` as data URI
- **Service Worker** - Embedded as JavaScript Blob
- **Icons** - Custom 192x192 & 512x512 SVG icons
- **Shortcuts** - Quick access to Daily Challenge & Random Maze

### How It Works
```javascript
// Service Worker is created from embedded code at runtime
const swCode = `... full service worker code ...`;
const blob = new Blob([swCode], { type: "application/javascript" });
const swUrl = URL.createObjectURL(blob);
navigator.serviceWorker.register(swUrl);
```

This approach means:
- ✅ **No separate file needed** - Everything in index.html
- ✅ **Automatic updates** - SW code updates when HTML updates
- ✅ **Better portability** - Single file deployment

## 🎯 URL Parameters

### Challenge Links
```
?seed=<number>&size=<difficulty>
```

**Example:**
```
https://supermaze.com/?seed=12345&size=hard
```

**Behavior:**
- ✅ Auto-loads maze with seed
- ✅ Skips menu (if username saved)
- ✅ Starts timer immediately
- ✅ Shows leaderboard for this challenge

## 🎮 Controls

### Keyboard
- **Arrow Keys / WASD** - Move
- **ESC / SPACE** - Pause/Resume
- **R** - Restart maze

### Mobile
- **Swipe** - Directional movement
- **D-Pad** - Tap arrow buttons
- **Touch** - Full touch support

## 🔐 Security

- ✅ XSS Prevention - HTML entity encoding
- ✅ Input Sanitization - Username validation
- ✅ JSON Validation - Safe file parsing
- ✅ URL Validation - No javascript: or data: attacks
- ✅ Color Validation - Hex-only color input

## 📊 Leaderboard

- **Persistent** - Saved in browser localStorage
- **Real-time** - Updates on maze completion
- **Filterable** - Sort by time, date, difficulty
- **Share** - Export and import replay files

## 🎵 Audio

- ✅ Step sounds (move feedback)
- ✅ Wall bump (collision feedback)
- ✅ Victory jingle (3-sec fanfare)
- ✅ UI sounds (hover/click feedback)
- ✅ Mute toggle in navbar
- ✅ Persistent audio settings

## 🚀 Performance

- **File Size** - ~200KB total (uncompressed HTML)
- **Load Time** - <500ms on 3G
- **FPS** - 33fps game loop (smooth on mobile)
- **Memory** - ~10MB max (mostly localStorage)

## 🛠️ Development

### No Build Required
```bash
# Just open it
npx http-server .
# or
python -m http.server 8000
```

### Customization
- Edit `gameSettings` for default difficulty
- Change `moveDelay` (120ms) for movement speed
- Modify colors in CSS variables
- Add maze algorithms in `generateMaze*` functions

### Browser Support
- ✅ Chrome/Edge 90+
- ✅ Firefox 88+
- ✅ Safari 14+
- ✅ Mobile Safari (iOS 14.5+)
- ✅ Android Chrome

## 📄 License

MIT License - Feel free to fork, modify, and distribute!

## 🤝 Contributing

Issues, feature requests, and pull requests welcome!

## 📝 Version History

### v1.3.1 (Current)
- Embedded manifest.json in HTML
- Bootstrap Icons integration
- Continuous movement (hold-to-move)
- Complete feature documentation

### v1.3.0
- Challenge links (URL parameters)
- Share button on victory screen
- Breadcrumb trails
- Minimap for large mazes

### v1.0.0
- Initial release
- Daily challenges
- XP progression
- PWA support

---

**Made with ❤️ and vanilla JavaScript**
