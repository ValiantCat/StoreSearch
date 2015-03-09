//
//  BounceAnimationController.swift
//  StoreSearch
//
//  Created by nero on 15/3/9.
//  Copyright (c) 2015年 Razeware. All rights reserved.
//   动画类

import UIKit

class BounceAnimationController: NSObject ,UIViewControllerAnimatedTransitioning {
//    动画持续时间
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.4
    }
// 动画具体实现
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) {
            if let toView = transitionContext.viewForKey(UITransitionContextToViewKey) {
                toView.frame = transitionContext.finalFrameForViewController(toViewController)
                
                let containerView = transitionContext.containerView()
                containerView.addSubview(toView)
                
                toView.transform = CGAffineTransformMakeScale(0.7, 0.7)
                
                UIView.animateKeyframesWithDuration(transitionDuration(transitionContext), delay: 0.0, options: .CalculationModeCubic, animations: {
                    UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.334, animations: {
                        toView.transform = CGAffineTransformMakeScale(1.2, 1.2)
                    })
                    UIView.addKeyframeWithRelativeStartTime(0.334, relativeDuration: 0.333, animations: {
                        toView.transform = CGAffineTransformMakeScale(0.9, 0.9)
                    })
                    UIView.addKeyframeWithRelativeStartTime(0.666, relativeDuration: 0.333, animations: {
                        toView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                    })
                    }, completion: { finished in
                        transitionContext.completeTransition(finished)
                })
            }
        }
    }

    
    
}
