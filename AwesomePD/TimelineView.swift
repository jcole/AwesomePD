//
//  TimelineView.swift
//  AwesomePD
//
//  Created by Jeff on 2/28/17.
//  Copyright © 2017 Team Awesome. All rights reserved.
//

import Foundation
import UIKit
import Charts
import SnapKit

class TimelineView: UIView, PillPickerViewDelegate {
  
  // Constants
  let timeStep: Double = 0.25
  
  // Views
  let chartView = LineChartView()
  let pillPickerView: PillPickerView!
  var selectedPills: [PillView] = []
  var pillLongPressed: PillView?
  
  // Calculated total data
  let totalSet = LineChartDataSet()

  // MARK: Init
  
  init(availablePills: [Pill]) {
    pillPickerView = PillPickerView(pills: availablePills)

    super.init(frame: CGRect.zero)

    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Setup subviews

  func setup() {
    isUserInteractionEnabled = true
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(screenTapped)))
    
    // Chart
    formatChart()
    addSubview(chartView)
    
    // Pillpicker
    pillPickerView.delegate = self
    addSubview(pillPickerView)
    
    // Constraints
    pillPickerView.snp.makeConstraints { (make) in
      make.top.equalTo(self).offset(30.0)
      make.right.equalTo(self).offset(-30.0)
      make.bottom.equalTo(self.chartView)
      make.width.equalTo(200.0)
    }
    
