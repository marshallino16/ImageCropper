//
//  ImageCropperView.swift
//  
//
//  Created by Anthony Fernandez on 12/18/20.
//

import SwiftUI

public struct ImageCropperView: View {

  let image: Image
  let ratio: CropperRatio
  let cropRect: CGRect?
  
  var onCropChanged : ((CGRect) -> Void)?
  
  public init(image: Image,
              cropRect: CGRect? = nil,
              ratio: CropperRatio) {
    self.image = image
    self.ratio = ratio
    self.cropRect = cropRect
  }
  
  public var body: some View {
    image
      .resizable()
      .scaledToFit()
      .overlay(
        GeometryReader { reader in
          CropperView(viewModel: CropperViewModel(parentProxy: reader,
                                                  cropRect: cropRect,
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
