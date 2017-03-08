//
//  LevelSelectView.swift
//  AwesomePD
//
//  Created by Jeff on 3/8/17.
//  Copyright © 2017 Team Awesome. All rights reserved.
//

import Foundation
import UIKit

enum DifficultyLevel {
  case Easy
  case Medium
  case Hard
}

protocol LevelSelectViewDelegate {
  func modeSelected(mode: DifficultyLevel)
}

class LevelSelectView: UIView {
  
  // Views
  var easyButton = UILabel()
  var mediumButton = UILabel()
  var hardButton = UILabel()
  
  // Data
  var mode: DifficultyLevel?
  var delegate: LevelSelectViewDelegate?
  
  // MARK: Init
  
  convenience init() {
    self.init(frame: CGRect.zero)
    setup()
  }
  
  func setup() {
    easyButton.text = "Easy"
    addButton(label: easyButton, below: nil)

    mediumButton.text = "Medium"
    addButton(label: mediumButton, below: easyButton)
    
    hardButton.text = "Hard"
    addButton(label: hardButton, below: mediumButton)
  }
  
  private func addButton(label: UILabel, below: UILabel?) {
    addSubview(label)
    label.isUserInteractionEnabled = true
    label.textColor = UIColor.darkGray
    label.layer.borderColor = UIColor.lightGray.cgColor
    label.layer.borderWidth = 2.0
    label.layer.cornerRadius = 5.0
    label.textAlignment = .center
    
    label.snp.makeConstraints { (make) in
      make.left.right.equalTo(self)
      make.height.equalTo(40.0)
      if let labelAbove = below {
        make.top.equalTo(labelAbove.snp.bottom).offset(10.0)
      } else {
        make.top.equalTo(self)
      }
    }
    
    label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(levelButtonTapped(gesture:))))
  }
  
  // MARK: Gestures
  
  func levelButtonTapped(gesture: UITapGestureRecognizer) {
    if let buttonView = gesture.view as? UILabel {
      let selectedMode = modeForButton(button: buttonView)
      setMode(mode: selectedMode)
      delegate?.modeSelected(mode: selectedMode)
    }
  }
  
  // MARK: Modes
  
  func setMode(mode: DifficultyLevel?) {
    self.mode = mode
    [easyButton, mediumButton, hardButton].forEach { (button) in
      button.backgroundColor = UIColor.white
    }
    if let button = buttonForMode(mode: mode) {
      button.backgroundColor = UIColor.yellow
    }
  }
  
  // MARK: Mapping
  
  func modeForButton(button: UILabel) -> DifficultyLevel {
    var selectedMode: DifficultyLevel!
    if button == easyButton {
      selectedMode = .Easy
    } else if button == mediumButton {
      selectedMode = .Medium
    } else if button == hardButton {
      selectedMode = .Hard
    }
    return selectedMode
  }
  
  func buttonForMode(mode: DifficultyLevel?) -> UILabel? {
    var buttonSelected: UILabel?
    if let selectedMode = mode {
      switch selectedMode {
      case .Easy:
        buttonSelected = easyButton
      case .Medium:
        buttonSelected = mediumButton
      case .Hard:
        buttonSelected = hardButton
      }
    }
    return buttonSelected
  }
  
}
