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

protocol TimelineViewProtocol {
  func pillShouldEdit(pillView: PillView)
}

class TimelineView: UIView, PillPickerViewDelegate {
  
  // Constants
  let timeStep: Double = 0.25
  
  // Views
  let chartView = LineChartView()
  let pillPickerView: PillPickerView!
  var selectedPillViews: [PillView] = []
  var pillLongPressed: PillView?
  
  // Chart objects
  let totalSet = LineChartDataSet()
  var lowLimitLine: ChartLimitLine!
  var highLimitLine: ChartLimitLine!
  var selectedLimitLine: ChartLimitLine?
  
  // Data
  var delegate: TimelineViewProtocol?
  
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
    
    // Chart gestures
    chartView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(chartPanned(gesture:))))
    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(chartTapped(gesture:)))
    doubleTap.numberOfTapsRequired = 1
    chartView.addGestureRecognizer(doubleTap)
    
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
      make.bottom.equalTo(self).offset(-100.0)
    }
  }
  
  func formatChart() {
    // General chart properties
    chartView.doubleTapToZoomEnabled = false
    chartView.backgroundColor = UIColor.black
    chartView.chartDescription = nil
    chartView.drawGridBackgroundEnabled = false
    chartView.legend.textColor = UIColor.white
    
    // Left axis
    chartView.leftAxis.labelTextColor = UIColor.white
    chartView.leftAxis.axisMinimum = chartYAxisMin
    chartView.leftAxis.axisMaximum = chartYAxisMax
    chartView.leftAxis.drawGridLinesEnabled = false
    
    lowLimitLine = ChartLimitLine(limit: 4.0, label: "Low")
    lowLimitLine.lineColor = UIColor.green
    lowLimitLine.valueTextColor = UIColor.white
    chartView.leftAxis.addLimitLine(lowLimitLine)
    
    highLimitLine = ChartLimitLine(limit: 6.0, label: "High")
    highLimitLine.lineColor = UIColor.green
    highLimitLine.valueTextColor = UIColor.white
    chartView.leftAxis.addLimitLine(highLimitLine)
    
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
    totalSet.setDrawHighlightIndicators(false)
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
  
  func pillShouldEdit(pillView: PillView) {
    delegate?.pillShouldEdit(pillView: pillView)
  }
  
  // MARK: Pills
  
  func addPill(pillView: PillView) {
    selectedPillViews.append(pillView)
    addSubview(pillView)
    
    // Animate pill
    pillView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    UIView.animate(withDuration: 0.1,
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
    if let index = selectedPillViews.index(of: pill) {
      selectedPillViews.remove(at: index)
      pill.removeFromSuperview()
      recalcData()
    }
  }
  
  func recalcData() {
    var sets:[LineChartDataSet] = []
    
    // Create sets for each pill
    selectedPillViews.forEach { (pillView) in
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
    set.setDrawHighlightIndicators(false)
  }
  
  func adjustPillLocationBasedOnStartTime(pillView: PillView) {
    let locationX = locationForTime(time: pillView.pill.startTime)
    
    pillView.timeLabel.text = pillView.formattedStartTime()
    
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
  
  // MARK: Chart gesture
  
  func chartTapped(gesture: UIPanGestureRecognizer) {
    stopCurrentPillLongPressed()
  }
  
  func chartPanned(gesture: UIPanGestureRecognizer) {
    if gesture.state == .ended {
      selectedLimitLine = nil
    } else {
      let touchPoint: CGPoint = gesture.location(in: self.chartView)
      let dataPoint = self.chartView.valueForTouchPoint(point: touchPoint, axis: YAxis.AxisDependency.left)
      
      if gesture.state == .began {
        selectedLimitLine = getLimitLineForDataPoint(point: dataPoint)
      } else if gesture.state == .changed {
        if let limitLine = selectedLimitLine {
          limitLine.limit = Double(dataPoint.y)
          chartView.notifyDataSetChanged()
        }
      }
    }
  }
  
  // MARK: Moving limit lines
  
  func getLimitLineForDataPoint(point: CGPoint) -> ChartLimitLine? {
    let margin: CGFloat = 0.5
    if abs(point.y - CGFloat(lowLimitLine.limit)) < margin {
      return lowLimitLine
    } else if  abs(point.y - CGFloat(highLimitLine.limit)) < margin {
      return highLimitLine
    } else {
      return nil
    }
  }
  
  // MARK: Refresh pill data
  
  func refreshPillData(pill: Pill, profileData: [DoublePoint]) {
    let pillViewsToCheck: [PillView] = selectedPillViews + pillPickerView.pillViews

    pillViewsToCheck.forEach { (pillView) in
      if pillView.pill.name == pill.name {
        pillView.pill.updateProfileData(data: profileData)
      }
    }
    
    recalcData()
  }
  
}
