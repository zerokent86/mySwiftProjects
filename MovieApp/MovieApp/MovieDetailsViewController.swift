//
//  MovieDetailsViewController.swift
//  MovieApp
//
//  Created by Macintosh on 7/9/16.
//  Copyright © 2016 Ken Production. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    var movie = NSDictionary()

    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var detailScrollView: UIScrollView!
    @IBOutlet weak var detailImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailScrollView.contentSize = CGSize(width: detailScrollView.frame.size.width, height: detailView.frame.origin.y + detailView.frame.size.height)
        
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        titleLabel.text = title
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        
        if let posterpath = movie["poster_path"] as? String {
        let baseURL = "https://image.tmdb.org/t/p/w342"
        let imageURL = NSURL(string: baseURL + posterpath)
        detailImageView.setImageWithURL(imageURL!)
        }


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