    chartView.snp.makeConstraints { (make) in
      make.left.top.equalTo(self).offset(30.0)
      make.right.equalTo(self.pillPickerView.snp.left).offset(-30.0)
      make.bottom.equalTo(self).offset(-80.0)
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
    chartView.leftAxis.axisMinimum = chartYAxisMin
    chartView.leftAxis.axisMaximum = chartYAxisMax
    chartView.leftAxis.drawGridLinesEnabled = false
    let lowLimitLine = ChartLimitLine(limit: 4.0, label: "Low")
    lowLimitLine.lineColor = UIColor.green
    lowLimitLine.valueTextColor = UIColor.white
    chartView.leftAxis.addLimitLine(lowLimitLine)
    
    let hightLimitLine = ChartLimitLine(limit: 6.0, label: "High")
    hightLimitLine.lineColor = UIColor.green
    hightLimitLine.valueTextColor = UIColor.white
    chartView.leftAxis.addLimitLine(hightLimitLine)
    
    // Right axis
    chartView.rightAxis.enabled = false
    
    // Horizontal axis
    chartView.xAxis.labelTextColor = UIColor.white
    chartView.xAxis.labelPosition = .bottom
    chartView.xAxis.axisMinimum = chartMinTime
    chartView.xAxis.axisMaximum = chartMaxTime
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
    
  func chartDataEntries(points:[DoublePoint]) -> [ChartDataEntry] {
    var entries:[ChartDataEntry] = []
    
    points.forEach { (point) in
      entries.append(ChartDataEntry(x: point.x, y: point.y))
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
    var calcTime = chartMinTime + (chartMaxTime - chartMinTime) * Double((x - minX) / (maxX - minX))
    
    // round to nearest step
    calcTime = calcTime - calcTime.truncatingRemainder(dividingBy: timeStep)
    
    return calcTime
  }
  
  func locationForTime(time: Double) -> CGFloat {
    let minX = minLocationX()
    let maxX = maxLocationX()
    return CGFloat(time / (chartMaxTime - chartMinTime)) * (maxX - minX) + minX
  }
  
  // MARK: PillPickerViewDelegate
  
  func pillSelected(pillView: PillView) {
    let pillCopy = pillView.clone()
    addPill(pillView: pillCopy)
    stopCurrentPillLongPressed()
  }
  
  // MARK: Pills
  
  func addPill(pillView: PillView) {
    selectedPills.append(pillView)
    addSubview(pillView)
    
    // Animate pill
    pillView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
    UIView.animate(withDuration: 0.2,
                   delay: 0.0,
                   usingSpringWithDamping: 0.2,
                   initialSpringVelocity: 6.0,
                   options: .allowUserInteraction,
                   animations: {
                    pillView.transform = .identity
    },
                   completion: nil
    )
    
    // Add gestures
    pillView.isUserInteractionEnabled = true
    pillView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pillPanned(recognizer:))))
    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(pillLongPressed(recognizer:)))
    longPress.minimumPressDuration = 0.75
    pillView.addGestureRecognizer(longPress)
    pillView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pillTapped(recognizer:))))
    
    pillView.pill.startTime = 12.0
    adjustPillLocationBasedOnStartTime(pillView: pillView)
    
    recalcData()
  }
  
  func removePill(pill: PillView) {
    if let index = selectedPills.index(of: pill) {
      selectedPills.remove(at: index)
      pill.removeFromSuperview()
      recalcData()
    }
  }
  
  func recalcData() {
    var sets:[LineChartDataSet] = []
    
    // Create sets for each pill
    selectedPills.forEach { (pillView) in
      let set = LineChartDataSet()
      formatPillDataSet(set: set, pillView: pillView)
      set.values = chartDataEntries(points: pillView.pill.adjustedTimeData())
      sets.append(set)
    }
    
    // Calculate totals
    var totalData:[DoublePoint] = []
    for xValue in stride(from: chartMinTime, to: chartMaxTime, by: timeStep) {
      var totalVal:Double = 0
      sets.forEach({ (set) in
        if Double(xValue) >= set.xMin {
          if let setVal = set.entryForXValue(Double(xValue), closestToY: 0.0)?.y {
            totalVal += setVal
          }
        }
      })
      
      totalData.append(DoublePoint(x: xValue, y: totalVal))
    }
    totalSet.values = chartDataEntries(points: totalData)
    sets.append(totalSet)
    
    // Refresh chart with new sets
    chartView.data = LineChartData(dataSets: sets)
    chartView.notifyDataSetChanged()
  }
  
  func formatPillDataSet(set: LineChartDataSet, pillView: PillView) {
    set.label = pillView.pill.name
    set.setColor(pillView.color)
    set.fillColor = pillView.color
    set.mode = .cubicBezier
    set.drawFilledEnabled = true
    set.drawCirclesEnabled = false
    set.drawValuesEnabled = false
    set.fillAlpha = 0.3
  }
  
  func adjustPillLocationBasedOnStartTime(pillView: PillView) {
    let locationX = locationForTime(time: pillView.pill.startTime)
    
    pillView.snp.remakeConstraints { (make) in
      make.width.equalTo(100.0)
      make.height.equalTo(40.0)
      make.top.equalTo(chartView.snp.bottom).offset(20.0)
      make.centerX.equalTo(locationX)
    }
  }
  
  func pillPanned(recognizer: UIPanGestureRecognizer) {
    stopCurrentPillLongPressed()
    
    if let pillView = recognizer.view as? PillView {
      // Check bounds of button location
      let locationX = recognizer.location(in: self).x
      var adjustedLocation:CGFloat = locationX
      adjustedLocation = max(minLocationX(), adjustedLocation)
      adjustedLocation = min(maxLocationX(), adjustedLocation)
      
      // Calculate time based on location
      let time = timeForLocationX(x: adjustedLocation)
      
      // Re-position pill
      adjustPillLocationBasedOnStartTime(pillView: pillView)
      
      // Adjust data
      pillView.pill.startTime = time
      recalcData()
    }
  }
  
  func pillLongPressed(recognizer: UIPanGestureRecognizer) {
    stopCurrentPillLongPressed()
    
    if let pillView = recognizer.view as? PillView {
      pillLongPressed = pillView
      
      // Animate pill shimmy
      pillView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * -3.0 / 180.0)
      UIView.animate(withDuration: 0.1,
                     delay: 0.0,
                     options: [.allowUserInteraction, .repeat, .autoreverse],
                     animations: {
                      pillView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 3.0 / 180.0)
      }, completion: nil
      )
    }
  }
  
  func pillTapped(recognizer: UIPanGestureRecognizer) {
    if let pillView = recognizer.view as? PillView {
      if pillView == pillLongPressed {
        removePill(pill: pillView)
      }
    }
    
    pillLongPressed = nil
  }
  
  func stopCurrentPillLongPressed() {
    if pillLongPressed != nil {
      pillLongPressed!.layer.removeAllAnimations()
      pillLongPressed!.transform = .identity
    }
    pillLongPressed = nil
  }
  
  // MARK: Screen gesture
  
  func screenTapped() {
    stopCurrentPillLongPressed()
  }
  
}
