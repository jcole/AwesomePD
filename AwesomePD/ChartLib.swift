//
//  ChartLib.swift
//  AwesomePD
//
//  Created by Jeff on 2/28/17.
//  Copyright © 2017 Team Awesome. All rights reserved.
//

import Foundation
import Charts

func chartDataEntries(points:[DoublePoint]) -> [ChartDataEntry] {
  var entries:[ChartDataEntry] = []
  
  points.forEach { (point) in
    entries.append(ChartDataEntry(x: point.x, y: point.y))
  }
  
  return entries
}

func chartDataEntriesToDoubles(points: [ChartDataEntry]) -> [DoublePoint] {
  var data:[DoublePoint] = []
  
  points.forEach { (point) in
    data.append(DoublePoint(x: point.x, y: point.y))
  }
  
  return data
}
