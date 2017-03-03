//
//  Pill.swift
//  AwesomePD
//
//  Created by Jeff on 2/23/17.
//  Copyright © 2017 Team Awesome. All rights reserved.
//

import Foundation
import UIKit

enum PillType {
  case Sinemet
  case Stalevo
  case Rotary
  case SinemetEntacapone
  case RotigotinePatch
}

class Pill {
  
  // Properties
  var type: PillType!
  var name:String!
  var startTime:Double = 0.0
  var profileData:[DoublePoint] = []
  var interpolatedData:[DoublePoint] = []

  // MARK: Init
  
  init(type: PillType, name: String, profileData: [DoublePoint]) {
    self.type = type
    self.name = name
    updateProfileData(data: profileData)
  }
  
  // MARK: Clone
  
  func clone() -> Pill {
    return Pill(type: type, name: name, profileData: profileData)
  }
  
  // MARK: Available pills
  
  static func availablePills() -> [Pill] {
    let pills: [Pill] = [
      Pill(type: .Sinemet, name: "Sinemet", profileData: defaultProfileDataForType(type: .Sinemet)),
      Pill(type: .Stalevo, name: "Stalevo ", profileData: defaultProfileDataForType(type: .Stalevo)),
      Pill(type: .Rotary, name: "Rotary", profileData: defaultProfileDataForType(type: .Rotary)),
      Pill(type: .SinemetEntacapone, name: "Sinemet + Entacapone", profileData: defaultProfileDataForType(type: .SinemetEntacapone)),
      Pill(type: .RotigotinePatch, name: "Rotigotine patch", profileData: defaultProfileDataForType(type: .RotigotinePatch)),
    ]
    
    return pills
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
  
  func updateProfileData(data: [DoublePoint]) {
    profileData = data
    interpolatedData = interpolatedData(data: data)
  }
  
  static func defaultProfileDataForType(type: PillType) -> [DoublePoint] {
    var data: [[Double]]
    
    switch type {
    case .Sinemet:
      data = [
        [0.0, 0.0],
        [0.5, 1.87],
        [1.0, 4.0],
        [1.5, 3.21],
        [4.0, 0.68],
        [10.0, 0.0]
      ]

    case .Stalevo:
      data = [
        [0.0, 0.0],
        [0.75, 1.94],
        [2.0, 3.95],
        [4.0, 2.69],
        [6.0, 1.34],
        [10.0, 0.0]
      ]

    case .Rotary:
      data = [
        [0.0, 0.0],
        [0.5, 1.87],
        [1.0, 4.0],
        [2.0, 3.93],
        [3.0, 4.69],
        [4.0, 3.61],
        [6.0, 4.63],
        [8.0, 1.97],
        [12.0, 1.04],
        [16.0, 0.55],
        [20.0, 0.0]
      ]

    case .SinemetEntacapone:
      data = [
        [0.0, 0.0],
        [1.0, 1.87],
        [1.8, 5.95],
        [2.8, 3.85],
        [4.0, 1.92],
        [10.0, 0.0]
      ]

    case .RotigotinePatch:
      data = [
        [0.0, 0.0],
        [1.0, 2.0],
        [2.0, 4.0],
        [4.0, 4.0],
        [8.0, 4.0],
        [12.0, 4.0],
        [14.0, 0.0]
      ]
    }
    
    var points: [DoublePoint] = []
    data.forEach { (pair) in
      points.append(DoublePoint(x: pair[0], y: pair[1]))
    }
    return points
  }
  
}
