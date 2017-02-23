//
//  PillPicker.swift
//  AwesomePD
//
//  Created by Jeff on 2/23/17.
//  Copyright © 2017 Team Awesome. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

protocol PillPickerDelegate {
  func pillSelected(pill: Pill)
}

class PillPicker: UIView {

  var pills:[Pill] = []
  
  var delegate:PillPickerDelegate?
  
  // MARK: Init
  
  convenience init() {
    self.init(frame: CGRect.zero)
    setup()
  }
  
  func setup() {
    backgroundColor = UIColor.clear
    layer.borderColor = UIColor.black.cgColor
    layer.borderWidth = 2.0

    setupPills()
  }
  
  // MARK: Setup pills
  
  func getAvailablePills() -> [Pill] {
    let pills = [
      Pill(name: "blue pill", color: .cyan, profileData: Pill.randomData(magnitude: 8.0)),
      Pill(name: "red pill", color: .red, profileData: Pill.randomData(magnitude: 4.0)),
      Pill(name: "green pill", color: .green, profileData: Pill.randomData(magnitude: 2.0)),
      Pill(name: "purple pill", color: .purple, profileData: Pill.randomData(magnitude: 1.0)),
    ]
    
    return pills
  }
  
  func setupPills() {
    pills = getAvailablePills()
    var lastPill:Pill? = nil
    
    pills.forEach { (pill) in
      pill.isUserInteractionEnabled = true
      pill.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pillTapped(sender:))))
      addSubview(pill)
      
      pill.snp.makeConstraints({ (make) in
        make.width.equalTo(pill.frame.width)
        make.height.equalTo(pill.frame.height)
        make.centerX.equalTo(self)
        if let last = lastPill {
          make.top.equalTo(last.snp.bottom).offset(20.0)
        } else {
          make.top.equalTo(self).offset(20.0)
        }
      })
      
      lastPill = pill
    }
  }
  
  // MARK: Gestures
  
  func pillTapped(sender: UITapGestureRecognizer) {
    if let pill = sender.view as? Pill {
      self.delegate?.pillSelected(pill: pill)
    }
  }
  
}
