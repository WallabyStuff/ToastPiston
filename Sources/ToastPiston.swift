import UIKit

extension UIViewController {
  
  private enum Constant {
    static let toastDuration: CGFloat = 2
    static let toastPresentationDuration: CGFloat = 0.5
    
    static let contentHeight: CGFloat = 44
    static let contentHorizontalPadding: CGFloat = 16
    
    static let toastCornerRadius: CGFloat = 24
  }
  
  private struct AssociatedKeys {
    static var currentToastView: UIVisualEffectView?
    static var isUserPanning: Bool = false
    static var panGestureStartTime: Date?
  }
  
  private var currentToastView: UIVisualEffectView? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.currentToastView) as? UIVisualEffectView
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.currentToastView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  private var isUserPanning: Bool {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.isUserPanning) as? Bool ?? false
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.isUserPanning, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  private var panGestureStartTime: Date? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.panGestureStartTime) as? Date
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.panGestureStartTime, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  public func showPistonToast(title: String,
                              titleColor: UIColor = .white,
                              font: UIFont = .systemFont(ofSize: 15, weight: .semibold),
                              blurStyle: UIBlurEffect.Style = .dark) {
    // If a toast is already displayed, remove it before displaying the new one
    if let existingToast = currentToastView {
      UIView.animate(withDuration: Constant.toastPresentationDuration, animations: {
        existingToast.transform = CGAffineTransform(translationX: 0, y: -existingToast.bounds.height)
      }, completion: { _ in
        existingToast.removeFromSuperview()
      })
    }
    
    // Create the visual effect view with blur effect
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    visualEffectView.translatesAutoresizingMaskIntoConstraints = false
    visualEffectView.clipsToBounds = true
    currentToastView = visualEffectView
    
    // Create the label
    let titleLabel = UILabel()
    titleLabel.text = title
    titleLabel.textColor = titleColor
    titleLabel.font = font
    titleLabel.textAlignment = .center
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    
    // Add the visual effect view and the label to the view
    self.view.addSubview(visualEffectView)
    visualEffectView.contentView.addSubview(titleLabel)
    
    // Get the safe area insets
    let safeAreaInsets = self.view.safeAreaInsets
    let totalHeight = Constant.contentHeight + safeAreaInsets.top
    
    // Set up the constraints
    NSLayoutConstraint.activate([
      visualEffectView.topAnchor.constraint(equalTo: self.view.topAnchor),
      visualEffectView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      visualEffectView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      visualEffectView.heightAnchor.constraint(equalToConstant: totalHeight),
      titleLabel.topAnchor.constraint(equalTo: visualEffectView.topAnchor, constant: safeAreaInsets.top),
      titleLabel.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor, constant: Constant.contentHorizontalPadding),
      titleLabel.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor, constant: -Constant.contentHorizontalPadding),
      titleLabel.heightAnchor.constraint(equalToConstant: Constant.contentHeight)
    ])
    
    // Add pan gesture recognizer to the toast view
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleToastPanGesture(_:)))
    visualEffectView.addGestureRecognizer(panGestureRecognizer)
    
    // Animate the visual effect view from top to bottom
    visualEffectView.transform = CGAffineTransform(translationX: 0, y: -totalHeight)
    UIView.springAnimate(withDuration: Constant.toastPresentationDuration) {
      visualEffectView.transform = .identity
    } completion: {
      DispatchQueue.main.asyncAfter(deadline: .now() + Constant.toastDuration, execute: {
        // Only dismiss the toast automatically if the user is not panning
        guard !self.isUserPanning else {
          return
        }
        UIView.springAnimate(withDuration: Constant.toastPresentationDuration) {
          visualEffectView.transform = CGAffineTransform(translationX: 0, y: -totalHeight)
        } completion: {
          visualEffectView.removeFromSuperview()
          // Remove the reference to the toast view when it's removed from the superview
          if self.currentToastView == visualEffectView {
            self.currentToastView = nil
          }
        }
      })
    }
  }
  
  @objc
  private func handleToastPanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
    guard let toastView = currentToastView else {
      return
    }
    
    let translation = gestureRecognizer.translation(in: view)
    
    switch gestureRecognizer.state {
    case .began:
      // Store the start time of the pan gesture
      panGestureStartTime = Date()
    case .changed:
      // Move the toast view as the user pans
      if toastView.frame.minY > 0 {
        toastView.transform = CGAffineTransform(translationX: 0, y: max(translation.y * 0.1, -toastView.bounds.height))
      } else {
        toastView.transform = CGAffineTransform(translationX: 0, y: max(translation.y, -toastView.bounds.height))
      }
      
      // Adjust corner radius if the user starts panning
      let threshold: CGFloat = 24
      let multiplier = min(max(toastView.frame.minY / threshold, 0), 1)
      toastView.layer.cornerRadius = Constant.toastCornerRadius * multiplier
      
      // Indicate that the user is panning
      isUserPanning = true
      
      // Cancel the automatic dismiss if the user starts panning
      toastView.layer.removeAllAnimations()
    case .ended, .cancelled:
      let velocity = gestureRecognizer.velocity(in: view)
      
      // Indicate that the user has stopped panning
      isUserPanning = false
      
      // If the user panned upwards with a sufficient velocity, or panned more than half of the toast view's height upwards, then dismiss the toast
      if velocity.y < -500 || translation.y < -toastView.bounds.height / 2 || panGestureExceedsPresentationDuration() {
        UIView.springAnimate(withDuration: Constant.toastPresentationDuration) {
          toastView.transform = CGAffineTransform(translationX: 0, y: -toastView.bounds.height)
          toastView.layer.cornerRadius = .zero
        } completion: {
          toastView.removeFromSuperview()
          // Remove the reference to the toast view when it's removed from the superview
          if self.currentToastView == toastView {
            self.currentToastView = nil
          }
        }
      } else {
        // Otherwise, bring the toast back to its original position
        UIView.springAnimate(withDuration: Constant.toastPresentationDuration) {
          toastView.transform = .identity
          toastView.layer.cornerRadius = .zero
        }
      }
    default:
      break
    }
  }
  
  private func panGestureExceedsPresentationDuration() -> Bool {
    if let startTime = panGestureStartTime {
      return Date().timeIntervalSince(startTime) > TimeInterval(Constant.toastPresentationDuration)
    }
    return false
  }
}
