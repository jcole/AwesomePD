//
//  DefineCurveView.swift
//  AwesomePD
//
//  Created by Jeff on 2/27/17.
//  Copyright © 2017 Team Awesome. All rights reserved.
//

import Foundation
import UIKit
import Charts

class DefineCurveView: UIView, ChartViewDelegate {

  // Subviews
  let chartView = LineChartView()
  let chartLine = LineChartDataSet()
  var selectedPoint: ChartDataEntry?
  
  // MARK: Init
  
  convenience init() {
    self.init(frame: CGRect.zero)
    setup()
    
    initData()
  }
  
  func setup() {
    // Chart
    chartView.delegate = self
    chartView.backgroundColor = UIColor.white
    chartView.highlightPerTapEnabled = true
    chartView.doubleTapToZoomEnabled = false
    chartView.maxHighlightDistance = 20.0
    chartView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(chartPanned(gesture:))))
    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(chartDoubleTapped(gesture:)))
    doubleTap.numberOfTapsRequired = 2
    chartView.addGestureRecognizer(doubleTap)
    chartView.dragEnabled = false
    chartView.xAxis.labelPosition = .bottom
    addSubview(chartView)
    
    // Data set
    chartLine.lineWidth = 4.0
    chartLine.setDrawHighlightIndicators(false)
    
    chartView.snp.makeConstraints { (make) in
      make.edges.equalTo(self).inset(UIEdgeInsetsMake(20, 20, 20, 20))
    }
  }
  
  func initData() {
    var dataValues:[ChartDataEntry] = []
    dataValues.append(ChartDataEntry(x: 0, y: 0))
    dataValues.append(ChartDataEntry(x: 1, y: 3))
    dataValues.append(ChartDataEntry(x: 5, y: 2))
    
    chartLine.values = dataValues
    chartView.data = LineChartData(dataSets: [chartLine])
    chartView.notifyDataSetChanged()
  }
  
  // MARK: - Dragging selected data point
  
  func updateSelectedPoint(x: Double, y: Double) {
    if let point = selectedPoint {
      point.x = x
      point.y = y
      sortDataPoints()
      chartView.notifyDataSetChanged()
    }
  }

  func unselectDataPoint() {
    selectedPoint = nil
  }
  
  func sortDataPoints() {
    chartLine.values.sort { (a, b) -> Bool in
      return a.x < b.x
    }
  }
  
  func addNewPointFromTouch(x: Double, y: Double) {
    let newEntry = ChartDataEntry(x: x, y: y)
    chartLine.values.append(newEntry)
    sortDataPoints()
    selectedPoint = newEntry
    chartView.notifyDataSetChanged()
  }
  
  func removePointByTouch(point: ChartDataEntry) {
    if let index = chartLine.values.index(of: point) {
      chartLine.values.remove(at: index)
      selectedPoint = nil
      chartView.notifyDataSetChanged()
    }
  }
  
  // MARK: ChartViewDelegate
  
  // Data point tapped
  func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
    print("Selected: \(entry)")
    selectedPoint = entry
  }
  
  // Tap on chart with no value
  func chartValueNothingSelected(_ chartView: ChartViewBase) {
    if let gestures = chartView.gestureRecognizers {
      gestures.forEach({ (gesture) in
        
        // Tap
        if gesture is UITapGestureRecognizer {
          if gesture.state == .ended {
            let touchPoint = gesture.location(in: self.chartView)
            let dataPoint = self.chartView.valueForTouchPoint(point: touchPoint, axis: YAxis.AxisDependency.left)
            print("Tap: \(touchPoint),  data : \(dataPoint)")
            addNewPointFromTouch(x: Double(dataPoint.x), y: Double(dataPoint.y))
          }
        }
      })
    }
  }
  
  // MARK: Gesture recognizer
  
  func chartDoubleTapped(gesture: UIPanGestureRecognizer) {
    let touchPoint: CGPoint = gesture.location(in: self.chartView)
    if let point = chartView.getEntryByTouchPoint(point: touchPoint) {
      removePointByTouch(point: point)
    }
  }
  
  func chartPanned(gesture: UIPanGestureRecognizer) {
    let touchPoint: CGPoint = gesture.location(in: self.chartView)
    let dataPoint = self.chartView.valueForTouchPoint(point: touchPoint, axis: YAxis.AxisDependency.left)

    if selectedPoint != nil {
      if gesture.state == .ended {
        unselectDataPoint()
      } else if gesture.state == .began || gesture.state == .changed {
        updateSelectedPoint(x: Double(dataPoint.x), y: Double(dataPoint.y))
      }
    } else if let point = chartView.getEntryByTouchPoint(point: touchPoint) {
      selectedPoint = point
      updateSelectedPoint(x: Double(dataPoint.x), y: Double(dataPoint.y))
    }
  }
  
}
