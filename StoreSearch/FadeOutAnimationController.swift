//
//  FadeOutAnimationController.swift
//  StoreSearch
//
//  Created by nero on 15/3/10.
//  Copyright (c) 2015年 Razeware. All rights reserved.
//

import UIKit

class FadeOutAnimationController: NSObject , UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.4
    }
    //    关闭时候的动画
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey) {
            let duration = transitionDuration(transitionContext)
            
            UIView.animateWithDuration(duration, animations: {
                fromView.alpha = 0
                }, completion: { finished in
                    transitionContext.completeTransition(true)
            })
        }
    }
}
