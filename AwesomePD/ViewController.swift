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
  var redButton = UIView()

  // Data sets
  let setA = LineChartDataSet()
  let setB = LineChartDataSet()
  let setTotal = LineChartDataSet()
  
  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    setupViews()
    initChartData()
  }

  // MARK: Setup
  
  func setupViews() {
    // Chart
    chartView.backgroundColor = UIColor.black
    chartView.chartDescription = nil
    view.addSubview(chartView)
    
    // Test Buttons
    blueButton = UIView()
    blueButton.backgroundColor = UIColor.cyan
    blueButton.isUserInteractionEnabled = true
    blueButton.layer.cornerRadius = 20.0
    blueButton.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(buttonPanned(recognizer:))))
    view.addSubview(blueButton)

    redButton = UIView()
    redButton.backgroundColor = UIColor.red
    redButton.isUserInteractionEnabled = true
    redButton.layer.cornerRadius = 20.0
    redButton.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(buttonPanned(recognizer:))))
    view.addSubview(redButton)

    // Constraints
    chartView.snp.makeConstraints { (make) in
      make.left.top.equalTo(self.view).offset(30.0)
      make.right.equalTo(self.view).offset(-30.0)
      make.bottom.equalTo(self.view).offset(-80.0)
    }
    
    moveButton(button: blueButton, locationX: view.center.x - 100.0)
    moveButton(button: redButton, locationX: view.center.x + 100.0)
  }
  
  // MARK: Chart
  
  func initChartData() {
    setA.label = "set A"
    setA.setColor(UIColor.red)
    setA.fillColor = UIColor.red
    setA.mode = .cubicBezier
    setA.drawFilledEnabled = true
    setA.fillAlpha = 0.3

    (0...20).forEach { (i) in
      let xValue = Double(i)
      let yValue = Double(arc4random_uniform(10))
      setA.values.append(ChartDataEntry(x: xValue, y: yValue))
    }
    
    setB.label = "set B"
    setB.setColor(UIColor.cyan)
    setB.fillColor = UIColor.cyan
    setB.mode = .cubicBezier
    setB.drawFilledEnabled = true
    setB.fillAlpha = 0.3

    (0...20).forEach { (i) in
      let xValue = Double(i)
      let yValue = Double(arc4random_uniform(10))
      setB.values.append(ChartDataEntry(x: xValue, y: yValue))
    }
    
    setTotal.label = "set Total"
    setTotal.setColor(UIColor.yellow)
    setTotal.mode = .cubicBezier
    setTotal.drawFilledEnabled = false

    setTotal.values = calculateTotalValues()
    
    let chartData = LineChartData(dataSets: [setA, setB, setTotal])
    chartView.data = chartData
  }

  func refreshChartData(set:LineChartDataSet) {
    (0...set.entryCount - 1).forEach({ (i) in
      set.entryForIndex(i)?.y += -0.25 + 0.5 * Double(arc4random_uniform(100)) / 100.0
    })
    
    setTotal.values = calculateTotalValues()
    chartView.notifyDataSetChanged()
  }
  
  func calculateTotalValues() -> [ChartDataEntry] {
    var totalValues:[ChartDataEntry] = []
    
    (0...20).forEach { (xValue) in
      let aVal:Double? = setA.entryForXValue(Double(xValue), closestToY: 0.0)?.y
      let bVal:Double? = setB.entryForXValue(Double(xValue), closestToY: 0.0)?.y
      
      var totalVal:Double = 0
      if aVal != nil {
        totalVal += aVal!
      }
      
      if bVal != nil {
        totalVal += bVal!
      }
      
      totalValues.append(ChartDataEntry(x: Double(xValue), y: totalVal))
    }
    
    return totalValues
  }

  // MARK: Button
  
  func moveButton(button:UIView, locationX: CGFloat) {
    button.snp.remakeConstraints { (make) in
      make.width.equalTo(100.0)
      make.height.equalTo(40.0)
      make.top.equalTo(chartView.snp.bottom).offset(20.0)
      make.centerX.equalTo(locationX)
    }
  }

  // MARK: Gestures
  
  func buttonPanned(recognizer: UIPanGestureRecognizer) {
    let locationX = recognizer.location(in: self.view).x

    var buttonTapped:UIView?
    var set:LineChartDataSet?
    
    if recognizer.view == redButton {
      buttonTapped = redButton
      set = setA
    } else if recognizer.view == blueButton {
      buttonTapped = blueButton
      set = setB
    }
    
    if set != nil {
      refreshChartData(set:set!)
    }
    if buttonTapped != nil {
      moveButton(button:buttonTapped!, locationX: locationX)
    }
  }
  
}

