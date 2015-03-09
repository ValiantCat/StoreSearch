//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by nero on 15/3/9.
//  Copyright (c) 2015年 Razeware. All rights reserved.
//

import UIKit
//detail 展示控制器  ios8支持
class DimmingPresentationController: UIPresentationController {
//    显示上一个控制器
    override func shouldRemovePresentersView() -> Bool {
         return false
    }
    
     lazy var dimmingView = GradientView(frame: CGRect.zeroRect)
//    viewController显示  将 gradientView塞进下面 
    override func presentationTransitionWillBegin() {
         dimmingView.frame = self.containerView.bounds
        self.containerView.insertSubview(dimmingView, atIndex: 0)
        
        
        dimmingView.alpha = 0
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ _ in
                self.dimmingView.alpha = 1
                }, completion: nil)
        }

    }
//    viewContrller 移除
    override func dismissalTransitionWillBegin()  {
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ _ in
                self.dimmingView.alpha = 0
                }, completion: nil)
        }
    }
    
}
