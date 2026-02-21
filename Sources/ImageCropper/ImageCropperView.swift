//
//  ImageCropperView.swift
//
//
//  Created by Anthony Fernandez on 12/18/20.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct ImageCropperView: View {

  let image: Image
  let imageAspectRatio: CGFloat
  let ratio: CropperRatio
  let cropRect: CGRect?

  var onCropChanged: ((CGRect) -> Void)?

  // Platform image for export
  var platformImage: PlatformImage?

  // MARK: - Configuration (single source of truth)

  var config = CropperConfiguration()

  // MARK: - Triggers & callbacks

  var resetTriggerBinding: Binding<Bool>?
  var cropTriggerBinding: Binding<Bool>?
  var onCropImageCallback: ((PlatformImage) -> Void)?

  // MARK: - Inits

  #if canImport(UIKit)
  public init(image: UIImage,
              cropRect: CGRect? = nil,
              ratio: CropperRatio) {
    self.image = Image(uiImage: image)
    self.imageAspectRatio = image.size.width / max(image.size.height, 1)
    self.ratio = ratio
    self.cropRect = cropRect
    self.platformImage = image
  }
  #elseif canImport(AppKit)
  public init(image: NSImage,
              cropRect: CGRect? = nil,
              ratio: CropperRatio) {
    self.image = Image(nsImage: image)
    self.imageAspectRatio = image.size.width / max(image.size.height, 1)
    self.ratio = ratio
    self.cropRect = cropRect
    self.platformImage = image
  }
  #endif

  /// Fallback init with a SwiftUI Image. Requires `imageSize` for correct pan bounds.
  /// Note: crop export is unavailable with this init (no platform image).
  public init(image: Image,
              imageSize: CGSize,
              cropRect: CGRect? = nil,
              ratio: CropperRatio) {
    self.image = image
    self.imageAspectRatio = imageSize.width / max(imageSize.height, 1)
    self.ratio = ratio
    self.cropRect = cropRect
    self.platformImage = nil
  }

  public var body: some View {
    GeometryReader { reader in
      CropperView(
        image: image,
        imageAspectRatio: imageAspectRatio,
        containerSize: reader.size,
        initialCropRect: cropRect,
        ratio: ratio,
        config: config,
        onCropChanged: onCropChanged,
        resetTrigger: resetTriggerBinding,
        cropTrigger: cropTriggerBinding,
        platformImage: platformImage,
        onCropImage: onCropImageCallback
      )
      .frame(width: reader.size.width, height: reader.size.height)
      .id("\(ratio.width)_\(ratio.height)")
    }
  }
}


// MARK: - Public API

extension ImageCropperView {

  /// Called whenever the normalized crop rect changes.
  public func onCropChanged(_ action: @escaping ((CGRect) -> Void)) -> Self {
    var copy = self
    copy.onCropChanged = action
    return copy
  }

  /// When `true`, the grid is always visible.
  /// When `false` (default), the grid appears only during user interaction.
  public func alwaysShowGrid(_ show: Bool) -> Self {
    var copy = self
    copy.config.alwaysShowGrid = show
    return copy
  }

  // MARK: - Visual modifiers

  /// Customize the overlay (dimmed area outside crop frame).
  public func overlayStyle(color: Color = .black, opacity: Double = 0.55) -> Self {
    var copy = self
    copy.config.overlayColor = color
    copy.config.overlayOpacity = opacity
    return copy
  }

  /// Customize the corner guide appearance.
  public func cornerStyle(color: Color = .white, size: CGFloat = 20, weight: CGFloat = 2) -> Self {
    var copy = self
    copy.config.cornerColor = color
    copy.config.cornerSize = size
    copy.config.cornerWeight = weight
    return copy
  }

  /// Customize the grid color, line width, and opacity.
  public func gridColor(_ color: Color, lineWidth: CGFloat = 0.5, opacity: Double = 0.6) -> Self {
    var copy = self
    copy.config.gridColor = color
    copy.config.gridLineWidth = lineWidth
    copy.config.gridOpacity = opacity
    return copy
  }

  /// Set the grid overlay pattern.
  public func gridStyle(_ style: GridStyle) -> Self {
    var copy = self
    copy.config.gridStyle = style
    return copy
  }

  /// Set the crop cutout shape.
  public func cropShape(_ shape: CropShape) -> Self {
    var copy = self
    copy.config.cropShape = shape
    return copy
  }

  /// Set the background color behind the image.
  public func backgroundColor(_ color: Color) -> Self {
    var copy = self
    copy.config.backgroundColor = color
    return copy
  }

  // MARK: - Behavior modifiers

  /// Set the allowed zoom range. Default is `1.0...5.0`.
  public func zoomRange(_ range: ClosedRange<CGFloat>) -> Self {
    var copy = self
    copy.config.zoomRange = range
    return copy
  }

  /// Set the snap-back animation used when the image settles after a gesture.
  public func snapBackAnimation(_ animation: Animation) -> Self {
    var copy = self
    copy.config.snapBackAnimation = animation
    return copy
  }

  /// Enable or disable rubber-band effect when panning past bounds.
  public func rubberBandEnabled(_ enabled: Bool) -> Self {
    var copy = self
    copy.config.rubberBandEnabled = enabled
    return copy
  }

  /// Set the rubber-band dampening factor (0 = no stretch, 1 = full stretch). Default is 0.35.
  public func rubberBandFactor(_ factor: CGFloat) -> Self {
    var copy = self
    copy.config.rubberBandFactor = factor
    return copy
  }

  // MARK: - Interaction modifiers

  /// Enable double-tap to toggle zoom.
  public func doubleTapToZoom(enabled: Bool = true, targetScale: CGFloat = 2.0) -> Self {
    var copy = self
    copy.config.doubleTapEnabled = enabled
    copy.config.doubleTapTargetScale = targetScale
    return copy
  }

  /// Enable haptic feedback when panning past bounds (iOS only, no-op on macOS).
  public func hapticFeedback(_ enabled: Bool) -> Self {
    var copy = self
    copy.config.hapticFeedbackEnabled = enabled
    return copy
  }

  // MARK: - Trigger modifiers

  /// Bind a Bool that, when set to `true`, resets scale and offset to defaults.
  /// The binding is automatically set back to `false` after reset.
  public func resetTrigger(_ trigger: Binding<Bool>) -> Self {
    var copy = self
    copy.resetTriggerBinding = trigger
    return copy
  }

  /// Bind a Bool that, when set to `true`, triggers image crop export.
  /// The binding is automatically set back to `false` after export starts.
  /// Use `.onCropImage` to receive the cropped platform image.
  public func cropTrigger(_ trigger: Binding<Bool>) -> Self {
    var copy = self
    copy.cropTriggerBinding = trigger
    return copy
  }

  /// Called with the cropped platform image when `.cropTrigger` fires.
  /// Only works when the cropper was initialized with a UIImage or NSImage.
  public func onCropImage(_ action: @escaping (PlatformImage) -> Void) -> Self {
    var copy = self
    copy.onCropImageCallback = action
    return copy
  }

}
