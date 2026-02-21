<p align="center">
  <h1 align="center">SwiftUI-ImageCropper</h1>
  <p align="center">
    A modern, ratio-based image cropper for SwiftUI.<br>
    The crop frame stays fixed while the user pans and zooms the image underneath —<br>just like iOS Photos or Instagram.
  </p>
  <p align="center">
    <img src="https://img.shields.io/github/v/tag/marshallino16/ImageCropper?style=flat-square&label=version&color=blue" alt="Version">
    <img src="https://img.shields.io/badge/Swift_5.3+-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift 5.3+">
    <img src="https://img.shields.io/badge/SPM-compatible-4BC51D?style=flat-square&logo=swift" alt="SPM">
    <img src="https://img.shields.io/badge/iOS_13+-000000?style=flat-square&logo=apple" alt="iOS 13+">
    <img src="https://img.shields.io/badge/macOS_10.15+-000000?style=flat-square&logo=apple" alt="macOS 10.15+">
    <img src="https://img.shields.io/github/license/marshallino16/ImageCropper?style=flat-square" alt="License">
  </p>
</p>

<br>

<p align="center">
  <img width="700" alt="SwiftUI-ImageCropper Demo" src="https://user-images.githubusercontent.com/1506323/102635181-4293b700-4153-11eb-81aa-1175d58b4464.png">
</p>

<br>

---

## Highlights

- **Pan & pinch-to-zoom** with anchor at finger midpoint
- **Rubber-band** elastic drag beyond crop bounds with animated snap-back
- **Multiple grid styles** — rule of thirds, golden ratio, diagonal, crosshair
- **Crop shapes** — rectangle, circle, rounded rectangle
- **Double-tap/click** to toggle zoom
- **Programmatic reset & image export** via binding triggers
- **Haptic feedback** on iOS when dragging past bounds
- **Preset aspect ratios** — `1:1`, `3:2`, `4:3`, `16:9` (or define your own)
- **Normalized `CGRect` output** (0–1 range) for easy image processing
- **Fully configurable** via SwiftUI modifiers — all options are opt-in
- **Cross-platform** — iOS 13+ and macOS 10.15+

---

## Installation

### Swift Package Manager

Add the package to your Xcode project:

**File** → **Add Package Dependencies** → paste the URL:

```
https://github.com/marshallino16/ImageCropper
```

Or add it to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/marshallino16/ImageCropper", from: "1.0.0")
]
```

---

## Quick Start

### iOS

```swift
import ImageCropper

ImageCropperView(image: UIImage(named: "photo")!, ratio: .r_1_1)
  .onCropChanged { cropRect in
    print(cropRect) // normalized CGRect (0–1)
  }
```

### macOS

```swift
import ImageCropper

ImageCropperView(image: NSImage(named: "photo")!, ratio: .r_1_1)
  .onCropChanged { cropRect in
    print(cropRect)
  }
```

### SwiftUI Image (cross-platform)

```swift
ImageCropperView(image: Image("photo"),
                 imageSize: CGSize(width: 1920, height: 1080),
                 ratio: .r_16_9)
  .onCropChanged { cropRect in
    print(cropRect)
  }
```

---

## Full Example

```swift
@State private var shouldReset = false
@State private var shouldCrop = false

ImageCropperView(image: UIImage(named: "photo")!, ratio: .r_4_3)
  .onCropChanged { cropRect in print(cropRect) }

  // Visual
  .backgroundColor(.black)
  .overlayStyle(color: .black, opacity: 0.55)
  .cornerStyle(color: .white, size: 20, weight: 2)
  .cropShape(.circle)
  .gridStyle(.goldenRatio)
  .gridColor(.white, lineWidth: 0.5, opacity: 0.6)
  .alwaysShowGrid(true)

  // Behavior
  .zoomRange(1.0...8.0)
  .snapBackAnimation(.spring(response: 0.4, dampingFraction: 0.8))
  .rubberBandEnabled(true)
  .rubberBandFactor(0.35)

  // Interactions
  .doubleTapToZoom(enabled: true, targetScale: 2.0)
  .hapticFeedback(true) // iOS only

  // Triggers
  .resetTrigger($shouldReset)
  .cropTrigger($shouldCrop)
  .onCropImage { croppedImage in
    // croppedImage is UIImage (iOS) or NSImage (macOS)
  }
