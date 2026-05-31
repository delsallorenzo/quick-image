# QuickImage Info — Quick Action

A macOS **Quick Action** (Finder right-click service) that shows detailed
image metadata for the selected image(s): dimensions, file size, DPI, format,
color space, ICC profile, bit depth, and EXIF (camera, lens, capture date,
exposure).

## Why a Quick Action instead of a Quick Look extension?

On modern macOS, a Quick Look Preview Extension **cannot inject a metadata
bar** onto the system's native image preview. If your extension declares it
handles `public.image`, the system gives priority to its own built-in image
viewer and your extension is discovered but never invoked. To override it you'd
have to re-implement the entire image viewer — fragile and unreliable.

A Quick Action is the clean, supported way to surface extra metadata: it does
not fight the system, works on every recent macOS, and needs no code signing
or Development Team setup.

## What it shows

```
📷  IMG_1303.jpg
────────────────────────
Size:     4032 × 3024 px
File:     2.41 MB
DPI:      72 dpi
Format:   JPEG
Color:    Display P3
Profile:  Display P3
Depth:    8-bit · 3 ch
Camera:   Apple iPhone 15 Pro
Lens:     iPhone 15 Pro back camera
Captured: 2024-05-12 14:30:00
Exposure: ƒ/1.78 · 1/120s · ISO 64 · 24mm
```

Select multiple images and it shows each one in turn.

## Install (1 minute)

**Option A — double-click the bundle**

1. Double-click `QuickImage Info.workflow`
2. Click **Install** when prompted
3. Done — right-click any image in Finder → **Quick Actions → QuickImage Info**

**Option B — build it yourself in Automator**

1. Open **Automator** → New → **Quick Action**
2. Set *"Workflow receives current"* → **image files** in **Finder**
3. Add a **Run Shell Script** action
4. Set *Shell* to `/bin/zsh` and *Pass input* to **as arguments**
5. Paste the contents of [`quickimage-info.sh`](quickimage-info.sh)
   (everything below the shebang line)
6. Save as **QuickImage Info**

## Manage / remove

System Settings → **Privacy & Security → Extensions → Finder** (or
`~/Library/Services/`) — toggle or delete *QuickImage Info*.

## How it works

Pure native tooling, no dependencies:

- `sips -g all` → dimensions, DPI, bit depth, channels, alpha, color space, ICC profile, format
- `mdls` (Spotlight) → EXIF: camera make/model, lens, capture date, ISO, aperture, shutter, focal length
- `osascript` → the result dialog
