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

class ViewController: UIViewController {

  var chartView = LineChartView()

  // Buttons
  var blueButton = UIView()
  var blueData:[[Double]] = []
  let blueSet = LineChartDataSet()
  var blueTime:Double = 0.0
  
  var redButton = UIView()
  var redData:[[Double]] = []
  let redSet = LineChartDataSet()
  var redTime:Double = 0.0

  let totalSet = LineChartDataSet()
  
  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    setupViews()
    initChart()
  }

  override func viewDidAppear(_ animated: Bool) {
    setButtonTime(button: blueButton, time: 8.0)
    setButtonTime(button: redButton, time: 16.0)
  }

  // MARK: Setup
  
  func setupViews() {
    // Chart
    chartView.backgroundColor = UIColor.black
    chartView.chartDescription = nil
    view.addSubview(chartView)
    
    // Test Buttons
    formatButton(button:blueButton, color: UIColor.cyan)
    view.addSubview(blueButton)

    formatButton(button:redButton, color: UIColor.red)
    view.addSubview(redButton)

    // Constraints
    chartView.snp.makeConstraints { (make) in
      make.left.top.equalTo(self.view).offset(30.0)
      make.right.equalTo(self.view).offset(-30.0)
      make.bottom.equalTo(self.view).offset(-80.0)
    }
  }
  
  // MARK: Create subviews

  func formatButton(button: UIView, color: UIColor) {
    button.backgroundColor = color
    button.isUserInteractionEnabled = true
    button.layer.cornerRadius = 20.0
    button.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(buttonPanned(recognizer:))))
  }
  
  func initChart() {
    blueData = randomData()
    redData = randomData()
    
    blueSet.label = "blue set"
    formatData(set: blueSet, color: UIColor.cyan)

    redSet.label = "red set"
    formatData(set: redSet, color: UIColor.red)
    
    totalSet.label = "total set"
    totalSet.setColor(UIColor.yellow)
    totalSet.mode = .cubicBezier
    totalSet.drawFilledEnabled = false
    totalSet.drawCirclesEnabled = false
    totalSet.drawValuesEnabled = false
    
    refreshData()
    let chartData = LineChartData(dataSets: [blueSet, redSet, totalSet])
    chartView.data = chartData
  }
  
  func formatData(set: LineChartDataSet, color: UIColor) {
    set.setColor(color)
    set.fillColor = color
    set.mode = .cubicBezier
    set.drawFilledEnabled = true
    set.drawCirclesEnabled = false
    set.drawValuesEnabled = false
    set.fillAlpha = 0.3
  }
  
  // MARK: Data
  
  func randomData() -> [[Double]] {
    var data:[[Double]] = []
    
    data.append([0, 0])
    
    (1...24).forEach { (i) in
      let xValue = Double(i)
      let yValue = Double(arc4random_uniform(10))
      data.append([xValue, yValue])
    }
    
    return data
  }
  
  func chartDataEntries(pairs:[[Double]]) -> [ChartDataEntry] {
    var entries:[ChartDataEntry] = []

    pairs.forEach { (pair) in
      entries.append(ChartDataEntry(x: pair[0], y: pair[1]))
    }
    
    return entries
  }
  
  func adjustData(startTime: Double, initData: [[Double]]) -> [[Double]] {
    var adjusted:[[Double]] = []
    
    initData.forEach { (pair) in
      adjusted.append([pair[0] + startTime, pair[1]])
    }
    
    return adjusted
  }
  
  func refreshData() {
    let adjustedBlueData = adjustData(startTime: blueTime, initData: blueData)
    blueSet.values = chartDataEntries(pairs: adjustedBlueData)
    
    let adjustedRedData = adjustData(startTime: redTime, initData: redData)
    redSet.values = chartDataEntries(pairs: adjustedRedData)

    // Calculate totals
    let sets = [blueSet, redSet]
    var totalData:[[Double]] = []
    (0...24).forEach { (xValue) in
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
    
    chartView.notifyDataSetChanged()
  }
  
  // MARK: Button movement
  
  func minLocationX() -> CGFloat {
    return chartView.frame.minX
  }
  
  func maxLocationX() -> CGFloat {
    return chartView.frame.maxX
  }
  
  func timeForLocationX(x: CGFloat) -> Double {
    let minX = minLocationX()
    let maxX = maxLocationX()
    return Double(24.0) * Double((x - minX) / (maxX - minX))
  }
  
  func locationForTime(time: Double) -> CGFloat {
    let minX = minLocationX()
    let maxX = maxLocationX()
    return CGFloat(time / 24.0) * (maxX - minX) + minX
  }
  
  func buttonPanned(recognizer: UIPanGestureRecognizer) {
    // Check bounds of button location
    let locationX = recognizer.location(in: self.view).x
    var adjustedLocation:CGFloat = locationX
    adjustedLocation = max(minLocationX(), adjustedLocation)
    adjustedLocation = min(maxLocationX(), adjustedLocation)
    
    // Adjust data
    let time = timeForLocationX(x: adjustedLocation)
    
    setButtonTime(button: recognizer.view!, time: time)
  }
  
  func setButtonTime(button: UIView, time: Double) {
    let location = locationForTime(time: time)
    moveButton(button: button, locationX: location)
    if button == redButton {
      redTime = time
    } else if button == blueButton {
      blueTime = time
    }
    
    refreshData()
  }
  
  func moveButton(button: UIView, locationX:CGFloat) {
    button.snp.remakeConstraints { (make) in
      make.width.equalTo(100.0)
      make.height.equalTo(40.0)
      make.top.equalTo(chartView.snp.bottom).offset(20.0)
      make.centerX.equalTo(locationX)
    }
  }
  
}

