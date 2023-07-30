import UIKit

extension UIViewController {
  
  private enum Constant {
    static let toastDuration: CGFloat = 2
    static let toastPresentationDuration: CGFloat = 0.5
    
    static let contentHeight: CGFloat = 44
    static let contentHorizontalPadding: CGFloat = 16
  }
  
  private struct AssociatedKeys {
    static var currentToastView: UIVisualEffectView?
  }
  
  private var currentToastView: UIVisualEffectView? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.currentToastView) as? UIVisualEffectView
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.currentToastView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
    
    // Animate the visual effect view from top to bottom
    visualEffectView.transform = CGAffineTransform(translationX: 0, y: -totalHeight)
    UIView.animate(withDuration: Constant.toastPresentationDuration,
                   delay: 0.0,
                   usingSpringWithDamping: 0.9,
                   initialSpringVelocity: 0.9,
                   options: .curveEaseInOut, animations: {
      visualEffectView.transform = .identity
    }, completion: { _ in
      DispatchQueue.main.asyncAfter(deadline: .now() + Constant.toastDuration, execute: {
        UIView.animate(withDuration: Constant.toastPresentationDuration, animations: {
          visualEffectView.transform = CGAffineTransform(translationX: 0, y: -totalHeight)
        }, completion: { _ in
          visualEffectView.removeFromSuperview()
          // Remove the reference to the toast view when it's removed from the superview
          if self.currentToastView == visualEffectView {
            self.currentToastView = nil
          }
        })
      })
    })
  }
}
