//
//  PlatformTypes.swift
//
//  Cross-platform type aliases and image cropping.
//

#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#endif

// MARK: - Platform image cropping

func cropPlatformImage(_ image: PlatformImage, to normalizedRect: CGRect) -> PlatformImage? {
  #if canImport(UIKit)
  guard let cgImage = image.cgImage else { return nil }
  let imgW = CGFloat(cgImage.width)
  let imgH = CGFloat(cgImage.height)
  let cropRect = CGRect(
    x: normalizedRect.origin.x * imgW,
    y: normalizedRect.origin.y * imgH,
    width: normalizedRect.width * imgW,
    height: normalizedRect.height * imgH
  )
  guard let cropped = cgImage.cropping(to: cropRect) else { return nil }
  return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)

  #elseif canImport(AppKit)
  guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
  let imgW = CGFloat(cgImage.width)
  let imgH = CGFloat(cgImage.height)
  let cropRect = CGRect(
    x: normalizedRect.origin.x * imgW,
    y: normalizedRect.origin.y * imgH,
    width: normalizedRect.width * imgW,
    height: normalizedRect.height * imgH
  )
  guard let cropped = cgImage.cropping(to: cropRect) else { return nil }
  return NSImage(cgImage: cropped, size: NSSize(width: cropRect.width, height: cropRect.height))
  #endif
}
