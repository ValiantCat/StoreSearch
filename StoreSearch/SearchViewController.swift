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
  var searchResults = [SearchResult]()
  var hasSearched = false
  var isLoading = false
  var dataTask:NSURLSessionDataTask?
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
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
//    MARK:  获取url
  func urlWithSearchText(searchText: String, category: Int) -> NSURL {
    
    var entityName: String
    switch category {
    case 1: entityName = "musicTrack"
    case 2: entityName = "software"
    case 3: entityName = "ebook"
    default: entityName = ""
    }
    
    let escapedSearchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!

    let urlString = String(format: "http://itunes.apple.com/search?term=%@&limit=200&entity=%@",escapedSearchText, entityName)
    
    let url = NSURL(string: urlString)
    return url!
  }

  
  func parseJSON(data: NSData) -> [String: AnyObject]? {

      var error: NSError?
      if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as? [String: AnyObject] {
        return json
      } else if let error = error {
        println("JSON Error: \(error)")
      } else {
        println("Unknown JSON Error")
      }

    return nil
  }
  
  func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult] {
    var searchResults = [SearchResult]()

    if let array: AnyObject = dictionary["results"] {
      for resultDict in array as [AnyObject] {
        if let resultDict = resultDict as? [String: AnyObject] {

          var searchResult: SearchResult?
          
          if let wrapperType = resultDict["wrapperType"] as? NSString {
            switch wrapperType {
            case "track":
              searchResult = parseTrack(resultDict)
            case "audiobook":
              searchResult = parseAudioBook(resultDict)
            case "software":
              searchResult = parseSoftware(resultDict)
            default:
              break
            }
          } else if let kind = resultDict["kind"] as? NSString {
            if kind == "ebook" {
              searchResult = parseEBook(resultDict)
            }
          }
          
          if let result = searchResult {
            searchResults.append(result)
          }

        } else {
          println("Expected a dictionary")
        }
      }
    } else {
      println("Expected 'results' array")
    }

    return searchResults
  }

  func parseTrack(dictionary: [String: AnyObject]) -> SearchResult {
    let searchResult = SearchResult()
    
    searchResult.name = dictionary["trackName"] as NSString
    searchResult.artistName = dictionary["artistName"] as NSString
    searchResult.artworkURL60 = dictionary["artworkUrl60"] as NSString
    searchResult.artworkURL100 = dictionary["artworkUrl100"] as NSString
    searchResult.storeURL = dictionary["trackViewUrl"] as NSString
    searchResult.kind = dictionary["kind"] as NSString
    searchResult.currency = dictionary["currency"] as NSString
    
    if let price = dictionary["trackPrice"] as? NSNumber {
      searchResult.price = Double(price)
    }
    if let genre = dictionary["primaryGenreName"] as? NSString {
      searchResult.genre = genre
    }
    return searchResult
  }
  
  func parseAudioBook(dictionary: [String: AnyObject]) -> SearchResult {
    let searchResult = SearchResult()
    searchResult.name = dictionary["collectionName"] as NSString
    searchResult.artistName = dictionary["artistName"] as NSString
    searchResult.artworkURL60 = dictionary["artworkUrl60"] as NSString
    searchResult.artworkURL100 = dictionary["artworkUrl100"] as NSString
    searchResult.storeURL = dictionary["collectionViewUrl"] as NSString
    searchResult.kind = "audiobook"
    searchResult.currency = dictionary["currency"] as NSString
    
    if let price = dictionary["collectionPrice"] as? NSNumber {
      searchResult.price = Double(price)
    }
    if let genre = dictionary["primaryGenreName"] as? NSString {
      searchResult.genre = genre
    }
    return searchResult
  }
  
  func parseSoftware(dictionary: [String: AnyObject]) -> SearchResult {
    let searchResult = SearchResult()
    searchResult.name = dictionary["trackName"] as NSString
    searchResult.artistName = dictionary["artistName"] as NSString
    searchResult.artworkURL60 = dictionary["artworkUrl60"] as NSString
    searchResult.artworkURL100 = dictionary["artworkUrl100"] as NSString
    searchResult.storeURL = dictionary["trackViewUrl"] as NSString
    searchResult.kind = dictionary["kind"] as NSString
    searchResult.currency = dictionary["currency"] as NSString
    
    if let price = dictionary["price"] as? NSNumber {
      searchResult.price = Double(price)
    }
    if let genre = dictionary["primaryGenreName"] as? NSString {
      searchResult.genre = genre
    }
    return searchResult
  }
  
  func parseEBook(dictionary: [String: AnyObject]) -> SearchResult {
    let searchResult = SearchResult()
    searchResult.name = dictionary["trackName"] as NSString
    searchResult.artistName = dictionary["artistName"] as NSString
    searchResult.artworkURL60 = dictionary["artworkUrl60"] as NSString
    searchResult.artworkURL100 = dictionary["artworkUrl100"] as NSString
    searchResult.storeURL = dictionary["trackViewUrl"] as NSString
    searchResult.kind = dictionary["kind"] as NSString
    searchResult.currency = dictionary["currency"] as NSString
    
    if let price = dictionary["price"] as? NSNumber {
      searchResult.price = Double(price)
    }
    if let genres: AnyObject = dictionary["genres"] {
      searchResult.genre = ", ".join(genres as [String])
    }
    return searchResult
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
    func performSearch () {
        if !searchBar.text.isEmpty {
            searchBar.resignFirstResponder()
            //             取消旧的请求
            dataTask?.cancel()
            isLoading = true
            tableView.reloadData()
            hasSearched = true
            searchResults = [SearchResult]()
            let url = self.urlWithSearchText(searchBar.text,category: segementControl.selectedSegmentIndex)
            let session = NSURLSession.sharedSession()
            dataTask = session.dataTaskWithURL(url, completionHandler: { data, response, error in
                if let error = error  {
                    println("error \(error)")
                    
                } else if let httpResponse = response as? NSHTTPURLResponse{
                    if httpResponse.statusCode == 200 {
                        if let dictionary = self.parseJSON(data) {
                            self.searchResults = self.parseDictionary(dictionary)
                            self.searchResults.sort(<)
                            dispatch_async(dispatch_get_main_queue()) {
                                self.isLoading = false
                                self.tableView.reloadData()
                            }
                            return
                        }
                    }else {
                        
                        println("failer")
                        if error.code == -999 {return}
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.hasSearched = false
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showNetworkError()
                }
            })
            
            //        开启
            dataTask?.resume();
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
    if isLoading {
        return 1
    } else if !hasSearched {
      return 0
    } else if searchResults.count == 0 {
      return 1
    } else {
      return searchResults.count
    }
  }
  //MARK：- tableView DataSource
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if isLoading {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath:indexPath) as UITableViewCell
        let spinner = cell.viewWithTag(100) as UIActivityIndicatorView
        spinner.startAnimating()
        return cell
    }else if searchResults.count == 0 {
      return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as UITableViewCell
      
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as SearchResultCell
      
      let searchResult = searchResults[indexPath.row]
     cell.configureForSearchResult(searchResult)

    return cell
    }
  }
}
//MARK: - tableView Delegate
extension SearchViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if searchResults.count == 0 || isLoading{
      return nil
    } else {
      return indexPath
    }
  }
}
