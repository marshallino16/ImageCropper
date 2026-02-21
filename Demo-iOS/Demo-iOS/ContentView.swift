//
//  ContentView.swift
//  Demo-iOS
//

import SwiftUI
import ImageCropper

struct ContentView: View {

  // MARK: - Crop state

  @State private var ratio: CropperRatio = .r_1_1
  @State private var cropRect: CGRect? = nil

  // MARK: - Visual options

  @State private var overlayColorChoice: OverlayColorChoice = .black
  @State private var overlayOpacity: Double = 0.55
  @State private var cornerColorChoice: CornerColorChoice = .white
  @State private var cornerSize: CGFloat = 20
  @State private var cornerWeight: CGFloat = 2
  @State private var gridStyleChoice: GridStyleChoice = .ruleOfThirds
  @State private var gridColorChoice: GridColorChoice = .white
  @State private var gridLineWidth: CGFloat = 0.5
  @State private var gridOpacity: Double = 0.6
  @State private var cropShapeChoice: CropShapeChoice = .rectangle
  @State private var roundedCornerRadius: CGFloat = 12
  @State private var alwaysShowGrid: Bool = false
  @State private var bgColorChoice: BgColorChoice = .black

  // MARK: - Behavior options

  @State private var zoomMin: CGFloat = 1.0
  @State private var zoomMax: CGFloat = 5.0
  @State private var rubberBandEnabled: Bool = true
  @State private var rubberBandFactor: CGFloat = 0.35

  // MARK: - Interaction options

  @State private var doubleTapEnabled: Bool = false
  @State private var doubleTapTargetScale: CGFloat = 2.0
  @State private var hapticEnabled: Bool = false

  // MARK: - Triggers

  @State private var shouldReset: Bool = false
  @State private var shouldCrop: Bool = false
  @State private var croppedImage: UIImage? = nil
  @State private var showCroppedSheet: Bool = false

