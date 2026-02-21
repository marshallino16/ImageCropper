//
//  CropHoleShape.swift
//
//  A Shape with a rectangular/circular/rounded-rect cutout (even-odd fill).
//

import SwiftUI

struct CropHoleShape: Shape {
  let holeSize: CGSize
  let cropShape: CropShape

  init(holeSize: CGSize, cropShape: CropShape = .rectangle) {
    self.holeSize = holeSize
    self.cropShape = cropShape
  }

  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.addRect(rect)
    let holeRect = CGRect(
      x: (rect.width - holeSize.width) / 2,
      y: (rect.height - holeSize.height) / 2,
      width: holeSize.width,
      height: holeSize.height
    )
    switch cropShape {
    case .rectangle:
      path.addRect(holeRect)
    case .circle:
      path.addEllipse(in: holeRect)
    case .roundedRect(let cornerRadius):
      path.addRoundedRect(in: holeRect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
    }
    return path
  }
}
