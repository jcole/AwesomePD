//
//  PillView.swift
//  AwesomePD
//
//  Created by Jeff on 2/28/17.
//  Copyright © 2017 Team Awesome. All rights reserved.
//

import Foundation
import UIKit

class PillView: UIView {
  
  // Data
  var color: UIColor!
  var pill: Pill!
  
  // Constants
  let pillWidth:CGFloat = 100.0
  let pillHeight:CGFloat = 40.0

  // MARK: Init
  
  init(pill: Pill, color: UIColor) {
    self.pill = pill
    self.color = color
    
    super.init(frame: CGRect(x: 0, y: 0, width: pillWidth, height: pillHeight))
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setup() {
    backgroundColor = color
    layer.borderColor = UIColor.lightGray.cgColor
    layer.borderWidth = 1.0
    layer.cornerRadius = 20.0
  }
  
  // MARK: Clone
  
  func clone() -> PillView {
    return PillView(pill: pill.clone(), color: color)
  }
  
}
