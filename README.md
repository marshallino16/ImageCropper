SwiftUI-ImageCropper
=================


![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/marshallino16/ImageCropper)
[![Swift Package Manager](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)
![Swift5](https://img.shields.io/badge/Swift-5-orange.svg)
![Platform](https://img.shields.io/badge/platform-iOS|macOS-blue.svg?style=flat)
![GitHub repo size](https://img.shields.io/github/repo-size/marshallino16/ImageCropper)


Simple ratio based image cropper for SwiftUI

<img width="653" alt="Screen Shot 2020-12-18 at 5 05 30 PM" src="https://user-images.githubusercontent.com/1506323/102635181-4293b700-4153-11eb-81aa-1175d58b4464.png">


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
                 cropRect: nil,
                 ratio: ratio)
.onCropChanged { (newCrop) in
  print(newCrop)
}
```

## Details


#### Parameters

| Param    | Type         | Initial Value | Optional |
|----------|--------------|---------------|----------|
| image    | Image        |               | no       |
| cropRect | CGRect       | nil           | yes      |
| ratio    | CropperRatio |               | no       |

#### Modifiers 

ImageCropperView comes with one modifier 

```swift
onCropChanged { ... }
```

## Next

- Pinch to zoom

## License

ImageCropper is available under the MIT license. See the LICENSE file for more info.
