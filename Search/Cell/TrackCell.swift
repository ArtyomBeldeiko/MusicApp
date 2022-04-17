//
//  TrackCell.swift
//  MusicApp
//
//  Created by Artyom Beldeiko on 15.03.22.
//

import Foundation
import UIKit
import SDWebImage

protocol TrackCellViewModel {
    var iconUrlString: String? { get }
    var trackName: String { get }
    var artistName: String { get }
    var collectionName: String { get }
}

class TrackCell: UITableViewCell {
    
    static let reuseId = "TrackCell"
    
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var collectionNameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        trackImageView.image = nil
    }
    
    var cell: SearchViewModel.Cell?
    
    func set(viewModel: SearchViewModel.Cell) {
        
        self.cell = viewModel
        
        let savedTracks = UserDefaults.standard.savedTracks()
        let hasFavourite = savedTracks.firstIndex {
            $0.trackName == self.cell?.trackName && $0.artistName == self.cell?.artistName
        } != nil
        
        if hasFavourite {
            addButton.isHidden = true
        } else {
            addButton.isHidden = false
        }
        
        trackNameLabel.text = viewModel.trackName
        artistNameLabel.text = viewModel.artistName
        collectionNameLabel.text = viewModel.collectionName
        
        guard let url = URL(string: viewModel.iconUrlString ?? "") else { return }
        
        
        trackImageView.sd_setImage(with: url, completed: nil)
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        //        defaults.set(25, forKey: "Age")
        //        defaults.set("Hello", forKey: "String")
        
        guard let cell = cell else { return }
        addButton.isHidden = true
        
        var listOfTracks = defaults.savedTracks()
        listOfTracks.append(cell)
        
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: listOfTracks, requiringSecureCoding: false) {
            print("Success")
            defaults.set(savedData, forKey: UserDefaults.favouriteTrackKey)
        }
        
    }
    
}
