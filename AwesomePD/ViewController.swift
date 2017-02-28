//
//  ViewController.swift
//  AwesomePD
//
//  Created by Jeff on 2/22/17.
//  Copyright © 2017 Team Awesome. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
  
  // Subviews
  let defineCurveView = DefineCurveView()
  let timelineView = TimelineView()
  
  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    setup()
  }

  // MARK: Setup subviews
  
  func setup() {
    // TimelineView
    timelineView.isHidden = true
    view.addSubview(timelineView)
    timelineView.snp.makeConstraints { (make) in
      make.edges.equalTo(self.view)
    }
    
    // DefineCurveView
    defineCurveView.isHidden = false
    view.addSubview(defineCurveView)
    defineCurveView.snp.makeConstraints { (make) in
      make.edges.equalTo(self.view)
    }
  }
  
}

