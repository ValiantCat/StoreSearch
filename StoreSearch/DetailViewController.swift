//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by nero on 15/3/9.
//  Copyright (c) 2015年 Razeware. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!

    enum AnimationStyle {  //动画类型
        case Slide
        case Fade
    }
    var dismissAnimationStyle = AnimationStyle.Fade
    
    var searchResult:SearchResult!
    var downloadTask:NSURLSessionDownloadTask?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clearColor()
        self.view.tintColor =  UIColor(red: 20/255, green: 160/255, blue: 160/255,
            alpha: 1)
        self.popupView.layer.cornerRadius = 10.0;
        let tap = UITapGestureRecognizer(target: self, action: Selector("close"))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
        if searchResult != nil {
            self.updateUI()
        }
        if let url = NSURL(string: searchResult.artworkURL100){
            downloadTask = artworkImageView.loadImageWithURL(url)
        }
    }
    deinit {
     downloadTask?.cancel()
    }
    /**
    更新ui
    */
    func updateUI(){
    nameLabel.text = searchResult.name
        if searchResult.artistName.isEmpty {
                artistNameLabel.text = "Un Know"
        }else {
            artistNameLabel.text = searchResult.artistName
        }
        kindLabel.text = searchResult.kindForDisplay()
        genreLabel.text = searchResult.genre
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.currencyCode = searchResult.currency
        
        var priceText: String
        if searchResult.price == 0 {
            priceText = "Free"
        } else if let text = formatter.stringFromNumber(searchResult.price) {
            priceText = text
        } else {
            priceText = ""
        }
        
        priceButton.setTitle(priceText, forState: .Normal)
    }
    
    @IBAction func close(){
            dismissAnimationStyle  = .Slide
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func openInAppStore(){
        if  let url = NSURL(string: searchResult.storeURL) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        设置modal 代理
        self.modalPresentationStyle = .Custom;
        self.transitioningDelegate = self
    }
}
extension DetailViewController :UIGestureRecognizerDelegate {
            func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
                    return touch.view === self.view
            }


}
// 展示效果
extension DetailViewController :UIViewControllerTransitioningDelegate {
//    设置展示控制来自哪个控制器   DimmingPresentationController
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController( presentedViewController: presented,
            presentingViewController: presenting)
    }
//   开始展示动画的动画控制器
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
    //   开始关闭动画的动画控制器
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

            
        switch dismissAnimationStyle {
        case .Slide:
            return SlideOutAnimationController()
        case .Fade:
            return FadeOutAnimationController()
        }
    }

}
