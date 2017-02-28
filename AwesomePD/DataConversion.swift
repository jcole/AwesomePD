//
//  DataConversion.swift
//  AwesomePD
//
//  Created by Jeff on 2/28/17.
//  Copyright © 2017 Team Awesome. All rights reserved.
//

import Foundation
import UIKit

struct DoublePoint {
  var x: Double = 0.0
  var y: Double = 0.0
  func toCGPoint() -> CGPoint {
    return CGPoint(x: x, y: y)
  }
}

func convertToCGPoints(points: [[Double]]) -> [CGPoint] {
  var converted: [CGPoint] = []
  for pair in points {
    converted.append(CGPoint(x: pair[0], y: pair[1]))
  }
  return converted
}

func convertToDoubles(points: [CGPoint]) -> [[Double]] {
  var converted: [[Double]] = []
  for point in points {
    converted.append([Double(point.x), Double(point.y)])
  }
  return converted
}
