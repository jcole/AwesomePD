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
  var testButton = UIView()
  
  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    setupViews()
    refreshChartData()
  }

  // MARK: Setup
  
  func setupViews() {
    // Chart
    chartView.backgroundColor = UIColor.black
    view.addSubview(chartView)
    
    // Test Button
    testButton = UIView()
    testButton.backgroundColor = UIColor.blue
    testButton.isUserInteractionEnabled = true
    testButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonTapped)))
    view.addSubview(testButton)
    
    // Constraints
    chartView.snp.makeConstraints { (make) in
      make.left.top.equalTo(self.view).offset(30.0)
      make.right.equalTo(self.view).offset(-30.0)
      make.height.equalTo(self.view).multipliedBy(0.5)
    }
    
    testButton.snp.makeConstraints { (make) in
      make.width.equalTo(100.0)
      make.height.equalTo(40.0)
      make.centerX.equalTo(self.view)
      make.top.equalTo(chartView.snp.bottom).offset(30.0)
    }
  }
  
  // MARK: Chart

  func refreshChartData() {
    let setA = LineChartDataSet()
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
    
    let setB = LineChartDataSet()
    setB.label = "set B"
    setB.setColor(UIColor.cyan)
    setB.fillColor = UIColor.cyan
    setB.mode = .cubicBezier
    setB.drawFilledEnabled = true
    setB.fillAlpha = 0.3

    (0...10).forEach { (i) in
      let xValue = Double(i * 2)
      let yValue = Double(arc4random_uniform(10))
      setB.values.append(ChartDataEntry(x: xValue, y: yValue))
    }
    
    let chartData = LineChartData(dataSets: [setA, setB])
    chartView.data = chartData
  }

  // MARK: Gestures
  
  func buttonTapped() {
    refreshChartData()
  }

}

