//
//  Pill.swift
//  AwesomePD
//
//  Created by Jeff on 2/23/17.
//  Copyright © 2017 Team Awesome. All rights reserved.
//

import Foundation
import UIKit

class Pill {
  
  // Properties
  var name:String!
  var startTime:Double = 0.0
  var profileData:[DoublePoint] = []
  var interpolatedData:[DoublePoint] = []

  // MARK: Init
  
  init(name: String, profileData:[DoublePoint]) {
    self.name = name
    self.profileData = profileData
    self.interpolatedData = interpolatedData(data: profileData)
  }
  
  // MARK: Clone
  
  func clone() -> Pill {
    return Pill(name: name, profileData: profileData)
  }
  
  // MARK: Data methods
  
  func adjustedTimeData() -> [DoublePoint] {
    var adjusted:[DoublePoint] = []
    
    interpolatedData.forEach { (point) in
      adjusted.append(DoublePoint(x: point.x + startTime, y: point.y))
    }
    
    return adjusted
  }
  
  func interpolatedData(data: [DoublePoint]) -> [DoublePoint] {
    let cgPoints: [CGPoint] = convertToCGPoints(points: data)
    let adjustedData = SmoothLinePoints.smoothPointsThrough(points: cgPoints)
    let convertedData: [DoublePoint] = convertToDoublePoints(points: adjustedData)
    
    return convertedData
  }
  
  // MARK: Model data
  
  static func initData() -> [DoublePoint] {
    let data: [[Double]] = [
      [0.0, 0.0],
      [0.61218177028937, 1.94435243458099],
      [1.17893019265716, 3.28324122661739],
      [2.22426617169107, 3.91549426730124],
      [3.54667915721591, 4.01963006223741],
      [4.80612009581098, 3.48407454542285],
      [5.58697347773993, 2.8741363179396],
      [6.70787591308956, 1.83277836857795],
      [7.65245661703586, 0.984815466954901],
      [9.40307952168303, 0.590587100410849],
      [11.7456396674699, 0.374877239471651],
      [14.4282488666774, 0.114537752131239],
      [15.1461302016766, 0.0178402282619441],
      [16.2670326370262, 0.0]
    ]
    var points: [DoublePoint] = []
    data.forEach { (pair) in
      points.append(DoublePoint(x: pair[0], y: pair[1]))
    }
    return points
  }
  
}
