//
//  CornerGuides.swift
//
//  A view that draws L-shaped corner guides around the crop frame.
//

import SwiftUI

struct CornerGuides: View {
  let color: Color
  let size: CGFloat
  let weight: CGFloat

  var body: some View {
    VStack {
      HStack {
        VStack(alignment: .leading, spacing: 0) {
          Rectangle()
            .fill(color)
            .frame(width: size, height: weight)
          HStack {
            Rectangle()
              .fill(color)
              .frame(width: weight, height: size)
            Spacer()
          }
        }
        Spacer()
        VStack(alignment: .trailing, spacing: 0) {
          Rectangle()
            .fill(color)
            .frame(width: size, height: weight)
          HStack {
            Spacer()
            Rectangle()
              .fill(color)
              .frame(width: weight, height: size)
          }
        }
      }
      Spacer()
      HStack {
        VStack(alignment: .leading, spacing: 0) {
          HStack {
            Rectangle()
              .fill(color)
              .frame(width: weight, height: size)
            Spacer()
          }
          Rectangle()
            .fill(color)
            .frame(width: size, height: weight)
        }
        Spacer()
        VStack(alignment: .trailing, spacing: 0) {
          HStack {
            Spacer()
            Rectangle()
              .fill(color)
              .frame(width: weight, height: size)
          }
          Rectangle()
            .fill(color)
            .frame(width: size, height: weight)
        }
      }
    }
  }
}
