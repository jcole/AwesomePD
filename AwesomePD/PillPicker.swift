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
  
  func setupPills() {
    pills = Pill.getAvailablePills()
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
      // Animate pill
      pill.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
      UIView.animate(withDuration: 0.2,
                     delay: 0.0,
                     usingSpringWithDamping: 0.2,
                     initialSpringVelocity: 6.0,
                     options: .allowUserInteraction,
                     animations: {
                      pill.transform = .identity
                      },
                     completion: { (finished) in
        self.delegate?.pillSelected(pill: pill)
      })
    }
  }
  
}
