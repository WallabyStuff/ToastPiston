//
//  File.swift
//  
//
//  Created by 이승기 on 2023/08/05.
//

import UIKit

extension UIView {
  static func springAnimate(withDuration: CGFloat,
                            animations: @escaping () -> Void,
                            completion: (() -> Void)? = nil) {
    animate(withDuration: withDuration,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.9) {
      animations()
    } completion: { _ in
      completion?()
    }
  }
}
