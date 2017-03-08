//
//  TimeFormatter.swift
//  AwesomePD
//
//  Created by Jeff on 3/8/17.
//  Copyright © 2017 Team Awesome. All rights reserved.
//

import Foundation

func formatTime(dayFraction: Double) -> String {
  let hour = Int(dayFraction)
  let hourString = String(format: "%02d", hour)
  let min = Int((dayFraction - floor(dayFraction)) * 60)
  let minString = String(format: "%02d", min)
  
  return "\(hourString):\(minString)"
}
