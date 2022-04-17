//
//  NetworkManager.swift
//  MusicApp
//
//  Created by Artyom Beldeiko on 13.03.22.
//

import Foundation
import Alamofire

class NetworkManager {
    
    func fetchTracks(searchText: String, completion: @escaping (ResponseResults?) -> ()) {
        
        let url = "https://itunes.apple.com/search?"
        let parameters = ["term":"\(searchText)",
                          "limit":"100",
                          "media":"music"]
        
        AF.request(url, method: .get, parameters: parameters).responseData { dataResponse in
            
            if let error = dataResponse.error {
                print(error.localizedDescription)
                completion(nil)
                return
            }
            
            guard let data = dataResponse.data else { return }
            
            let decoder = JSONDecoder()
            
            do {
                
                let objects = try decoder.decode(ResponseResults.self, from: data)
                print("objects: ", objects)
                completion(objects)
                
                
            } catch let error as NSError {
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
    
}
