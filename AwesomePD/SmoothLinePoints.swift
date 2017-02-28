//
//  SmoothLinePoints.swift
//  AwesomePD
//
//  Created by Jeff on 2/28/17.
//  Copyright © 2017 Team Awesome. All rights reserved.
//

import Foundation
import UIKit

class SmoothLinePoints {
  
  static func smoothPointsThrough(points: [CGPoint]) -> [CGPoint] {
    // Get Cubic Bezier control points for given points
    let controlPoints = CubicCurveAlgorithm().controlPointsFromPoints(points)
    
    // Calculate points along Bezier curves
    var interpolatedPoints: [CGPoint] = []
    for i in 1 ..< points.count {
      if i == points.count - 1 {
        interpolatedPoints.append(points[i])
      }else {
        let start = points[i - 1]
        let end = points[i]
        let segment = controlPoints[i-1]
        let cp1 = segment.controlPoint1
        let cp2 = segment.controlPoint2
        for pct:CGFloat in stride(from: 0.0, to: 1.0, by: 0.1) {
          let x = valueAlongCubicBezier(t: pct, start: start.x, c1: cp1.x, c2: cp2.x, end: end.x)
          let y = valueAlongCubicBezier(t: pct, start: start.y, c1: cp1.y, c2: cp2.y, end: end.y)
          interpolatedPoints.append(CGPoint(x: x, y: y))
        }
      }
    }
    
    return interpolatedPoints
  }
  
  // Cacluate points along cubic bezier line
  // http://ericasadun.com/2013/03/25/calculating-bezier-points/
  // t = pct: 0 to 1
  
  static func valueAlongCubicBezier(t: CGFloat, start: CGFloat, c1: CGFloat, c2: CGFloat, end: CGFloat) -> CGFloat {
    let t_: CGFloat = (1.0 - t);
    let tt_: CGFloat = t_ * t_;
    let ttt_: CGFloat = t_ * t_ * t_;
    let tt: CGFloat = t * t;
    let ttt: CGFloat = t * t * t;
    
    return start * ttt_
      + 3.0 *  c1 * tt_ * t
      + 3.0 *  c2 * t_ * tt
      + end * ttt;
  }
  
}

