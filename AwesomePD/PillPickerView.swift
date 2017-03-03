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
  func pillPickerPillViewShouldEdit(pillView: PillView)
  func pillPickerPillViewPanned(pillView: PillView, gesture: UIPanGestureRecognizer)
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
    let colors: [UIColor] = [
      UIColor(hex: 0xd7191c),
      UIColor(hex: 0xfdae61),
      UIColor(hex: 0xfee08b),
      UIColor(hex: 0xabdda4),
      UIColor(hex: 0x2b83ba)
    ]
    var colorIndex = 0
    
    pills.forEach { (pill) in
      let pillView = PillView(pill: pill, color: colors[colorIndex])
      pillViews.append(pillView)
      addSubview(pillView)

      colorIndex += 1
      if colorIndex >= colors.count {
        colorIndex = 1
      }
      
      pillView.isUserInteractionEnabled = true
      
      let doubleTap = UITapGestureRecognizer(target: self, action: #selector(pillViewDoubleTapped(gesture:)))
      doubleTap.numberOfTapsRequired = 2
      pillView.addGestureRecognizer(doubleTap)

      let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pillViewPanned(gesture:)))
      pillView.addGestureRecognizer(panGesture)
      
      pillView.snp.makeConstraints({ (make) in
        make.width.equalTo(pillView.frame.width)
        make.height.equalTo(pillView.frame.height)
        make.centerX.equalTo(self)
        if let last = lastPillView {
          make.top.equalTo(last.snp.bottom).offset(45.0)
        } else {
          make.top.equalTo(self).offset(20.0)
        }
      })
      
      lastPillView = pillView
    }
    
    backgroundColor = UIColor.clear
    layer.borderColor = UIColor.lightGray.cgColor
    layer.borderWidth = 2.0
    layer.cornerRadius = 5.0
  }
  
  // MARK: Gestures
  
  func pillViewDoubleTapped(gesture: UITapGestureRecognizer) {
    if let pillView = gesture.view as? PillView {
      delegate?.pillPickerPillViewShouldEdit(pillView: pillView)
    }
  }
  
  func pillViewPanned(gesture: UIPanGestureRecognizer) {
    if let pillView = gesture.view as? PillView {
      delegate?.pillPickerPillViewPanned(pillView: pillView, gesture: gesture)
    }
  }
  
  // MARK: When selected
  
  func hidePillView(pillView: PillView) {
    pillView.isHidden = true
  }

  func showPillView(pillView: PillView) {
    pillView.isHidden = false
  }
  
}
