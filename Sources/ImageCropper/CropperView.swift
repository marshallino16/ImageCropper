//
//  CropperView.swift
//
//  Created by Anthony Fernandez on 17/12/2020.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - AnyShape (type eraser for iOS 13+ compatibility)

private struct AnyShape: Shape {
  private let pathBuilder: @Sendable (CGRect) -> Path

  init<S: Shape>(_ shape: S) {
    pathBuilder = { rect in shape.path(in: rect) }
  }

  func path(in rect: CGRect) -> Path {
    pathBuilder(rect)
  }
}

// MARK: - CropperView

struct CropperView: View {

  let image: Image
  let imageAspectRatio: CGFloat
  let containerSize: CGSize
  let initialCropRect: CGRect?
  let ratio: CropperRatio
  let config: CropperConfiguration
  var onCropChanged: ((CGRect) -> Void)?

  // Reset / Export triggers (passed as bindings, not part of config)
  var resetTrigger: Binding<Bool>?
  var cropTrigger: Binding<Bool>?
  var platformImage: PlatformImage?
  var onCropImage: ((PlatformImage) -> Void)?

  @State private var imageOffset: CGSize = .zero
  @State private var lastOffset: CGSize = .zero
  @State private var imageScale: CGFloat = 1.0
  @State private var lastScale: CGFloat = 1.0
  @State private var isInteracting: Bool = false

  // Double-tap
  @State private var isZoomedIn: Bool = false

  // Haptic (iOS only)
  #if canImport(UIKit)
  @State private var hasTriggeredHaptic: Bool = false
  #endif

  // MARK: - Computed sizes

  private var cropClipShape: AnyShape {
    switch config.cropShape {
    case .circle:
      return AnyShape(Circle())
    case .roundedRect(let cornerRadius):
      return AnyShape(RoundedRectangle(cornerRadius: cornerRadius))
    case .rectangle:
      return AnyShape(Rectangle())
    }
  }

  var cropFrameSize: CGSize {
    let ratioValue = ratio.width / ratio.height
    let containerRatio = containerSize.width / containerSize.height
    var size: CGSize
    if ratioValue > containerRatio {
      let w = containerSize.width
      size = CGSize(width: w, height: w / ratioValue)
    } else {
      let h = containerSize.height
      size = CGSize(width: h * ratioValue, height: h)
    }
    // Force square for circle shape so the ellipse is a perfect circle
    if config.cropShape == .circle {
      let side = min(size.width, size.height)
      size = CGSize(width: side, height: side)
    }
    return size
  }

  var imageDisplaySize: CGSize {
    let frameW = cropFrameSize.width
    let frameH = cropFrameSize.height
    let frameRatio = frameW / max(frameH, 1)

    if imageAspectRatio > frameRatio {
      return CGSize(width: frameH * imageAspectRatio, height: frameH)
    } else {
      return CGSize(width: frameW, height: frameW / max(imageAspectRatio, 0.001))
    }
  }

  // MARK: - Body

