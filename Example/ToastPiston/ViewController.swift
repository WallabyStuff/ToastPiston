//
//  ViewController.swift
//  ToastPiston
//
//  Created by WallabyStuff on 07/30/2023.
//  Copyright (c) 2023 WallabyStuff. All rights reserved.
//

import UIKit
import ToastPiston

class ViewController: UIViewController {
  
  // MARK: - UI
  
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var button: UIButton!
  
  
  // MARK: - Methods
  
  @IBAction func didTapShowButton(_ sender: Any) {
    showPistonToast(title: textField.text ?? "")
  }
}

