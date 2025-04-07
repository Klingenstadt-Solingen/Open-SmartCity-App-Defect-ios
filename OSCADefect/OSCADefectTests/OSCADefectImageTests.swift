//
//  OSCADefectImageTests.swift
//
//
//  Created by Stephan Breidenbach on 15.04.24.
//

#if canImport(XCTest) && canImport(OSCATestCaseExtension)
import XCTest
import UIKit
import Combine
import OSCANetworkService
import OSCATestCaseExtension
@testable import OSCADefect

final class OSCADefectImageTests: XCTestCase {
  var base64String: String!
  
  override func setUpWithError() throws -> Void {
    try super.setUpWithError()
  }// end override fun setUp
  
  override func tearDownWithError() throws -> Void {
    try super.tearDownWithError()
  }// end override func tearDown
  
  func testCreateLargeImage() throws -> Void {
    let height: Int = 1024
    let width: Int = 768
    let pixels: [OSCADefectImageTests.PixelData] = [OSCADefectImageTests.PixelData](width: width,
                                                                                    height: height)
    XCTAssertTrue(pixels.count == height * width)
    
    guard let uiImage = imageFromARGB32BitBitmap(pixels: pixels,
                                                 width: width,
                                                 height: height) else { XCTFail("Wrong image!"); return }
    XCTAssertTrue(Int(uiImage.size.width * uiImage.scale) == width)
    XCTAssertTrue(Int(uiImage.size.height * uiImage.scale) == height)
    
    //guard let pngImageData = uiImage.pngData() else { XCTFail("Wrong PNG image!"); return }
    guard let jpgImageData = uiImage.jpegData(compressionQuality: 0.8) else { XCTFail("Wrong JPEG image!"); return }
    let base64String = jpgImageData.base64EncodedString()
    
    XCTAssertTrue(!base64String.isEmpty)
    self.base64String = base64String
  }// end func testCreateLargeImage
}// end final class OSCADefectImageTests

extension OSCADefectImageTests {
  public struct PixelData {
    public static func random() -> UInt8 { UInt8.random(in: UInt8.min...UInt8.max) }// end public static func random
    var a: UInt8
    var r: UInt8
    var g: UInt8
    var b: UInt8
    
    init() {
      self.a = PixelData.random()
      self.r = PixelData.random()
      self.g = PixelData.random()
      self.b = PixelData.random()
    }// end init
  }// end public struct PixelData
  
  func imageFromARGB32BitBitmap(pixels: [OSCADefectImageTests.PixelData],
                                width: Int,
                                height: Int) -> UIImage? {
    guard pixels.count == Int(width * height) else { return nil }
    var data = pixels // copy to mutable []
    let rgbColorSpace = /*CGColorSpaceCreateDeviceRGB()*/ CGColorSpace(name: CGColorSpace.sRGB)!
    let bitmapInfo: CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
    let bitsPerComponent: Int = 8
    let bitsPerPixel: Int = 32
    let bytesPerRow: Int = 4 * width //[bytes]
    
    let dataLength: Int = 4 * height * width //[bytes]

    guard let providerRef = CGDataProvider(
      data: NSData(bytes: &data,
                   length: dataLength)
    ) else { return nil }
    guard let cgim = CGImage(width: width,
                             height: height,
                             bitsPerComponent: bitsPerComponent,
                             bitsPerPixel: bitsPerPixel,
                             bytesPerRow: bytesPerRow,
                             space: rgbColorSpace,
                             bitmapInfo: bitmapInfo,
                             provider: providerRef,
                             decode: nil,
                             shouldInterpolate: true,
                             intent: CGColorRenderingIntent.defaultIntent) else { return nil }
    return UIImage(cgImage: cgim)
  }// end func imageFromARGB32BitBitmap+
}// end extension OSCADefectImageTests

 extension Array where Element == OSCADefectImageTests.PixelData {
  init(width: Int,
       height: Int) {
    self.init()
    let count = width * height
    for _ in 1...count {
      self.append(OSCADefectImageTests.PixelData())
    }// for i
  }// end init with width, height
}//end extension Array
#endif
