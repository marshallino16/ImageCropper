//
//  NativeGestureOverlay.swift
//
//  Bridge UIKit / AppKit gesture recognizers to SwiftUI.
//  Provides the real touch midpoint for anchor-based pinch zoom.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Shared gesture state

struct CropGestureState {
  var translation: CGSize = .zero
  /// Incremental scale factor (1.0 = no change). Reset each frame.
  var scale: CGFloat = 1.0
  /// Pinch anchor relative to the view center.
  var pinchAnchor: CGSize = .zero
  var isPinching: Bool = false
  var isDragging: Bool = false
  /// Double-tap detected.
  var isDoubleTap: Bool = false
  /// Double-tap location relative to the view center.
  var doubleTapLocation: CGSize = .zero
}

// MARK: - Shared gesture state manager

/// Holds the mutable gesture state and the callbacks.
/// Used by both UIKit and AppKit coordinators to avoid duplicating state logic.
class GestureStateManager {
  var onChanged: (CropGestureState) -> Void
  var onEnded: () -> Void
  var state = CropGestureState()

  init(onChanged: @escaping (CropGestureState) -> Void,
       onEnded: @escaping () -> Void) {
    self.onChanged = onChanged
    self.onEnded = onEnded
  }

  // MARK: - Pan

  func panChanged(translation: CGPoint) {
    state.translation = CGSize(width: translation.x, height: translation.y)
    state.isDragging = true
    state.isDoubleTap = false
    onChanged(state)
  }

  func panEnded() {
    state.translation = .zero
    state.isDragging = false
    if !state.isPinching { onEnded() }
  }

  // MARK: - Pinch / Magnify

  func pinchChanged(anchor: CGSize, incrementalScale: CGFloat) {
    state.pinchAnchor = anchor
    state.scale = incrementalScale
    state.isPinching = true
    state.isDoubleTap = false
    onChanged(state)
  }

  func pinchEnded(isStillDragging: Bool) {
    state.scale = 1
    state.isPinching = false
    if isStillDragging {
      onChanged(state)
    } else {
      onEnded()
    }
  }

  // MARK: - Double-tap

  func doubleTapOccurred(location: CGSize) {
    var tapState = CropGestureState()
    tapState.isDoubleTap = true
    tapState.doubleTapLocation = location
    onChanged(tapState)
  }
}

// MARK: - UIKit implementation

#if canImport(UIKit)

struct NativeGestureOverlay: UIViewRepresentable {
  var doubleTapEnabled: Bool = false
  var onChanged: (CropGestureState) -> Void
  var onEnded: () -> Void

  func makeCoordinator() -> Coordinator { Coordinator(onChanged: onChanged, onEnded: onEnded) }

