//
//  ViewController.swift
//  StoreSearch
//
//  Created by M.I. Hollemans on 01/10/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var segementControl: UISegmentedControl!
//  var searchResults = [SearchResult]()
//  var hasSearched = false
//  var isLoading = false
//  var dataTask:NSURLSessionDataTask?

  let search = Search()
  var landscapeViewController:LandscapeViewController?
  struct TableViewCellIdentifiers {
    static let searchResultCell = "SearchResultCell"
    static let nothingFoundCell = "NothingFoundCell"
    static let loadingCell = "LoadingCell"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
            //        tableVuew往下走108
    tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
    tableView.rowHeight = 80
    //        注册tableView cell
    var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)

    cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
    cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
    searchBar.becomeFirstResponder()
    
    tableView.tableFooterView = UIView(frame: CGRect.zeroRect)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

 
//    MARK: - 网络错误
  func showNetworkError() {
    let alert = UIAlertController(
      title: "Whoops...",
      message: "There was an error reading from the iTunes Store. Please try again.",
      preferredStyle: .Alert)
    
    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alert.addAction(action)
    
    presentViewController(alert, animated: true, completion: nil)
  }
    
    
//    选项卡发生改变
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        
        self.performSearch();
        
    }
    /**
    开始查找
    */
    func performSearch() {
        if let category = Search.Category(rawValue: self.segementControl.selectedSegmentIndex) {
            search.performSearchForText(searchBar.text, category: category, completion: {
                success in
                
                if let controller = self.landscapeViewController {
                    controller.searchResultsReceived()
                }
                
                if !success {
                    self.showNetworkError()
                }
                
                self.tableView.reloadData()
            })
            
            tableView.reloadData()
            searchBar.resignFirstResponder()
        }
    }

}
// MARK:  - searchBar delegate
extension SearchViewController: UISearchBarDelegate {
    //    MARK: 点击搜索
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.performSearch()
    }
    
    
        //    MARK searchBar 的状态栏上移
  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    return .TopAttached
  }
}

extension SearchViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch search.state {
    case .NotSearchedYet:
        return 0
    case .Loading:
        return 1
    case .NoResults:
        return 1
    case .Results(let list):
        return list.count
    }
  }
  //MARK：- tableView DataSource
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch search.state {
    case .NotSearchedYet:
        fatalError("Should never get here")
        
    case .Loading:
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath:indexPath) as UITableViewCell
        
        let spinner = cell.viewWithTag(100) as UIActivityIndicatorView
        spinner.startAnimating()
        
        return cell
        
    case .NoResults:
        return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as UITableViewCell
        
    case .Results(let list):
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as SearchResultCell
        
        let searchResult = list[indexPath.row]
        cell.configureForSearchResult(searchResult)
        
        return cell
    }
  }
}
//MARK: - tableView Delegate
extension SearchViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    performSegueWithIdentifier("ShowDetail", sender: indexPath)
  }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            switch search.state {
            case .Results(let list):
                let detailViewController = segue.destinationViewController as DetailViewController
                let indexPath = sender as NSIndexPath
                let searchResult = list[indexPath.row]
                detailViewController.searchResult = searchResult
            default:
                break
            }
        
        }
    }
  
  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    switch search.state {
    case .NotSearchedYet, .Loading, .NoResults:
        return nil
    case .Results:
        return indexPath
    }
  }
}
//MARK ： - 横屏时操作  ios8新特性
extension SearchViewController {
  
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        switch newCollection.verticalSizeClass {
        case .Compact:  //是横屏的
            showLandscapeViewWithCoordinator(coordinator)
        case .Regular, .Unspecified: //竖屏
            hideLandscapeViewWithCoordinator(coordinator)
        }
        
    }
    
    func  showLandscapeViewWithCoordinator(coordinator: UIViewControllerTransitionCoordinator) {
        precondition(landscapeViewController == nil)
        landscapeViewController = storyboard!.instantiateViewControllerWithIdentifier("LandscapeViewController") as? LandscapeViewController
        if let controller = landscapeViewController {
//           赋值  传递数据

            controller.search = self.search
            controller.view.frame = self.view.bounds
            controller.view.alpha = 0
            self.view.addSubview(controller.view)
            self.addChildViewController(controller)
            coordinator.animateAlongsideTransition({ (_ ) -> Void in
                controller.view.alpha = 1
                self.view.endEditing(true)
                if self.presentedViewController != nil {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            
            }, completion: { (_) -> Void in
                
                //            控制器添加到上面 而不是销毁下面的
                controller.didMoveToParentViewController(self)
            })
            
            

        
        }
    
    }
    func hideLandscapeViewWithCoordinator(
        coordinator: UIViewControllerTransitionCoordinator) {
            if let controller = landscapeViewController {
                controller.willMoveToParentViewController(nil)
                
                coordinator.animateAlongsideTransition({ _ in
                    controller.view.alpha = 0
                    
                    if self.presentedViewController != nil {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    }, completion: { _ in
                        controller.view.removeFromSuperview()
                        controller.removeFromParentViewController()
                        self.landscapeViewController = nil
                })
            }
        
    }
//    这是ios8之前处理方法
//    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
    
//    }
}