  var body: some View {
    VStack(spacing: 0) {
      // Cropper (top ~60%)
      cropperView
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height * 0.55)

      // Crop rect info
      if let rect = cropRect {
        HStack {
          Text("x=\(rect.origin.x, specifier: "%.3f") y=\(rect.origin.y, specifier: "%.3f") w=\(rect.width, specifier: "%.3f") h=\(rect.height, specifier: "%.3f")")
            .font(.system(.caption2, design: .monospaced))
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
      }

      // Controls (bottom, scrollable)
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          sectionRatio
          Divider()
          sectionCropShape
          Divider()
          sectionVisual
          Divider()
          sectionGrid
          Divider()
          sectionBehavior
          Divider()
          sectionInteractions
          Divider()
          sectionTriggers
        }
        .padding()
      }
    }
    .sheet(isPresented: $showCroppedSheet) {
      croppedImageSheet
    }
  }

  // MARK: - Cropper builder

  @ViewBuilder
  private var cropperView: some View {
    let cropper = ImageCropperView(
      image: UIImage(named: "stock")!,
      cropRect: cropRect,
      ratio: ratio
    )
    .onCropChanged { cropRect = $0 }
    // Visual
    .backgroundColor(bgColorChoice.color)
    .overlayStyle(color: overlayColorChoice.color, opacity: overlayOpacity)
    .cornerStyle(color: cornerColorChoice.color, size: cornerSize, weight: cornerWeight)
    .cropShape(resolvedCropShape)
    .alwaysShowGrid(alwaysShowGrid)
    // Grid
    .gridStyle(gridStyleChoice.style)
    .gridColor(gridColorChoice.color, lineWidth: gridLineWidth, opacity: gridOpacity)
    // Behavior
    .zoomRange(zoomMin...zoomMax)
    .rubberBandEnabled(rubberBandEnabled)
    .rubberBandFactor(rubberBandFactor)
    .snapBackAnimation(.spring(response: 0.4, dampingFraction: 0.8))
    // Interactions
    .doubleTapToZoom(enabled: doubleTapEnabled, targetScale: doubleTapTargetScale)
    .hapticFeedback(hapticEnabled)
    // Triggers
    .resetTrigger($shouldReset)
    .cropTrigger($shouldCrop)
    .onCropImage { image in
      croppedImage = image
      showCroppedSheet = true
    }

    cropper
  }

  private var resolvedCropShape: CropShape {
    switch cropShapeChoice {
    case .rectangle: return .rectangle
    case .circle: return .circle
    case .roundedRect: return .roundedRect(cornerRadius: roundedCornerRadius)
    }
  }

  // MARK: - Ratio section

  private var sectionRatio: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Aspect Ratio").font(.headline)
      HStack(spacing: 8) {
        ratioButton("1:1", .r_1_1)
        ratioButton("3:2", .r_3_2)
        ratioButton("4:3", .r_4_3)
        ratioButton("16:9", .r_16_9)
      }
    }
  }

  private func ratioButton(_ label: String, _ r: CropperRatio) -> some View {
    Button(label) {
      ratio = r
      cropRect = nil
    }
    .buttonStyle(.bordered)
  }

  // MARK: - Crop shape section

  private var sectionCropShape: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Crop Shape").font(.headline)
      Picker("Shape", selection: $cropShapeChoice) {
        Text("Rectangle").tag(CropShapeChoice.rectangle)
        Text("Circle").tag(CropShapeChoice.circle)
        Text("Rounded Rect").tag(CropShapeChoice.roundedRect)
      }
      .pickerStyle(.segmented)

      if cropShapeChoice == .roundedRect {
        HStack {
          Text("Corner radius:")
          Slider(value: $roundedCornerRadius, in: 0...50, step: 1)
          Text("\(Int(roundedCornerRadius))")
            .frame(width: 30, alignment: .trailing)
        }
      }
    }
  }

  // MARK: - Visual section

  private var sectionVisual: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Visual").font(.headline)

      HStack {
        Text("Background:")
        Picker("", selection: $bgColorChoice) {
          ForEach(BgColorChoice.allCases) { c in
            Text(c.rawValue.capitalized).tag(c)
          }
        }
      }

      HStack {
        Text("Overlay color:")
        Picker("", selection: $overlayColorChoice) {
          ForEach(OverlayColorChoice.allCases) { c in
            Text(c.rawValue.capitalized).tag(c)
          }
        }
      }

      HStack {
        Text("Overlay opacity:")
        Slider(value: $overlayOpacity, in: 0...1, step: 0.05)
        Text("\(overlayOpacity, specifier: "%.2f")")
          .frame(width: 36, alignment: .trailing)
      }

      HStack {
        Text("Corner color:")
        Picker("", selection: $cornerColorChoice) {
          ForEach(CornerColorChoice.allCases) { c in
            Text(c.rawValue.capitalized).tag(c)
          }
        }
      }

      HStack {
        Text("Corner size:")
        Slider(value: $cornerSize, in: 5...50, step: 1)
        Text("\(Int(cornerSize))")
          .frame(width: 30, alignment: .trailing)
      }

      HStack {
        Text("Corner weight:")
        Slider(value: $cornerWeight, in: 1...8, step: 0.5)
        Text("\(cornerWeight, specifier: "%.1f")")
          .frame(width: 30, alignment: .trailing)
      }
    }
  }

  // MARK: - Grid section

  private var sectionGrid: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Grid").font(.headline)

      Picker("Style", selection: $gridStyleChoice) {
        ForEach(GridStyleChoice.allCases) { s in
          Text(s.rawValue).tag(s)
        }
      }

      HStack {
        Text("Grid color:")
        Picker("", selection: $gridColorChoice) {
          ForEach(GridColorChoice.allCases) { c in
            Text(c.rawValue.capitalized).tag(c)
          }
        }
      }

      HStack {
        Text("Line width:")
        Slider(value: $gridLineWidth, in: 0.25...3, step: 0.25)
        Text("\(gridLineWidth, specifier: "%.2f")")
          .frame(width: 36, alignment: .trailing)
      }

      HStack {
        Text("Grid opacity:")
        Slider(value: $gridOpacity, in: 0...1, step: 0.05)
        Text("\(gridOpacity, specifier: "%.2f")")
          .frame(width: 36, alignment: .trailing)
      }

      Toggle("Always show grid", isOn: $alwaysShowGrid)
    }
  }

  // MARK: - Behavior section

  private var sectionBehavior: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Behavior").font(.headline)

      HStack {
        Text("Zoom min:")
        Slider(value: $zoomMin, in: 0.5...2, step: 0.1)
        Text("\(zoomMin, specifier: "%.1f")")
          .frame(width: 30, alignment: .trailing)
      }

      HStack {
        Text("Zoom max:")
        Slider(value: $zoomMax, in: 2...10, step: 0.5)
        Text("\(zoomMax, specifier: "%.1f")")
          .frame(width: 30, alignment: .trailing)
      }

      Toggle("Rubber band effect", isOn: $rubberBandEnabled)

      if rubberBandEnabled {
        HStack {
          Text("Rubber factor:")
          Slider(value: $rubberBandFactor, in: 0...1, step: 0.05)
          Text("\(rubberBandFactor, specifier: "%.2f")")
            .frame(width: 36, alignment: .trailing)
        }
      }
    }
  }

  // MARK: - Interactions section

  private var sectionInteractions: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Interactions").font(.headline)

      Toggle("Double-tap to zoom", isOn: $doubleTapEnabled)

      if doubleTapEnabled {
        HStack {
          Text("Target scale:")
          Slider(value: $doubleTapTargetScale, in: 1.5...5, step: 0.5)
          Text("\(doubleTapTargetScale, specifier: "%.1f")")
            .frame(width: 30, alignment: .trailing)
        }
      }

      Toggle("Haptic feedback", isOn: $hapticEnabled)
    }
  }

  // MARK: - Triggers section

  private var sectionTriggers: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Actions").font(.headline)

      HStack(spacing: 12) {
        Button("Reset") {
          shouldReset = true
        }
        .buttonStyle(.bordered)

        Button("Export Crop") {
          shouldCrop = true
        }
        .buttonStyle(.bordered)
      }
    }
  }

  // MARK: - Cropped image sheet

  private var croppedImageSheet: some View {
    VStack(spacing: 16) {
      Text("Cropped Image").font(.headline)

      if let img = croppedImage {
        Image(uiImage: img)
          .resizable()
          .scaledToFit()
          .frame(maxWidth: 300, maxHeight: 300)
          .background(Color(white: 0.1))
          .cornerRadius(8)

        Text("Size: \(Int(img.size.width)) x \(Int(img.size.height))")
          .font(.system(.caption, design: .monospaced))
          .foregroundColor(.secondary)
      }

      Button("Close") {
        showCroppedSheet = false
      }
      .buttonStyle(.bordered)
    }
    .padding(24)
  }
}