  func makeUIView(context: Context) -> UIView {
    let view = UIView(frame: .zero)
    view.backgroundColor = .clear
    let coordinator = context.coordinator

    let pan = UIPanGestureRecognizer(target: coordinator, action: #selector(Coordinator.handlePan(_:)))
    pan.minimumNumberOfTouches = 1
    pan.maximumNumberOfTouches = 2
    pan.delegate = coordinator
    view.addGestureRecognizer(pan)

    let pinch = UIPinchGestureRecognizer(target: coordinator, action: #selector(Coordinator.handlePinch(_:)))
    pinch.delegate = coordinator
    view.addGestureRecognizer(pinch)

    let doubleTap = UITapGestureRecognizer(target: coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
    doubleTap.numberOfTapsRequired = 2
    doubleTap.isEnabled = doubleTapEnabled
    coordinator.doubleTapRecognizer = doubleTap
    view.addGestureRecognizer(doubleTap)

    return view
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    context.coordinator.manager.onChanged = onChanged
    context.coordinator.manager.onEnded = onEnded
    context.coordinator.doubleTapRecognizer?.isEnabled = doubleTapEnabled
  }

  class Coordinator: NSObject, UIGestureRecognizerDelegate {
    let manager: GestureStateManager
    var doubleTapRecognizer: UITapGestureRecognizer?

    init(onChanged: @escaping (CropGestureState) -> Void, onEnded: @escaping () -> Void) {
      self.manager = GestureStateManager(onChanged: onChanged, onEnded: onEnded)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool { true }

    @objc func handlePan(_ g: UIPanGestureRecognizer) {
      guard let view = g.view else { return }
      switch g.state {
      case .began, .changed:
        let t = g.translation(in: view)
        manager.panChanged(translation: CGPoint(x: t.x, y: t.y))
      case .ended, .cancelled:
        g.setTranslation(.zero, in: view)
        manager.panEnded()
      default: break
      }
    }

    @objc func handlePinch(_ g: UIPinchGestureRecognizer) {
      guard let view = g.view else { return }
      switch g.state {
      case .began, .changed:
        let loc = g.location(in: view)
        let anchor = CGSize(width: loc.x - view.bounds.midX, height: loc.y - view.bounds.midY)
        manager.pinchChanged(anchor: anchor, incrementalScale: g.scale)
        g.scale = 1
      case .ended, .cancelled:
        manager.pinchEnded(isStillDragging: manager.state.isDragging)
      default: break
      }
    }

    @objc func handleDoubleTap(_ g: UITapGestureRecognizer) {
      guard let view = g.view else { return }
      let loc = g.location(in: view)
      let location = CGSize(width: loc.x - view.bounds.midX, height: loc.y - view.bounds.midY)
      manager.doubleTapOccurred(location: location)
    }
  }
}

// MARK: - AppKit implementation

#elseif canImport(AppKit)

struct NativeGestureOverlay: NSViewRepresentable {
  var doubleTapEnabled: Bool = false
  var onChanged: (CropGestureState) -> Void
  var onEnded: () -> Void

  func makeCoordinator() -> Coordinator { Coordinator(onChanged: onChanged, onEnded: onEnded) }

  func makeNSView(context: Context) -> GestureNSView {
    let view = GestureNSView(frame: .zero)
    let coordinator = context.coordinator
    view.manager = coordinator.manager

    let magnify = NSMagnificationGestureRecognizer(
      target: coordinator, action: #selector(Coordinator.handleMagnify(_:)))
    magnify.delegate = coordinator
    view.addGestureRecognizer(magnify)

    let pan = NSPanGestureRecognizer(
      target: coordinator, action: #selector(Coordinator.handlePan(_:)))
    pan.delegate = coordinator
    view.addGestureRecognizer(pan)

    let doubleClick = NSClickGestureRecognizer(
      target: coordinator, action: #selector(Coordinator.handleDoubleClick(_:)))
    doubleClick.numberOfClicksRequired = 2
    doubleClick.delegate = coordinator
    doubleClick.isEnabled = doubleTapEnabled
    coordinator.doubleClickRecognizer = doubleClick
    view.addGestureRecognizer(doubleClick)

    return view
  }

  func updateNSView(_ nsView: GestureNSView, context: Context) {
    context.coordinator.manager.onChanged = onChanged
    context.coordinator.manager.onEnded = onEnded
    context.coordinator.doubleClickRecognizer?.isEnabled = doubleTapEnabled
  }

  /// Custom NSView for trackpad scroll events (two-finger swipe).
  class GestureNSView: NSView {
    var manager: GestureStateManager?
    private var scrollAccumulator: CGPoint = .zero
    var isScrolling = false

    override var acceptsFirstResponder: Bool { true }
    override var isFlipped: Bool { true }

    override func viewDidMoveToWindow() {
      super.viewDidMoveToWindow()
      window?.makeFirstResponder(self)
    }

    override func scrollWheel(with event: NSEvent) {
      guard let manager = manager else { return }

      // Continuous trackpad scroll
      if event.phase.contains(.began) {
        isScrolling = true
        scrollAccumulator = .zero
      }
      if event.phase.contains(.changed) || event.phase.contains(.began) {
        scrollAccumulator.x += event.scrollingDeltaX
        scrollAccumulator.y += event.scrollingDeltaY
        manager.panChanged(translation: scrollAccumulator)
      }
      if event.phase.contains(.ended) || event.phase.contains(.cancelled) {
        isScrolling = false
        manager.panEnded()
      }

      // Discrete mouse wheel (no phase)
      if event.phase == [] && event.momentumPhase == [] {
        let delta = CGPoint(x: event.scrollingDeltaX * 3, y: event.scrollingDeltaY * 3)
        manager.panChanged(translation: delta)
        manager.panEnded()
      }
    }
  }

  class Coordinator: NSObject, NSGestureRecognizerDelegate {
    let manager: GestureStateManager
    var doubleClickRecognizer: NSClickGestureRecognizer?

    init(onChanged: @escaping (CropGestureState) -> Void, onEnded: @escaping () -> Void) {
      self.manager = GestureStateManager(onChanged: onChanged, onEnded: onEnded)
      super.init()
    }

    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith other: NSGestureRecognizer) -> Bool { true }

    @objc func handleMagnify(_ g: NSMagnificationGestureRecognizer) {
      guard let view = g.view else { return }
      let loc = g.location(in: view)
      let anchor = CGSize(width: loc.x - view.bounds.midX, height: loc.y - view.bounds.midY)

      switch g.state {
      case .began, .changed:
        manager.pinchChanged(anchor: anchor, incrementalScale: 1 + g.magnification)
        g.magnification = 0
      case .ended, .cancelled:
        let nsView = view as? GestureNSView
        manager.pinchEnded(isStillDragging: nsView?.isScrolling ?? false)
      default: break
      }
    }

    @objc func handlePan(_ g: NSPanGestureRecognizer) {
      guard let view = g.view else { return }
      switch g.state {
      case .began, .changed:
        let t = g.translation(in: view)
        manager.panChanged(translation: CGPoint(x: t.x, y: t.y))
      case .ended, .cancelled:
        g.setTranslation(.zero, in: view)
        manager.panEnded()
      default: break
      }
    }

    @objc func handleDoubleClick(_ g: NSClickGestureRecognizer) {
      guard let view = g.view else { return }
      let loc = g.location(in: view)
      let location = CGSize(width: loc.x - view.bounds.midX, height: loc.y - view.bounds.midY)
      manager.doubleTapOccurred(location: location)
    }
  }
}

#endif
