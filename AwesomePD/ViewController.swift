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

class ViewController: UIViewController {
  
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
    timelineView.isHidden = false
    view.addSubview(timelineView)
    timelineView.snp.makeConstraints { (make) in
      make.edges.equalTo(self.view)
    }
    
    // DefineCurveView
    defineCurveView.isHidden = true
    view.addSubview(defineCurveView)
    defineCurveView.snp.makeConstraints { (make) in
      make.edges.equalTo(self.view)
    }
  }
  
  // MARK: Setup pill data
  
  func initData() {
    pills = [
      Pill(name: "Levodopa", profileData: Pill.initData()),
      Pill(name: "Sinemet", profileData: Pill.randomData(magnitude: 4.0)),
      Pill(name: "Wacky pill", profileData: Pill.randomData(magnitude: 2.0))
    ]
  }
  
}

