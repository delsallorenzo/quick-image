# QuickImage

A macOS Quick Look extension that overlays image metadata at the bottom of the preview.

## What it shows

| Field | Description |
|---|---|
| **Size** | Pixel dimensions (width × height) |
| **File** | File size in KB or MB |
| **DPI** | Resolution (single value or W×H if different) |
| **Format** | JPEG, PNG, TIFF, HEIC, WebP, GIF, RAW… |
| **Color** | Color space (sRGB, Display P3, Adobe RGB, CMYK…) |
| **Profile** | Embedded ICC profile name |
| **Depth** | Bit depth + alpha channel indicator |
| **Captured** | EXIF capture date (if present) |
| **Camera** | Make + model (if present) |
| **Lens** | Lens model (if present) |

## Supported formats

`JPEG · PNG · TIFF · GIF · HEIC · WebP · RAW`  
(anything conforming to `public.image`)

## Requirements

- macOS 13.0+
- Xcode 15+

## Build & Install

1. Open `QuickImage.xcodeproj` in Xcode
2. Set your **Development Team** in both targets' Signing settings
3. Change the bundle identifiers if needed (`com.yourteam.QuickImage`)
4. Build & Run the **QuickImage** target (⌘R)
5. The app installs the extension automatically — no extra steps needed
6. Press Space on any image in Finder to see it in action

## Project structure

```
QuickImage.xcodeproj
├── QuickImageApp/
│   ├── AppDelegate.swift
│   ├── Info.plist
│   └── QuickImage.entitlements
└── QuickImageExtension/
    ├── PreviewViewController.swift   ← QLPreviewingController
    ├── ImageInfoView.swift           ← SwiftUI overlay
    ├── ImageMetadataReader.swift     ← CGImageSource metadata extraction
    ├── MainInterface.storyboard
    ├── Info.plist
    └── QuickImageExtension.entitlements
```
