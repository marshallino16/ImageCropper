//
//  GridOverlay.swift
//
//  A standalone view that renders the grid overlay inside the crop frame.
//

import SwiftUI

struct GridOverlay: View {
  let style: GridStyle
  let color: Color
  let lineWidth: CGFloat
  let opacity: Double

  var body: some View {
    switch style {
    case .ruleOfThirds:
      GeometryReader { geo in
        let w = geo.size.width
        let h = geo.size.height
        Path { path in
          path.move(to: CGPoint(x: w / 3, y: 0))
          path.addLine(to: CGPoint(x: w / 3, y: h))
          path.move(to: CGPoint(x: 2 * w / 3, y: 0))
          path.addLine(to: CGPoint(x: 2 * w / 3, y: h))
          path.move(to: CGPoint(x: 0, y: h / 3))
          path.addLine(to: CGPoint(x: w, y: h / 3))
          path.move(to: CGPoint(x: 0, y: 2 * h / 3))
          path.addLine(to: CGPoint(x: w, y: 2 * h / 3))
        }
        .stroke(color.opacity(opacity), lineWidth: lineWidth)
      }

    case .goldenRatio:
      GeometryReader { geo in
        let w = geo.size.width
        let h = geo.size.height
        let phi: CGFloat = 0.618
        Path { path in
          path.move(to: CGPoint(x: w * phi, y: 0))
          path.addLine(to: CGPoint(x: w * phi, y: h))
          path.move(to: CGPoint(x: w * (1 - phi), y: 0))
          path.addLine(to: CGPoint(x: w * (1 - phi), y: h))
          path.move(to: CGPoint(x: 0, y: h * phi))
          path.addLine(to: CGPoint(x: w, y: h * phi))
          path.move(to: CGPoint(x: 0, y: h * (1 - phi)))
          path.addLine(to: CGPoint(x: w, y: h * (1 - phi)))
        }
        .stroke(color.opacity(opacity), lineWidth: lineWidth)
      }

    case .diagonal:
      GeometryReader { geo in
        let w = geo.size.width
        let h = geo.size.height
        Path { path in
          path.move(to: CGPoint(x: 0, y: 0))
          path.addLine(to: CGPoint(x: w, y: h))
          path.move(to: CGPoint(x: w, y: 0))
          path.addLine(to: CGPoint(x: 0, y: h))
        }
        .stroke(color.opacity(opacity), lineWidth: lineWidth)
      }

    case .crosshair:
      GeometryReader { geo in
        let w = geo.size.width
        let h = geo.size.height
        Path { path in
          path.move(to: CGPoint(x: w / 2, y: 0))
          path.addLine(to: CGPoint(x: w / 2, y: h))
          path.move(to: CGPoint(x: 0, y: h / 2))
          path.addLine(to: CGPoint(x: w, y: h / 2))
        }
        .stroke(color.opacity(opacity), lineWidth: lineWidth)
      }

    case .none:
      EmptyView()
    }
  }
}
