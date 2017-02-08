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

class MoviesViewController: UIViewController {
    @IBOutlet weak var networkError: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var searchBar: UISearchBar!

    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var endpoint: String = "now_playing"
    override func viewDidLoad() {
        super.viewDidLoad()
        networkError.isHidden = true
        collectionView.bringSubview(toFront: searchBar)
        self.view.bringSubview(toFront: networkError)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(getMovies(_:)), for: UIControlEvents.valueChanged)
        collectionView.insertSubview(refreshControl, at: 0)
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        getMovies()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func getMovies(_ refreshControl: UIRefreshControl=UIRefreshControl()) {
        ALLoadingView.manager.blurredBackground = true
        ALLoadingView.manager.showLoadingView(ofType: .basic, windowMode: .fullscreen)
        let apiKey = "f65d3699b29412f05fdccffae5a92b19"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    self.movies = dataDictionary["results"] as? [NSDictionary]
                    self.filteredMovies = dataDictionary["results"] as? [NSDictionary]
                    self.collectionView.reloadData()
                    refreshControl.endRefreshing()
                    ALLoadingView.manager.hideLoadingView(withDelay: 0.1)
                    self.networkError.isHidden = true
                }
            } else {
                refreshControl.endRefreshing()
                ALLoadingView.manager.hideLoadingView(withDelay: 0.1)
                self.networkError.isHidden = false
            }
        }
        task.resume()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPath(for: cell)
        let movie = movies?[(indexPath?.row)!]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
    }

}

extension MoviesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = filteredMovies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = filteredMovies?[indexPath.row]
        
        let baseUrl = "https://image.tmdb.org/t/p/w500"
        let posterPath = movie?["poster_path"] as! String
        
        let imageUrl = URL(string: baseUrl + posterPath)
        let imageRequest = URLRequest(url: imageUrl!)
        cell.posterView.setImageWith(imageRequest, placeholderImage: nil, success: {(imageRequest, imageResponse, image) -> Void in
            if imageResponse != nil {
                cell.posterView.alpha = 0.0
                cell.posterView.image = image
                UIView.animate(withDuration: 1.0, animations: {() -> Void in
                    cell.posterView.alpha = 1.0
                })
            } else {
                cell.posterView.image = image
            }}, failure: {(imageRequest, imageResponse, error) -> Void in
                print(error)
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.bounds.width
        return CGSize(width: CGFloat(totalWidth / 2 - 5), height: 240)
    }
}

extension MoviesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let movies = movies {
            filteredMovies = searchText.isEmpty ? movies : movies.filter({(movie: NSDictionary) -> Bool in
                let title = movie["title"] as! String
                return (title.range(of: searchText, options: .caseInsensitive) != nil)
        })
        collectionView.reloadData()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredMovies = movies
        collectionView.reloadData()
    }
}
