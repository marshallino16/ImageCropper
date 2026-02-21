//
//  CropShape.swift
//
//  Defines the shape of the crop cutout.
//

import CoreGraphics

public enum CropShape: Equatable, Sendable {
  case rectangle
  case circle
  case roundedRect(cornerRadius: CGFloat)
}
