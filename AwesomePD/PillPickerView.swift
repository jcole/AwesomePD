//
//  PillPickerView.swift
//  AwesomePD
//
//  Created by Jeff on 2/23/17.
//  Copyright © 2017 Team Awesome. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

protocol PillPickerViewDelegate {
  func pillSelected(pillView: PillView)
}

class PillPickerView: UIView {

  // Data
  var pillViews:[PillView] = []
  var delegate:PillPickerViewDelegate?
  
  // MARK: Init
  
  init(pills: [Pill]) {
    super.init(frame: CGRect.zero)
    
    setup(pills: pills)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Setup pills

  func setup(pills: [Pill]) {
    var lastPillView: PillView? = nil
    let colors: [UIColor] = [.cyan, .red, .green, .purple]
    var colorIndex = 0
    
    pills.forEach { (pill) in
      let pillView = PillView(pill: pill, color: colors[colorIndex])
      colorIndex += 1
      if colorIndex >= colors.count {
        colorIndex = 1
      }
      
      pillView.isUserInteractionEnabled = true
      pillView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pillViewTapped(sender:))))
      addSubview(pillView)
      
      pillView.snp.makeConstraints({ (make) in
        make.width.equalTo(pillView.frame.width)
        make.height.equalTo(pillView.frame.height)
        make.centerX.equalTo(self)
        if let last = lastPillView {
          make.top.equalTo(last.snp.bottom).offset(20.0)
        } else {
          make.top.equalTo(self).offset(20.0)
        }
      })
      
      lastPillView = pillView
    }
    
    backgroundColor = UIColor.clear
    layer.borderColor = UIColor.black.cgColor
    layer.borderWidth = 2.0
  }
  
  // MARK: Gestures
  
  func pillViewTapped(sender: UITapGestureRecognizer) {
    if let pillView = sender.view as? PillView {
      // Animate pill
      pillView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
      UIView.animate(withDuration: 0.2,
                     delay: 0.0,
                     usingSpringWithDamping: 0.2,
                     initialSpringVelocity: 6.0,
                     options: .allowUserInteraction,
                     animations: {
                      pillView.transform = .identity
                      },
                     completion: { (finished) in
        self.delegate?.pillSelected(pillView: pillView)
      })
    }
  }
  
}