// MARK: - Choice enums

private enum CropShapeChoice: String, CaseIterable, Identifiable {
  case rectangle, circle, roundedRect
  var id: String { rawValue }
}

private enum GridStyleChoice: String, CaseIterable, Identifiable {
  case ruleOfThirds = "Rule of Thirds"
  case goldenRatio = "Golden Ratio"
  case diagonal = "Diagonal"
  case crosshair = "Crosshair"
  case none = "None"
  var id: String { rawValue }

  var style: GridStyle {
    switch self {
    case .ruleOfThirds: return .ruleOfThirds
    case .goldenRatio: return .goldenRatio
    case .diagonal: return .diagonal
    case .crosshair: return .crosshair
    case .none: return .none
    }
  }
}

private enum OverlayColorChoice: String, CaseIterable, Identifiable {
  case black, white
  var id: String { rawValue }
  var color: Color {
    switch self {
    case .black: return .black
    case .white: return .white
    }
  }
}

private enum CornerColorChoice: String, CaseIterable, Identifiable {
  case white, yellow, green, red
  var id: String { rawValue }
  var color: Color {
    switch self {
    case .white: return .white
    case .yellow: return .yellow
    case .green: return .green
    case .red: return .red
    }
  }
}

private enum GridColorChoice: String, CaseIterable, Identifiable {
  case white, yellow, red, blue
  var id: String { rawValue }
  var color: Color {
    switch self {
    case .white: return .white
    case .yellow: return .yellow
    case .red: return .red
    case .blue: return .blue
    }
  }
}

private enum BgColorChoice: String, CaseIterable, Identifiable {
  case black, white, transparent
  var id: String { rawValue }
  var color: Color {
    switch self {
    case .black: return .black
    case .white: return .white
    case .transparent: return .clear
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
