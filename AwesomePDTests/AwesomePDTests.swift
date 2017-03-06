//
//  AwesomePDTests.swift
//  AwesomePDTests
//
//  Created by Jeff on 3/6/17.
//  Copyright © 2017 Team Awesome. All rights reserved.
//

import XCTest
@testable import AwesomePD

class AwesomePDTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testDataConversion() {
    let doublePoints: [DoublePoint] = [DoublePoint(x: 0.0, y: 1.0), DoublePoint(x: 2.0, y: 3.0)]
    let convertedPoints: [CGPoint] = convertToCGPoints(points: doublePoints)
    XCTAssertEqual([CGPoint(x: 0.0, y: 1.0), CGPoint(x: 2.0, y: 3.0)], convertedPoints)
  }
  
}
