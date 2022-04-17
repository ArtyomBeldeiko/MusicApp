//
//  ResponseResults.swift
//  MusicApp
//
//  Created by Artyom Beldeiko on 13.03.22.
//

import Foundation

struct ResponseResults: Codable {
    
    var resultCount: Int
    var results: [Track]
    
}
