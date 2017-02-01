//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Jeremy Lehman on 1/29/17.
//  Copyright © 2017 Jeremy Lehman. All rights reserved.
//

import UIKit
import AFNetworking
import ALLoadingView

class MoviesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var networkError: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkError.isHidden = true
        self.view.bringSubview(toFront: networkError)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(getNowPlaying(_:)), for: UIControlEvents.valueChanged)
        collectionView.insertSubview(refreshControl, at: 0)
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        
        getNowPlaying()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = movies?[indexPath.row]
        //let title = movie?["title"] as! String
        //`let overview = movie?["overview"] as! String
        
        let baseUrl = "https://image.tmdb.org/t/p/w500"
        let posterPath = movie?["poster_path"] as! String
        
        let imageUrl = URL(string: baseUrl + posterPath)
        cell.posterView.setImageWith(imageUrl!)
        print("row \(indexPath.row)")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.bounds.width
        return CGSize(width: CGFloat(totalWidth / 2 - 5), height: 240)
    }
    
    func getNowPlaying(_ refreshControl: UIRefreshControl=UIRefreshControl()) {
        ALLoadingView.manager.blurredBackground = true
        ALLoadingView.manager.showLoadingView(ofType: .basic, windowMode: .fullscreen)
        let apiKey = "f65d3699b29412f05fdccffae5a92b19"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print(dataDictionary)
                    self.movies = dataDictionary["results"] as? [NSDictionary]
                    self.collectionView.reloadData()
                    refreshControl.endRefreshing()
                    ALLoadingView.manager.hideLoadingView(withDelay: 1.0)
                    self.networkError.isHidden = true
                }
            } else {
                refreshControl.endRefreshing()
                ALLoadingView.manager.hideLoadingView(withDelay: 1.0)
                self.networkError.isHidden = false
            }
        }
        task.resume()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
