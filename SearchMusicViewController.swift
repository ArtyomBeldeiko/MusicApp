//
//  SearchViewController.swift
//  MusicApp
//
//  Created by Artyom Beldeiko on 10.03.22.
//

import UIKit
import Alamofire

struct TrackModel {
    var trackName: String
    var artistName: String
}


class SearchMusicViewController: UITableViewController {
    
    var networkManager = NetworkManager()
    
    private var timer: Timer?
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var trackArray = [Track]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBarSetup()
        
        view.backgroundColor = .white
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }
    
    private func searchBarSetup() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let track = trackArray[indexPath.row]
        cell.textLabel?.text = "\(track.trackName)\n\(track.artistName)"
        cell.textLabel?.numberOfLines = 0
        cell.imageView?.image = UIImage(named: "Image")
        
        return cell
    }
    
}

extension SearchMusicViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.85, repeats: false, block: { _ in
            self.networkManager.fetchTracks(searchText: searchText) { [weak self] responseResults in
                self?.trackArray = responseResults?.results ?? []
                self?.tableView.reloadData()
            }
        })
        
    }
    
}
