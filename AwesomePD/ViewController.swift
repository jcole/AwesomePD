//
//  ViewController.swift
//  AwesomePD
//
//  Created by Jeff on 2/22/17.
//  Copyright © 2017 Team Awesome. All rights reserved.
//

import UIKit
import Charts
import SnapKit

class ViewController: UIViewController, PillPickerDelegate {

  // Constants
  let minTime:Double = 0.0
  let maxTime:Double = 24.0
  let timeStep:Double = 0.25
  
  // Views
  let chartView = LineChartView()
  let pillPicker = PillPicker()
  var pills:[Pill] = []
  
  // Calculated total data
  let totalSet = LineChartDataSet()
  
  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    setup()
  }

  // MARK: Setup subviews
  
  func setup() {
    // Chart
    formatChart()
    view.addSubview(chartView)
    
    // Pillpicker
    pillPicker.delegate = self
    view.addSubview(pillPicker)

    // Constraints
    pillPicker.snp.makeConstraints { (make) in
      make.top.equalTo(self.view).offset(30.0)
      make.right.equalTo(self.view).offset(-30.0)
      make.bottom.equalTo(self.chartView)
      make.width.equalTo(200.0)
    }

    chartView.snp.makeConstraints { (make) in
      make.left.top.equalTo(self.view).offset(30.0)
      make.right.equalTo(self.pillPicker.snp.left).offset(-30.0)
      make.bottom.equalTo(self.view).offset(-80.0)
    }
  }
  
  func formatChart() {
    // General chart properties
    chartView.backgroundColor = UIColor.black
    chartView.chartDescription = nil
    chartView.drawGridBackgroundEnabled = false
    chartView.legend.textColor = UIColor.white
    
    // Left axis
    chartView.leftAxis.labelTextColor = UIColor.white
    chartView.leftAxis.axisMinimum = 0.0
    chartView.leftAxis.axisMaximum = 20.0
    chartView.leftAxis.drawGridLinesEnabled = false
    let lowLimitLine = ChartLimitLine(limit: 4.0, label: "Low")
    lowLimitLine.lineColor = UIColor.green
    lowLimitLine.valueTextColor = UIColor.white
    chartView.leftAxis.addLimitLine(lowLimitLine)

    let hightLimitLine = ChartLimitLine(limit: 10.0, label: "High")
    hightLimitLine.lineColor = UIColor.green
    hightLimitLine.valueTextColor = UIColor.white
    chartView.leftAxis.addLimitLine(hightLimitLine)
    
    // Right axis
    chartView.rightAxis.enabled = false

    // Horizontal axis
    chartView.xAxis.labelTextColor = UIColor.white
    chartView.xAxis.labelPosition = .bottom
    chartView.xAxis.axisMinimum = minTime
    chartView.xAxis.axisMaximum = maxTime
    chartView.xAxis.drawGridLinesEnabled = true
    
    // Total data set
    totalSet.label = "total effect"
    totalSet.setColor(UIColor.yellow)
    totalSet.mode = .cubicBezier
    totalSet.drawFilledEnabled = false
    totalSet.drawCirclesEnabled = false
    totalSet.drawValuesEnabled = false
  }
  
  // MARK: Data methods
  
  func numTimeSteps() -> Int {
    return Int((maxTime - minTime) / timeStep)
  }
  
  func chartDataEntries(pairs:[[Double]]) -> [ChartDataEntry] {
    var entries:[ChartDataEntry] = []

    pairs.forEach { (pair) in
      entries.append(ChartDataEntry(x: pair[0], y: pair[1]))
    }
    
    return entries
  }
  
  // MARK: Pill movement
  
  func minLocationX() -> CGFloat {
    return chartView.frame.minX
  }
  
  func maxLocationX() -> CGFloat {
    return chartView.frame.maxX
  }
  
  func timeForLocationX(x: CGFloat) -> Double {
    let minX = minLocationX()
    let maxX = maxLocationX()
    var calcTime = minTime + (maxTime - minTime) * Double((x - minX) / (maxX - minX))
    
    // round to nearest step
    calcTime = calcTime - calcTime.truncatingRemainder(dividingBy: timeStep)
    
    return calcTime
  }
  
  func locationForTime(time: Double) -> CGFloat {
    let minX = minLocationX()
    let maxX = maxLocationX()
    return CGFloat(time / (maxTime - minTime)) * (maxX - minX) + minX
  }
  
  // MARK: PillPickerDelegate
  
  func pillSelected(pill: Pill) {
    let pillCopy = pill.clone()
    addPill(pill: pillCopy)
  }

  // MARK: Pills

  func addPill(pill: Pill) {
    self.pills.append(pill)
    self.view.addSubview(pill)
    
    pill.isUserInteractionEnabled = true
    pill.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pillPanned(recognizer:))))

    pill.startTime = 12.0
    adjustPillLocationBasedOnStartTime(pill: pill)
    
    recalcData()
  }
  
  func recalcData() {
    var sets:[LineChartDataSet] = []
    
    // Create sets for each pill
    pills.forEach { (pill) in
      let set = LineChartDataSet()
      formatPillDataSet(set: set, pill: pill)
      set.values = chartDataEntries(pairs: pill.adjustedTimeData())
      sets.append(set)
    }
    
    // Calculate totals
    var totalData:[[Double]] = []
    (0...numTimeSteps()).forEach { (step) in
      let xValue:Double = Double(step) * timeStep
      var totalVal:Double = 0
      sets.forEach({ (set) in
        if Double(xValue) >= set.xMin {
          if let setVal = set.entryForXValue(Double(xValue), closestToY: 0.0)?.y {
            totalVal += setVal
          }
        }
      })
      
      totalData.append([Double(xValue), totalVal])
    }
    totalSet.values = chartDataEntries(pairs: totalData)
    sets.append(totalSet)
  
    // Refresh chart with new sets
    chartView.data = LineChartData(dataSets: sets)
    chartView.notifyDataSetChanged()
  }
  
  func formatPillDataSet(set: LineChartDataSet, pill: Pill) {
    set.label = pill.name
    set.setColor(pill.color)
    set.fillColor = pill.color
    set.mode = .cubicBezier
    set.drawFilledEnabled = true
    set.drawCirclesEnabled = false
    set.drawValuesEnabled = false
    set.fillAlpha = 0.3
  }
  
  func adjustPillLocationBasedOnStartTime(pill: Pill) {
    let locationX = locationForTime(time: pill.startTime)

    pill.snp.remakeConstraints { (make) in
      make.width.equalTo(100.0)
      make.height.equalTo(40.0)
      make.top.equalTo(chartView.snp.bottom).offset(20.0)
      make.centerX.equalTo(locationX)
    }
  }
  
  func pillPanned(recognizer: UIPanGestureRecognizer) {
    if let pill = recognizer.view as? Pill {
      // Check bounds of button location
      let locationX = recognizer.location(in: self.view).x
      var adjustedLocation:CGFloat = locationX
      adjustedLocation = max(minLocationX(), adjustedLocation)
      adjustedLocation = min(maxLocationX(), adjustedLocation)

      // Calculate time based on location
      let time = timeForLocationX(x: adjustedLocation)
      
      // Re-position pill
      adjustPillLocationBasedOnStartTime(pill: pill)

      // Adjust data
      pill.startTime = time
      recalcData()
    }
  }
}

