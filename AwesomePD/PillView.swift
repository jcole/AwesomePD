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

  // Subviews
  let nameLabel = UILabel()
  let timeLabel = UILabel()
  
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
    layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
    layer.borderWidth = 1.0
    layer.cornerRadius = 20.0
    
    nameLabel.text = pill.name
    nameLabel.textAlignment = .center
    addSubview(nameLabel)

    timeLabel.textAlignment = .center
    timeLabel.textColor = UIColor.darkGray
    addSubview(timeLabel)
    
    // Constraints
    nameLabel.snp.makeConstraints({ (make) in
      make.left.right.equalTo(self)
      make.height.equalTo(20.0)
      make.top.equalTo(self.snp.bottom).offset(5.0)
    })
    
    timeLabel.snp.makeConstraints { (make) in
      make.edges.equalTo(self)
    }
  }
  
  // MARK: Formatted start time
  
  func formattedStartTime() -> String {
    let hour = Int(pill.startTime)
    let hourString = String(format: "%02d", hour)
    let min = Int((pill.startTime - floor(pill.startTime)) * 60)
    let minString = String(format: "%02d", min)
    
    return "\(hourString):\(minString)"
  }
  
  // MARK: Clone
  
  func clone() -> PillView {
    return PillView(pill: pill.clone(), color: color)
  }
  
}