```

---

## Init Parameters

| Parameter | Type | Default | Required |
|-----------|------|---------|:--------:|
| `image` | `UIImage` / `NSImage` / `Image` | — | Yes |
| `imageSize` | `CGSize` | — | Only with `Image` init |
| `cropRect` | `CGRect?` | `nil` | No |
| `ratio` | `CropperRatio` | — | Yes |

---

## Modifiers

### Core

| Modifier | Description |
|----------|-------------|
| `.onCropChanged { CGRect in }` | Called whenever the visible crop region changes |
| `.alwaysShowGrid(true)` | Show the grid permanently (default: only during interaction) |

### Visual

| Modifier | Default | Description |
|----------|---------|-------------|
| `.backgroundColor(_:)` | `.black` | Background color behind the image |
| `.overlayStyle(color:opacity:)` | black, 0.55 | Dimmed area outside the crop frame |
| `.cornerStyle(color:size:weight:)` | white, 20, 2 | Corner guide appearance |
| `.cropShape(_:)` | `.rectangle` | `.rectangle` · `.circle` · `.roundedRect(cornerRadius:)` |
| `.gridStyle(_:)` | `.ruleOfThirds` | `.ruleOfThirds` · `.goldenRatio` · `.diagonal` · `.crosshair` · `.none` |
| `.gridColor(_:lineWidth:opacity:)` | white, 0.5, 0.6 | Grid line appearance |

### Behavior

| Modifier | Default | Description |
|----------|---------|-------------|
| `.zoomRange(_:)` | `1.0...5.0` | Allowed zoom scale range |
| `.snapBackAnimation(_:)` | `.easeInOut(0.3)` | Animation when the image settles after a gesture |
| `.rubberBandEnabled(_:)` | `true` | Enable elastic drag beyond crop bounds |
| `.rubberBandFactor(_:)` | `0.35` | Dampening factor (0 = none, 1 = full stretch) |

### Interactions

| Modifier | Default | Description |
|----------|---------|-------------|
| `.doubleTapToZoom(enabled:targetScale:)` | off, 2.0 | Toggle zoom on double-tap/click |
| `.hapticFeedback(_:)` | `false` | Haptic when dragging past bounds (iOS only) |

### Triggers & Export

| Modifier | Description |
|----------|-------------|
| `.resetTrigger($binding)` | Set to `true` to reset scale & offset (auto-resets to `false`) |
| `.cropTrigger($binding)` | Set to `true` to trigger crop export (auto-resets to `false`) |
| `.onCropImage { PlatformImage in }` | Receive the cropped `UIImage`/`NSImage` when crop fires |

---

## Preset Ratios

| Preset | Value |
|--------|:-----:|
| `CropperRatio.r_1_1` | 1 : 1 |
| `CropperRatio.r_3_2` | 3 : 2 |
| `CropperRatio.r_4_3` | 4 : 3 |
| `CropperRatio.r_16_9` | 16 : 9 |

Custom ratios:
```swift
CropperRatio(width: 21, height: 9)
```

---

## Types

```swift
// Cross-platform image type alias
#if iOS
public typealias PlatformImage = UIImage
#else
public typealias PlatformImage = NSImage
#endif

// Crop shape
public enum CropShape: Equatable, Sendable {
  case rectangle
  case circle
  case roundedRect(cornerRadius: CGFloat)
}

// Grid style
public enum GridStyle: Sendable {
  case ruleOfThirds
  case goldenRatio
  case diagonal
  case crosshair
  case none
}
```

---

## Demo Apps

The repository includes two demo apps showcasing every modifier and option:

| App | Location | Description |
|-----|----------|-------------|
| **Demo-macOS** | `Demo-macOS/` | macOS app with HSplitView — cropper + sidebar controls |
| **Demo-iOS** | `Demo-iOS/` | iOS app with top cropper + scrollable controls below |

Open the workspace to build both:

```bash
open SwiftUI-ImageCropper.xcworkspace
```

---

## Architecture

```
Sources/ImageCropper/
├── ImageCropperView.swift    # Public API — SwiftUI View with all modifiers
├── CropperView.swift         # Internal UI — ZStack, gesture handling, crop math
├── CropperConfiguration.swift# All configurable values in one struct
├── CropperRatio.swift        # Aspect ratio value type with presets
├── CropShape.swift           # Rectangle / circle / rounded rect enum
├── GridStyle.swift            # Grid overlay pattern enum
├── GridOverlay.swift          # Grid drawing view (5 styles)
├── CornerGuides.swift         # L-shaped corner guide view
├── CropHoleShape.swift        # Even-odd cutout shape
├── ChangeObserver.swift       # onChange polyfill for iOS 13 / macOS 10.15
├── NativeGestureOverlay.swift # UIKit & AppKit gesture bridge
└── PlatformTypes.swift        # PlatformImage typealias + crop helper
```

**Data flow:**
`ImageCropperView` → `GeometryReader` → `CropperView` → `NativeGestureOverlay` captures gestures → crop rect computed → `.onCropChanged` fires with normalized `CGRect`

---

## Requirements

| Requirement | Minimum |
|-------------|---------|
| Xcode | 12+ |
| Swift | 5.3+ |
| iOS | 13.0+ |
| macOS | 10.15+ |

---

## License

ImageCropper is available under the **MIT license**. See the [LICENSE](LICENSE) file for details.
