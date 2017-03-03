//
//  ViewController.swift
//  AwesomePD
//
//  Created by Jeff on 2/22/17.
//  Copyright © 2017 Team Awesome. All rights reserved.
//

import UIKit
import SnapKit

// Global constants
let chartYAxisMin: Double = 0.0
let chartYAxisMax: Double = 10.0
let chartMinTime: Double = 0.0
let chartMaxTime: Double = 24.0

class ViewController: UIViewController, TimelineViewProtocol, DefineCurveViewDelegate {
  
  // Subviews
  let defineCurveView = DefineCurveView()
  var timelineView: TimelineView!
  
  // Data
  var pills: [Pill] = []
  
  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    initData()
    setup()
  }

  // MARK: Setup subviews
  
  func setup() {
    // TimelineView
    timelineView = TimelineView(availablePills: pills)
    timelineView.delegate = self
    view.addSubview(timelineView)
    timelineView.snp.makeConstraints { (make) in
      make.edges.equalTo(self.view)
    }
    
    // DefineCurveView
    defineCurveView.delegate = self
    view.addSubview(defineCurveView)
    
    defineCurveView.isHidden = true
    defineCurveView.snp.makeConstraints { (make) in
      make.edges.equalTo(self.view)
    }
  }
  
  func hideDefineCurve() {
    defineCurveView.snp.remakeConstraints { (make) in
      make.height.width.equalTo(self.view)
      make.top.equalTo(self.view.snp.bottom)
      make.left.equalTo(0)
    }
    UIView.animate(withDuration: 0.3, animations: { 
      self.view.layoutIfNeeded()
    }) { (completed) in
      self.defineCurveView.isHidden = true
    }
  }
  
  func showDefineCurve() {
    // Place off-screen
    defineCurveView.snp.remakeConstraints { (make) in
      make.height.width.equalTo(self.view)
      make.top.equalTo(self.view.snp.bottom)
      make.left.equalTo(0)
    }
    self.view.layoutIfNeeded()
    
    // Animate up
    defineCurveView.isHidden = false
    defineCurveView.snp.remakeConstraints { (make) in
      make.edges.equalTo(self.view)
    }
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
  
  // MARK: Setup pill data
  
  func initData() {
    pills = [
      Pill(name: "Levodopa", profileData: Pill.initData()),
      Pill(name: "Sinemet", profileData: Pill.initData()),
      Pill(name: "Wacky pill", profileData: Pill.initData())
    ]
  }
  
  // MARK: TimelineViewProtocol
  
  func pillShouldEdit(pillView: PillView) {
    defineCurveView.showPill(pillView: pillView)
    showDefineCurve()
  }
  
  // MARK: DefineCurveViewDelegate
  
  func pillCurveCancelled() {
    hideDefineCurve()
  }
  
  func pillCurveUpdated(pill: Pill, profileData: [DoublePoint]) {
    timelineView.refreshPillData(pill: pill, profileData: profileData)
    hideDefineCurve()
  }
  
}

