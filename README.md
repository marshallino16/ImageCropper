SwiftUI-ImageCropper
=================


![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/marshallino16/ImageCropper)
[![Swift Package Manager](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)
![Swift5](https://img.shields.io/badge/Swift-5-orange.svg)
![Platform](https://img.shields.io/badge/platform-iOS|macOS-blue.svg?style=flat)
![GitHub repo size](https://img.shields.io/github/repo-size/marshallino16/ImageCropper)


Simple ratio based image cropper for SwiftUI

## Features

- Movable crop area
- Convert crop area to crop CGRect 
- Convert crop CGRect to crop area

## Requirements

- Xcode 12
- Swift 5.3


## Integration

ImageCropper is available via [Swift Package Manager](https://swift.org/package-manager/)

Using Xcode 12, go to `File -> Swift Packages -> Add Package Dependency` and enter [https://github.com/marshallino16/ImageCropper](https://github.com/marshallino16/ImageCropper)

## Usage 

`ImageCropper` gives you access to a new view called `ImageCropperView`. It can be integrated within your view `body` like this : 

```swift
ImageCropperView(image: Image("stock"),
                 ratio: ratio)
.onCropChanged { (newCrop) in
  print(newCrop)
}
```

## Details


#### Parameters

#### Modifiers 

ImageCropperView comes with one modifier 

```swift
onCropChanged { ... }
```

## License

ImageCropper is available under the MIT license. See the LICENSE file for more info.
