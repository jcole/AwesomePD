//
//  Pill.swift
//  AwesomePD
//
//  Created by Jeff on 2/23/17.
//  Copyright © 2017 Team Awesome. All rights reserved.
//

import Foundation
import UIKit

class Pill: UIView {
  
  // Properties
  var name:String!
  var color:UIColor!
  var profileData:[[Double]] = []
  var startTime:Double = 0.0
  
  // Constants
  let pillWidth:CGFloat = 100.0
  let pillHeight:CGFloat = 40.0
  
  // MARK: Init
  
  init(name: String, color: UIColor, profileData:[[Double]]) {
    self.name = name
    self.color = color
    self.profileData = profileData
    
    super.init(frame: CGRect(x: 0, y: 0, width: pillWidth, height: pillHeight))

    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setup() {
    backgroundColor = color
    layer.borderColor = UIColor.lightGray.cgColor
    layer.borderWidth = 1.0
    layer.cornerRadius = 20.0
  }

  // MARK: copy 
  
  func clone() -> Pill {
    return Pill(name: self.name, color: self.color, profileData: self.profileData)
  }
  
  // MARK: Data methods
  
  func adjustedTimeData() -> [[Double]] {
    var adjusted:[[Double]] = []
    
    profileData.forEach { (pair) in
      adjusted.append([pair[0] + startTime, pair[1]])
    }
    
    return adjusted
  }
  
  // TODO: Replace this with actual profile data

  static func getAvailablePills() -> [Pill] {
    let pills = [
      Pill(name: "blue pill", color: .cyan, profileData: Pill.randomData(magnitude: 8.0)),
      Pill(name: "red pill", color: .red, profileData: Pill.randomData(magnitude: 4.0)),
      Pill(name: "green pill", color: .green, profileData: Pill.randomData(magnitude: 2.0)),
      Pill(name: "purple pill", color: .purple, profileData: Pill.randomData(magnitude: 1.0)),
      ]
    
    return pills
  }
  
  static func randomData(magnitude:Double) -> [[Double]] {
    var data:[[Double]] = []
    
    let numTimeSteps = 24 * 4
    let timeStep:Double = 0.25
    let fudgeX:Double = 0.5
    var hitZero:Bool = false
    
    data.append([0, 0])
    
    (1...numTimeSteps).forEach { (i) in
      let xValue = Double(i) * timeStep
      var yValue = magnitude * Double(sin(xValue * fudgeX))
      if hitZero || yValue <= 0.0 {
        yValue = 0.0
        hitZero = true
      }
      
      data.append([xValue, yValue])
    }
    
    return data
  }
  
}
