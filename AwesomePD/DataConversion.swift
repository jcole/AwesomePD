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

func convertToCGPoints(points: [DoublePoint]) -> [CGPoint] {
  var converted: [CGPoint] = []
  for point in points {
    converted.append(point.toCGPoint())
  }
  return converted
}

func convertToDoublePoints(points: [CGPoint]) -> [DoublePoint] {
  var converted: [DoublePoint] = []
  for point in points {
    converted.append(DoublePoint(x: Double(point.x), y: Double(point.y)))
  }
  return converted
}
