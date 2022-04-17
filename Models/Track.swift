//
//  Track.swift
//  MusicApp
//
//  Created by Artyom Beldeiko on 13.03.22.
//

import Foundation

struct Track: Codable {
    
    var trackName: String
    var collectionName: String?
    var artistName: String
    var artworkUrl100: String?
    var previewUrl: String? 

}
