//
//  MoviesViewController.swift
//  MovieApp
//
//  Created by Macintosh on 7/5/16.
//  Copyright © 2016 Ken Production. All rights reserved.
//

import UIKit
import AFNetworking
import EZLoadingActivity

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    var movies: [NSDictionary]?
    
    var filtered: [NSDictionary]?
    
    var baseURL = "https://image.tmdb.org/t/p/w342"
    var endPoint = String()
    var searchActive = false
    
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var warningImage: UIImageView!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var movieSearchBar: UISearchBar!
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
//        searchActive = true;
        movieSearchBar.showsCancelButton = true
        print("text begin")
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
        movieSearchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        movieSearchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        movieSearchBar.endEditing(true)
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filtered = movies?.filter({ (text) -> Bool in
            let tmpTitle = text["title"] as! String
            let tmpOverview = text["overview"] as! String

            let range1 = tmpTitle.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            let range2 = tmpOverview.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            
            //Return true if either match
            return range1 != nil || range2 != nil
            
        })
        if(filtered?.count == 0){
            searchActive = false;
            print("empty?")
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }

    
    func fetchMovies() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endPoint)?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            self.tableView.reloadData()
                            self.refreshControl.endRefreshing()
                            
                    }
                }
                else {
                    EZLoadingActivity.hide()
                    self.errorView.hidden = false
                    self.tableView.hidden = true
                    
                }
        })
        task.resume()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        //print("action!!!")
        //refreshControl.beginRefreshing()
        fetchMovies()
    }
    
    @IBAction func retryServer(sender: UIButton) {
        self.viewDidLoad()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //refreshControl.addTarget(self, action:, #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
//        refreshControl.addTarget(self, action: Selector(refreshControlAction(_,:)), forControlEvents: UIControlEvents.ValueChanged)
        
        tableView.dataSource = self
        tableView.delegate = self
        movieSearchBar.delegate = self
        
        movieSearchBar.showsCancelButton = true
        
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        
        // Do any additional setup after loading the view.
        //self.errorView.hidden = true
        retryButton.backgroundColor = UIColor.clearColor()
        retryButton.layer.cornerRadius = 5
        retryButton.layer.borderWidth = 1
        retryButton.layer.borderColor = UIColor.blackColor().CGColor
        
        self.errorView.hidden = true
        tableView.hidden = false
        self.errorLabel.text = "Network Error"
        warningImage.image = UIImage(named: "warning.png")
        EZLoadingActivity.show("Loading...", disableUI: true)
        fetchMovies()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered?.count ?? 0
        }
        
        return movies?.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        if (searchActive){
            
            let movie = filtered![indexPath.row] as! NSDictionary
            let title = movie["title"] as! String
            let overview = movie["overview"] as! String
            let posterpath = movie["poster_path"] as! String
            let imageURL = NSURL(string: baseURL + posterpath)
            
            cell.titleLabel.text = title
            cell.overviewLabel.text = overview
            cell.posterView.setImageWithURL(imageURL!)
            
            
        }
        else
        {

            let movie = movies![indexPath.row] as! NSDictionary
            let title = movie["title"] as! String
            let overview = movie["overview"] as! String
            let posterpath = movie["poster_path"] as! String
            let imageURL = NSURL(string: baseURL + posterpath)
        
            cell.titleLabel.text = title
            cell.overviewLabel.text = overview
            cell.posterView.setImageWithURL(imageURL!)
        }
        
        EZLoadingActivity.hide()

        return cell
        
    }
    
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        let movieDetailView = segue.destinationViewController as! MovieDetailsViewController
        
        movieDetailView.movie = movie
     
    }

}
