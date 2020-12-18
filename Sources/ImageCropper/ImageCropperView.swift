//
//  ImageCropperView.swift
//  
//
//  Created by Anthony Fernandez on 12/18/20.
//

import SwiftUI

public struct ImageCropperView: View {
  
  var ratio: CropperRatio
  
  let image: Image
  var onCropChanged : ((CGRect) -> Void)?
  
  public init(image: Image,
              ratio: CropperRatio) {
    self.image = image
    self.ratio = ratio
  }
  
  public var body: some View {
    image
      .resizable()
      .scaledToFit()
      .overlay(
        GeometryReader { reader in
          CropperView(viewModel: CropperViewModel(parentProxy: reader,
                                                  initialCropRect: nil,
                                                  ratio: ratio,
                                                  onCropChanged: onCropChanged))
        }
      )
  }
}


// MARK: - Public API

extension ImageCropperView {
  
  public func onCropChanged(_ action: @escaping ((CGRect) -> Void)) -> Self {
    var copy = self
    copy.onCropChanged = action
    return copy
  }
}
