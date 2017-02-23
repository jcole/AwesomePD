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

  // Constants
  let minTime:Double = 0.0
  let maxTime:Double = 24.0
  let timeStep:Double = 0.25
  
  // Chart
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

  // Treatment selection container
  var treatmentSidebar = UIView()
  
  // Data
  let totalSet = LineChartDataSet()
  
  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    initData()
    setupViews()
  }

  // MARK: Create subviews
  
  func setupViews() {
    // Chart
    chartView.backgroundColor = UIColor.black
    chartView.chartDescription = nil
    chartView.leftAxis.labelTextColor = UIColor.white
    chartView.xAxis.labelTextColor = UIColor.white
    chartView.xAxis.labelPosition = .bottom
    view.addSubview(chartView)
    
    // Sidebar
    treatmentSidebar.backgroundColor = UIColor.clear
    treatmentSidebar.layer.borderColor = UIColor.black.cgColor
    treatmentSidebar.layer.borderWidth = 2.0
    treatmentSidebar.isUserInteractionEnabled = true
    treatmentSidebar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sidebarTapped)))
    view.addSubview(treatmentSidebar)
    
    // Test Buttons
    formatButton(button:blueButton, color: UIColor.cyan)
    view.addSubview(blueButton)

    formatButton(button:redButton, color: UIColor.red)
    view.addSubview(redButton)

    // Constraints
    treatmentSidebar.snp.makeConstraints { (make) in
      make.top.equalTo(self.view).offset(30.0)
      make.right.bottom.equalTo(self.view).offset(-30.0)
      make.width.equalTo(200.0)
    }

    chartView.snp.makeConstraints { (make) in
      make.left.top.equalTo(self.view).offset(30.0)
      make.right.equalTo(self.treatmentSidebar.snp.left).offset(-30.0)
      make.bottom.equalTo(self.view).offset(-80.0)
    }
    
    initChart()
  }
  
  func formatButton(button: UIView, color: UIColor) {
    button.backgroundColor = color
    button.isUserInteractionEnabled = true
    button.layer.cornerRadius = 20.0
    button.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(buttonPanned(recognizer:))))
  }
  
  func initChart() {
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
  
  func initData() {
    blueData = randomData()
    redData = randomData()
  }
  
  func randomData() -> [[Double]] {
    var data:[[Double]] = []
    
    data.append([0, 0])
    
    (1...numTimeSteps()).forEach { (i) in
      let xValue = Double(i) * timeStep
      let yValue = Double(arc4random_uniform(10))
      data.append([xValue, yValue])
    }
    
    return data
  }
  
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
  
  func adjustData(startTime: Double, initData: [[Double]]) -> [[Double]] {
    var adjusted:[[Double]] = []
    
    initData.forEach { (pair) in
      adjusted.append([pair[0] + startTime, pair[1]])
    }
    
    return adjusted
  }
  
  func recalcData() {
    let adjustedBlueData = adjustData(startTime: blueTime, initData: blueData)
    blueSet.values = chartDataEntries(pairs: adjustedBlueData)
    
    let adjustedRedData = adjustData(startTime: redTime, initData: redData)
    redSet.values = chartDataEntries(pairs: adjustedRedData)

    // Calculate totals
    let sets = [blueSet, redSet]
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
    return minTime + (maxTime - minTime) * Double((x - minX) / (maxX - minX))
  }
  
  func locationForTime(time: Double) -> CGFloat {
    let minX = minLocationX()
    let maxX = maxLocationX()
    return CGFloat(time / (maxTime - minTime)) * (maxX - minX) + minX
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
    recalcData()
    chartView.notifyDataSetChanged()
  }
  
  func setButtonTime(button: UIView, time: Double) {
    let location = locationForTime(time: time)
    moveButton(button: button, locationX: location)
    if button == redButton {
      redTime = time
    } else if button == blueButton {
      blueTime = time
    }
  }
  
  func moveButton(button: UIView, locationX:CGFloat) {
    button.snp.remakeConstraints { (make) in
      make.width.equalTo(100.0)
      make.height.equalTo(40.0)
      make.top.equalTo(chartView.snp.bottom).offset(20.0)
      make.centerX.equalTo(locationX)
    }
  }
  
  // MARK: Sidebar
  
  func sidebarTapped() {
    addButtons()
  }
  
  func addButtons() {
    // Set button after chart frame has laid out
    setButtonTime(button: blueButton, time: 8.0)
    setButtonTime(button: redButton, time: 16.0)
    
    recalcData()
    
    // specify data sets
    chartView.data = LineChartData(dataSets: [blueSet, redSet, totalSet])
    
    chartView.notifyDataSetChanged()
  }
  
}

