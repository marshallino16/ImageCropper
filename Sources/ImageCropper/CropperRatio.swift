//
//  CropperRatio.swift
//  
//
//  Created by Anthony Fernandez on 12/18/20.
//

import Foundation
import CoreGraphics

public struct CropperRatio {
  
  let width: CGFloat
  let height: CGFloat
  
  public init(width: CGFloat, height: CGFloat) {
    self.width = width
    self.height = height
  }
  
  public static var r_1_1: Self {
    return .init(width: 1, height: 1)
  }
  
  public static var r_3_2: Self {
    return .init(width: 3, height: 2)
  }
  
  public static var r_4_3: Self {
    return .init(width: 4, height: 3)
  }
  
  public static var r_16_9: Self {
    return .init(width: 16, height: 9)
  }
  
  static var r_18_6: Self {
    return .init(width: 18, height: 6)
  }
}
