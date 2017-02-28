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
  var profileData:[[Double]] = []
  var interpolatedData:[[Double]] = []

  // MARK: Init
  
  init(name: String, profileData:[[Double]]) {
    self.name = name
    self.profileData = profileData
    self.interpolatedData = interpolatedData(data: profileData)
  }
  
  // MARK: Clone
  
  func clone() -> Pill {
    return Pill(name: name, profileData: profileData)
  }
  
  // MARK: Data methods
  
  func adjustedTimeData() -> [[Double]] {
    var adjusted:[[Double]] = []
    
    interpolatedData.forEach { (pair) in
      adjusted.append([pair[0] + startTime, pair[1]])
    }
    
    return adjusted
  }
  
  func interpolatedData(data: [[Double]]) -> [[Double]] {
    let startTime: Double = 0.0
    let endTime: Double = 24.0
    let timeStep: Double = 0.25
    
    var adjustedData: [[Double]] = []
    
    for xValue in stride(from: startTime, to: endTime, by: timeStep) {
      let yValue = interpolate(data: data, x: xValue)
      adjustedData.append([xValue, yValue])
    }
    
    return adjustedData
  }
  
  // TODO: currently linear interpolation
  func interpolate(data: [[Double]], x: Double) -> Double {
    var lastX: Double = 0.0
    var lastY: Double = 0.0
    for point in data {
      let dataX = point[0]
      let dataY = point[1]
      if ((x > lastX) && (x < dataX)) {
        let y: Double = lastY + (dataY - lastY) * (x - lastX) / (dataX - lastX)
        return y
      }
      lastX = dataX
      lastY = dataY
    }
    return 0.0
  }
  
  // MARK: Model data
  
  static func initData() -> [[Double]] {
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
    
    return data
  }
  
}
