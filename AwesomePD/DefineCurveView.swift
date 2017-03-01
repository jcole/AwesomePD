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

protocol DefineCurveViewDelegate {
  func pillCurveUpdated(pill: Pill, profileData: [DoublePoint])
  func pillCurveCancelled()
}

class DefineCurveView: UIView, ChartViewDelegate {

  // Subviews
  let chartView = LineChartView()
  let chartLine = LineChartDataSet()
  var selectedPoint: ChartDataEntry?
  var okView = UIImageView()
  var cancelView = UIImageView()
  
  // Data
  var delegate: DefineCurveViewDelegate?
  var pill: Pill?
  
  // MARK: Init
  
  convenience init() {
    self.init(frame: CGRect.zero)
    setup()
  }
  
  func setup() {
    // Add chart
    addSubview(chartView)

    // Chart formatting
    chartView.delegate = self
    chartView.backgroundColor = UIColor.white
    chartView.highlightPerTapEnabled = true
    chartView.doubleTapToZoomEnabled = false
    chartView.maxHighlightDistance = 20.0
    chartView.dragEnabled = false
    chartView.xAxis.labelPosition = .bottom
    chartView.xAxis.axisMinimum = chartMinTime
    chartView.xAxis.axisMaximum = chartMaxTime
    chartView.leftAxis.axisMinimum = chartYAxisMin
    chartView.leftAxis.axisMaximum = chartYAxisMax
    chartView.rightAxis.enabled = false

    // Chart gestures
    chartView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(chartPanned(gesture:))))
    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(chartDoubleTapped(gesture:)))
    doubleTap.numberOfTapsRequired = 2
    chartView.addGestureRecognizer(doubleTap)

    // Data set
    chartLine.lineWidth = 4.0
    chartLine.setDrawHighlightIndicators(false)
    
    // Ok/Cancel views
    okView.backgroundColor = UIColor.green
    okView.isUserInteractionEnabled = true
    okView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(okTapped)))
    addSubview(okView)

    cancelView.backgroundColor = UIColor.red
    cancelView.isUserInteractionEnabled = true
    cancelView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelTapped)))
    addSubview(cancelView)

    // Constraints
    chartView.snp.makeConstraints { (make) in
      make.edges.equalTo(self).inset(UIEdgeInsetsMake(20, 20, 20, 20))
    }
    
    okView.snp.makeConstraints { (make) in
      make.width.height.equalTo(60.0)
      make.top.equalTo(self)
      make.right.equalTo(cancelView.snp.left)
    }
    
    cancelView.snp.makeConstraints { (make) in
      make.width.height.equalTo(60.0)
      make.top.right.equalTo(self)
    }
  }
  
  func initData(data: [DoublePoint]) {
    let chartDataValues = chartDataEntries(points: data)
    chartLine.values = chartDataValues
    chartView.data = LineChartData(dataSets: [chartLine])
    chartView.notifyDataSetChanged()
  }
  
  // MARK: - Dragging selected data point
  
  func updateSelectedPoint(x: Double, y: Double) {
    if let point = selectedPoint {
      point.x = x
      point.y = max(0,y)
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
    let newEntry = ChartDataEntry(x: x, y: max(0,y))
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
  
  func okTapped() {
    let data = chartDataEntriesToDoubles(points: chartLine.values)
    delegate?.pillCurveUpdated(pill: pill!, profileData: data)
  }
  
  func cancelTapped() {
    delegate?.pillCurveCancelled()
  }
  
  // MARK: Load pill
  
  func showPill(pillView: PillView) {
    self.pill = pillView.pill
    chartLine.setColor(pillView.color)
    chartLine.setCircleColor(pillView.color)
    initData(data: pillView.pill.profileData)
  }
  
}
