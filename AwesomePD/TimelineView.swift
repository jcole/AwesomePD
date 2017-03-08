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
  let timeStep: Double = 0.25 // For snapping pills to timeline
  let totalStep: Double = 0.1 // Resolution of calculating total value
  
  // Views
  let chartView = LineChartView()
  let pillPickerView: PillPickerView!
  var timelinePillViews: [PillView] = []
  var pillViewLongPressed: PillView?
  var pillViewBeingAdded: PillView?
  var scoreLabel = UILabel()
  var highScoreLabel = UILabel()
  var highScore:Double = 0.0
  
  // Chart objects
  let totalSet = LineChartDataSet()
  var lowLimitLine: ChartLimitLine!
  var highLimitLine: ChartLimitLine!
  var selectedLimitLine: ChartLimitLine?
  var pillBeingAddedLimitLine: ChartLimitLine!
  
  // Data
  var delegate: TimelineViewProtocol?
  
  // MARK: Init
  
  init(availablePills: [Pill]) {
    pillPickerView = PillPickerView(pills: availablePills)

    super.init(frame: CGRect.zero)

    setup()
    recalcData()
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
    
    // Labels
    scoreLabel.textAlignment = .left
    scoreLabel.font = UIFont.systemFont(ofSize: 14.0)
    addSubview(scoreLabel)
    
    highScoreLabel.textAlignment = .left
    highScoreLabel.font = UIFont.systemFont(ofSize: 12.0)
    addSubview(highScoreLabel)
    
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
    
    scoreLabel.snp.makeConstraints { (make) in
      make.left.right.equalTo(self.pillPickerView)
      make.height.equalTo(30.0)
      make.top.equalTo(self.pillPickerView.snp.bottom).offset(10.0)
    }
    
    highScoreLabel.snp.makeConstraints { (make) in
      make.width.height.equalTo(self.scoreLabel)
      make.left.equalTo(self.scoreLabel)
      make.top.equalTo(self.scoreLabel.snp.bottom).offset(10.0)
    }
  }
  
  // MARK: Chart formatting
  
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
    
    // Limit line for pill being added
    pillBeingAddedLimitLine = ChartLimitLine(limit: 0.0)
    pillBeingAddedLimitLine.lineWidth = 1.0
    pillBeingAddedLimitLine.enabled = false
    chartView.xAxis.addLimitLine(pillBeingAddedLimitLine)
    
    // Total data set
    totalSet.label = "total effect"
    totalSet.setColor(UIColor.yellow)
    totalSet.mode = .linear
    totalSet.drawFilledEnabled = false
    totalSet.drawCirclesEnabled = false
    totalSet.drawValuesEnabled = false
    totalSet.setDrawHighlightIndicators(false)
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
  
  // MARK: Chart data
  
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
  
  func recalcData() {
    var sets:[LineChartDataSet] = []
    
    // Create sets for each pill
    timelinePillViews.forEach { (pillView) in
      let set = LineChartDataSet()
      formatPillDataSet(set: set, pillView: pillView)
      set.values = chartDataEntries(points: pillView.pill.adjustedTimeData())
      sets.append(set)
    }
    
    // Limits for score
    let highLimit = highLimitLine.limit
    let lowLimit = lowLimitLine.limit
    var inRangeCount: Int = 0
    var outOfRangeCount: Int = 0
    
    // Calculate totals and score
    var totalData:[DoublePoint] = []
    for xValue in stride(from: chartMinTime, to: chartMaxTime, by: totalStep) {
      var totalVal:Double = 0
      sets.forEach({ (set) in
        if Double(xValue) >= set.xMin {
          if let setVal = set.entryForXValue(Double(xValue), closestToY: 0.0)?.y {
            //print("xValue: \(xValue), set: \(set.label), setVal: \(setVal)")
            totalVal += setVal
          } else {
            //print("xValue: \(xValue), set: \(set.label), setVal: NONE")
          }
          
        }
      })
      //print("xValue: Total: \(totalVal)")
      totalData.append(DoublePoint(x: xValue, y: totalVal))
      
      if ((totalVal >= lowLimit) && (totalVal <= highLimit)) {
        inRangeCount += 1
      } else {
        outOfRangeCount += 1
      }
    }
    totalSet.values = chartDataEntries(points: totalData)
    sets.append(totalSet)
    
    // Refresh chart with new sets
    chartView.data = LineChartData(dataSets: sets)
    chartView.notifyDataSetChanged()
    
    // Update score
    let score: Double = Double(inRangeCount) / Double(inRangeCount + outOfRangeCount)
    updateScore(currentScore: score)
  }
  
  func updateScore(currentScore: Double) {
    if currentScore > highScore {
      highScore = currentScore
    }
    
    // Update score
    let currentScorePercentString = formatPercent(pct: currentScore)
    let attributedCurrentScoreString = NSMutableAttributedString(string: "\(currentScorePercentString) in range")
    attributedCurrentScoreString.addAttributes(
      [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 22.0)],
      range: NSRange(location: 0, length: currentScorePercentString.characters.count)
    )
    scoreLabel.attributedText = attributedCurrentScoreString
    
    let highScorePercentString = formatPercent(pct: highScore)
    let attributedHighScoreString = NSMutableAttributedString(string: "\(highScorePercentString) highest score")
    attributedHighScoreString.addAttributes(
      [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 22.0)],
      range: NSRange(location: 0, length: highScorePercentString.characters.count)
    )
    highScoreLabel.attributedText = attributedHighScoreString
  }
  
  func formatPercent(pct: Double) -> String {
    let scorePct: Int = Int(100.0 * pct)
    return "\(scorePct)%"
  }
  
  // MARK: PillPickerViewDelegate
  
  func pillPickerPillViewShouldEdit(pillView: PillView) {
    delegate?.pillShouldEdit(pillView: pillView)
  }
  
  func pillPickerPillViewPanned(pillView: PillView, gesture: UIPanGestureRecognizer) {
    let location = gesture.location(in: self)

    if gesture.state == .began {
      stopCurrentPillViewLongPressed()
      
      pillViewBeingAdded = pillView.clone()
      addSubview(pillViewBeingAdded!)
      pillViewBeingAdded!.center = location
      
      pillPickerView.hidePillView(pillView: pillView)
      
      pillBeingAddedLimitLine.lineColor = pillView.color
    } else if gesture.state == .ended {
      if pillViewBeingAdded != nil {
        if chartView.frame.contains(location) {
          // Hide limit line
          pillBeingAddedLimitLine.enabled = false

          // Add pill to timeline
          pillViewBeingAdded!.center = location
          let pillCopy = pillView.clone()
          addTimelinePillView(pillView: pillCopy, locationX: location.x)
        }
        
        // Remove from view
        pillViewBeingAdded!.removeFromSuperview()
        pillViewBeingAdded = nil
        
        // Re-show in picker
        pillPickerView.showPillView(pillView: pillView)
      }
    } else {
      if let pillView = pillViewBeingAdded {
        pillView.center = location
        if chartView.frame.contains(location) {
          pillView.nameLabel.textColor = UIColor.white
          pillBeingAddedLimitLine.limit = timeForLocationX(x: location.x)
          pillBeingAddedLimitLine.enabled = true
          chartView.notifyDataSetChanged()
        } else {
          pillView.nameLabel.textColor = UIColor.black
          pillBeingAddedLimitLine.enabled = false
          chartView.notifyDataSetChanged()
        }
      }
    }
  }
  
  // MARK: Timeline PillViews
  
  func addTimelinePillView(pillView: PillView, locationX: CGFloat) {
    timelinePillViews.append(pillView)
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
    // pan
    pillView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(timelinePillViewPanned(recognizer:))))
    // long press
    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(timelinePillViewLongPressed(recognizer:)))
    longPress.minimumPressDuration = 0.75
    pillView.addGestureRecognizer(longPress)
    // double tap
    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(timelinePillViewDoubleTapped(recognizer:)))
    doubleTap.numberOfTapsRequired = 2
    pillView.addGestureRecognizer(doubleTap)
    // single tap
    let singleTap = UITapGestureRecognizer(target: self, action: #selector(timelinePillViewTapped(recognizer:)))
    singleTap.numberOfTapsRequired = 1
    singleTap.require(toFail: doubleTap)
    pillView.addGestureRecognizer(singleTap)
    
    
    pillView.pill.startTime = timeForLocationX(x: locationX)
    adjustTimelinePillViewLocationBasedOnStartTime(pillView: pillView)
    
    recalcData()
  }
  
  func removeTimelinePillView(pill: PillView) {
    if let index = timelinePillViews.index(of: pill) {
      timelinePillViews.remove(at: index)
      pill.removeFromSuperview()
      recalcData()
    }
  }
  
  func adjustTimelinePillViewLocationBasedOnStartTime(pillView: PillView) {
    let locationX = locationForTime(time: pillView.pill.startTime)
    
    pillView.timeLabel.text = pillView.formattedStartTime()
    
    pillView.snp.remakeConstraints { (make) in
      make.width.equalTo(100.0)
      make.height.equalTo(40.0)
      make.top.equalTo(chartView.snp.bottom).offset(20.0)
      make.centerX.equalTo(locationX)
    }
  }
  
  func timelinePillViewPanned(recognizer: UIPanGestureRecognizer) {
    stopCurrentPillViewLongPressed()
    
    if let pillView = recognizer.view as? PillView {
      // Check bounds of button location
      let locationX = recognizer.location(in: self).x
      var adjustedLocation:CGFloat = locationX
      adjustedLocation = max(minLocationX(), adjustedLocation)
      adjustedLocation = min(maxLocationX(), adjustedLocation)
      
      // Calculate time based on location
      let time = timeForLocationX(x: adjustedLocation)
      
      // Re-position pill
      adjustTimelinePillViewLocationBasedOnStartTime(pillView: pillView)
      
      // Adjust data
      pillView.pill.startTime = time
      recalcData()
    }
  }
  
  func timelinePillViewLongPressed(recognizer: UIPanGestureRecognizer) {
    stopCurrentPillViewLongPressed()
    
    if let pillView = recognizer.view as? PillView {
      pillViewLongPressed = pillView
      
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
  
  func timelinePillViewTapped(recognizer: UIPanGestureRecognizer) {
    if let pillView = recognizer.view as? PillView {
      if pillView == pillViewLongPressed {
        removeTimelinePillView(pill: pillView)
      }
    }
    
    pillViewLongPressed = nil
  }
  
  func timelinePillViewDoubleTapped(recognizer: UIPanGestureRecognizer) {
    if let pillView = recognizer.view as? PillView {
      delegate?.pillShouldEdit(pillView: pillView)
    }
    
    pillViewLongPressed = nil
  }
  
  func stopCurrentPillViewLongPressed() {
    if pillViewLongPressed != nil {
      pillViewLongPressed!.layer.removeAllAnimations()
      pillViewLongPressed!.transform = .identity
    }
    pillViewLongPressed = nil
  }
  
  // MARK: Screen gesture
  
  func screenTapped() {
    stopCurrentPillViewLongPressed()
  }
  
  // MARK: Chart gesture
  
  func chartTapped(gesture: UIPanGestureRecognizer) {
    stopCurrentPillViewLongPressed()
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
          recalcData()
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
  
  // MARK: Refresh pill data from curve definition
  
  func refreshPillData(pill: Pill, profileData: [DoublePoint]) {
    let pillViewsToCheck: [PillView] = timelinePillViews + pillPickerView.pillViews

    pillViewsToCheck.forEach { (pillView) in
      if pillView.pill.name == pill.name {
        pillView.pill.updateProfileData(data: profileData)
      }
    }
    
    recalcData()
  }
  
}
