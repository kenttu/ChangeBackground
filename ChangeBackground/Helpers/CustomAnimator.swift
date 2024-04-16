//
//  CustomAnimator.swift
//  ChangeBackground
//
//  Created by Kent Tu on 4/15/24.
//

import UIKit

import UIKit

class CustomAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var sourceView: UIView?
    var destinationView: UIView?
    var isPresenting = true

    init(sourceView: UIView, destinationView: UIView) {
        self.sourceView = sourceView
        self.destinationView = destinationView
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let sourceView = sourceView,
              let destinationView = destinationView,
              let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView
        let fromView = fromVC.view!
        let toView = toVC.view!
        containerView.addSubview(toView)

        let sourceViewToAnimate = isPresenting ? sourceView : destinationView
        let destinationViewToAnimate = isPresenting ? destinationView : sourceView
        let animatedView = sourceView.snapshotView(afterScreenUpdates: true)!
        animatedView.frame = containerView.convert(sourceViewToAnimate.frame, from: sourceViewToAnimate.superview)
        containerView.addSubview(animatedView)
        destinationViewToAnimate.isHidden = true
        
        toView.alpha = 0
    
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            animatedView.frame = containerView.convert(destinationViewToAnimate.frame, from: destinationViewToAnimate.superview)
            toView.alpha = 1
        }, completion: { finished in
            animatedView.removeFromSuperview()
            destinationViewToAnimate.isHidden = false
            transitionContext.completeTransition(finished)
        })
    }
}

class TransitionManager: NSObject, UIViewControllerTransitioningDelegate {
    var animator: CustomAnimator?

    func setupTransition(from sourceVC: MainViewController, to destinationVC: EditViewController, usingSourceView sourceView: UIView, andDestinationView destinationView: UIView) {
        animator = CustomAnimator(sourceView: sourceView, destinationView: destinationView)
        destinationVC.modalPresentationStyle = .fullScreen
        destinationVC.transitioningDelegate = self
        sourceVC.present(destinationVC, animated: true, completion: nil)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator?.isPresenting = true
        return animator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator?.isPresenting = false
        return animator
    }
        
    deinit {
        print("animater deallocated")
    }
}
