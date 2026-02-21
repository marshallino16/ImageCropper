//
//  CropperConfiguration.swift
//
//  Groups all configurable values for the cropper.
//  Defaults reproduce the existing behavior.
//

import SwiftUI

struct CropperConfiguration {

  // MARK: - Visual

  var backgroundColor: Color = .black
  var overlayColor: Color = .black
  var overlayOpacity: Double = 0.55
  var cornerColor: Color = .white
  var cornerSize: CGFloat = 20
  var cornerWeight: CGFloat = 2
  var gridStyle: GridStyle = .ruleOfThirds
  var gridColor: Color = .white
  var gridLineWidth: CGFloat = 0.5
  var gridOpacity: Double = 0.6
  var cropShape: CropShape = .rectangle
  var alwaysShowGrid: Bool = false
  var showCornerGuides: Bool = true

  // MARK: - Behavior

  var zoomRange: ClosedRange<CGFloat> = 1.0...5.0
  var rubberBandEnabled: Bool = true
  var rubberBandFactor: CGFloat = 0.35
  var snapBackAnimation: Animation = .easeInOut(duration: 0.3)

  // MARK: - Interactions

  var doubleTapEnabled: Bool = false
  var doubleTapTargetScale: CGFloat = 2.0
  var hapticFeedbackEnabled: Bool = false
}
