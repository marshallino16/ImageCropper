import XCTest
@testable import ImageCropper

final class ImageCropperTests: XCTestCase {

  func testCropperRatioPresets() {
    let r = CropperRatio.r_16_9
    XCTAssertEqual(r.width, 16)
    XCTAssertEqual(r.height, 9)
  }

  static var allTests = [
    ("testCropperRatioPresets", testCropperRatioPresets),
  ]
}