  var body: some View {
    ZStack {
      config.backgroundColor

      // Image layer
      image
        .resizable()
        .scaledToFill()
        .frame(width: imageDisplaySize.width * imageScale,
               height: imageDisplaySize.height * imageScale)
        .offset(imageOffset)
        .frame(width: containerSize.width,
               height: containerSize.height)
        .clipped()

      // Dimmed overlay with hole for the crop frame
      CropHoleShape(holeSize: cropFrameSize, cropShape: config.cropShape)
        .fill(config.overlayColor.opacity(config.overlayOpacity), style: FillStyle(eoFill: true))
        .frame(width: containerSize.width,
               height: containerSize.height)
        .allowsHitTesting(false)

      // Corner guides + grid
      ZStack {
        if config.showCornerGuides && config.cropShape != .circle {
          CornerGuides(
            color: config.cornerColor,
            size: config.cornerSize,
            weight: config.cornerWeight
          )
        }

        GridOverlay(
          style: config.gridStyle,
          color: config.gridColor,
          lineWidth: config.gridLineWidth,
          opacity: config.gridOpacity
        )
        .clipShape(cropClipShape)
        .opacity(config.alwaysShowGrid || isInteracting ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: isInteracting)
      }
      .frame(width: cropFrameSize.width,
             height: cropFrameSize.height)
      .allowsHitTesting(false)

      // Native gesture layer (transparent, captures all touches)
      NativeGestureOverlay(
        doubleTapEnabled: config.doubleTapEnabled,
        onChanged: { state in handleGesture(state) },
        onEnded: { handleGestureEnd() }
      )
    }
    .onAppear {
      if let cropRect = initialCropRect {
        restoreFromCropRect(cropRect)
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        onCropChanged?(currentCropRect())
      }
    }
    .onChangeCompat(of: resetTrigger?.wrappedValue) { newValue in
      if newValue == true {
        withAnimation(config.snapBackAnimation) {
          imageScale = 1.0
          imageOffset = .zero
        }
        lastScale = 1.0
        lastOffset = .zero
        isZoomedIn = false
        resetTrigger?.wrappedValue = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
          onCropChanged?(currentCropRect())
        }
      }
    }
    .onChangeCompat(of: cropTrigger?.wrappedValue) { newValue in
      if newValue == true {
        cropTrigger?.wrappedValue = false
        performCropExport()
      }
    }
  }

  // MARK: - Gesture handling

  private func handleGesture(_ state: CropGestureState) {
    isInteracting = true

    // Double-tap
    if state.isDoubleTap && config.doubleTapEnabled {
      handleDoubleTap(at: state.doubleTapLocation)
      return
    }

    if state.isPinching {
      let anchor = state.pinchAnchor
      let delta = state.scale
      let prevScale = imageScale
      let lowerLimit = config.zoomRange.lowerBound - 0.5
      let upperLimit = config.zoomRange.upperBound + 1.0
      imageScale = max(lowerLimit, min(imageScale * delta, upperLimit))
      let appliedDelta = imageScale / prevScale

      imageOffset = CGSize(
        width: anchor.width - (anchor.width - imageOffset.width) * appliedDelta,
        height: anchor.height - (anchor.height - imageOffset.height) * appliedDelta
      )
      lastOffset = imageOffset
    }

    if state.isDragging && !state.isPinching {
      let rawOffset = CGSize(
        width: lastOffset.width + state.translation.width,
        height: lastOffset.height + state.translation.height
      )
      imageOffset = rubberBandOffset(for: rawOffset)
    }
  }

  private func handleGestureEnd() {
    isInteracting = false
    snapBack()
  }

  // MARK: - Double-tap

  private func handleDoubleTap(at location: CGSize) {
    if isZoomedIn {
      withAnimation(config.snapBackAnimation) {
        imageScale = config.zoomRange.lowerBound
        imageOffset = .zero
      }
      lastScale = config.zoomRange.lowerBound
      lastOffset = .zero
    } else {
      let targetScale = min(config.doubleTapTargetScale, config.zoomRange.upperBound)
      let prevScale = imageScale
      let newScale = targetScale
      let scaleFactor = newScale / prevScale
      let newOffset = CGSize(
        width: location.width - (location.width - imageOffset.width) * scaleFactor,
        height: location.height - (location.height - imageOffset.height) * scaleFactor
      )
      let clamped = clampedOffset(for: newOffset, scale: newScale)
      withAnimation(config.snapBackAnimation) {
        imageScale = newScale
        imageOffset = clamped
      }
      lastScale = newScale
      lastOffset = clamped
    }
    isZoomedIn.toggle()
    onCropChanged?(currentCropRect())
  }

  // MARK: - Crop rect computation

  func currentCropRect() -> CGRect {
    let scaledWidth = imageDisplaySize.width * imageScale
    let scaledHeight = imageDisplaySize.height * imageScale

    let visibleX = (scaledWidth - cropFrameSize.width) / 2 - imageOffset.width
    let visibleY = (scaledHeight - cropFrameSize.height) / 2 - imageOffset.height

    return CGRect(
      x: visibleX / scaledWidth,
      y: visibleY / scaledHeight,
      width: cropFrameSize.width / scaledWidth,
      height: cropFrameSize.height / scaledHeight
    )
  }

  private func restoreFromCropRect(_ cropRect: CGRect) {
    let scaleFromWidth = cropFrameSize.width / (imageDisplaySize.width * cropRect.width)
    let scaleFromHeight = cropFrameSize.height / (imageDisplaySize.height * cropRect.height)
    let zoomMax = config.zoomRange.upperBound
    let restoredScale = max(1.0, min((scaleFromWidth + scaleFromHeight) / 2, zoomMax))

    let scaledWidth = imageDisplaySize.width * restoredScale
    let scaledHeight = imageDisplaySize.height * restoredScale

    let visibleX = cropRect.origin.x * scaledWidth
    let visibleY = cropRect.origin.y * scaledHeight

    var offset = CGSize(
      width: (scaledWidth - cropFrameSize.width) / 2 - visibleX,
      height: (scaledHeight - cropFrameSize.height) / 2 - visibleY
    )

    let maxOffsetX = (scaledWidth - cropFrameSize.width) / 2
    let maxOffsetY = (scaledHeight - cropFrameSize.height) / 2
    offset.width = max(-maxOffsetX, min(offset.width, maxOffsetX))
    offset.height = max(-maxOffsetY, min(offset.height, maxOffsetY))

    imageScale = restoredScale
    lastScale = restoredScale
    imageOffset = offset
    lastOffset = offset
  }

  private func clampedOffset(for offset: CGSize, scale: CGFloat) -> CGSize {
    let scaledWidth = imageDisplaySize.width * scale
    let scaledHeight = imageDisplaySize.height * scale
    let maxOffsetX = max((scaledWidth - cropFrameSize.width) / 2, 0)
    let maxOffsetY = max((scaledHeight - cropFrameSize.height) / 2, 0)

    return CGSize(
      width: max(-maxOffsetX, min(offset.width, maxOffsetX)),
      height: max(-maxOffsetY, min(offset.height, maxOffsetY))
    )
  }

  private func rubberBandOffset(for rawOffset: CGSize) -> CGSize {
    let clamped = clampedOffset(for: rawOffset, scale: imageScale)

    guard config.rubberBandEnabled else { return clamped }

    let excessX = rawOffset.width - clamped.width
    let excessY = rawOffset.height - clamped.height

    #if canImport(UIKit)
    if config.hapticFeedbackEnabled {
      let exceeds = abs(excessX) > 1 || abs(excessY) > 1
      if exceeds && !hasTriggeredHaptic {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        hasTriggeredHaptic = true
      } else if !exceeds {
        hasTriggeredHaptic = false
      }
    }
    #endif

    return CGSize(
      width: clamped.width + excessX * config.rubberBandFactor,
      height: clamped.height + excessY * config.rubberBandFactor
    )
  }

  private func snapBack() {
    let clampedScale = max(config.zoomRange.lowerBound, min(imageScale, config.zoomRange.upperBound))
    let clamped = clampedOffset(for: imageOffset, scale: clampedScale)

    withAnimation(config.snapBackAnimation) {
      imageScale = clampedScale
      imageOffset = clamped
    }

    lastScale = clampedScale
    lastOffset = clamped
    onCropChanged?(currentCropRect())
  }

  // MARK: - Crop export

  private func performCropExport() {
    guard let platformImage = platformImage, let callback = onCropImage else { return }
    let rect = currentCropRect()

    DispatchQueue.global(qos: .userInitiated).async {
      guard let cropped = cropPlatformImage(platformImage, to: rect) else { return }
      DispatchQueue.main.async {
        callback(cropped)
      }
    }
  }
}
