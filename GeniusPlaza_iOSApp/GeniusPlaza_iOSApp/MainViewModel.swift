//
//  MainViewModel.swift
//  GeniusPlaza_iOSApp
//
//  Copyright © 2019 yashbelorkar. All rights reserved.
//

import UIKit
import Foundation

public struct Media {
    var name: String
    var type: String
    var thumbnail: String
}

public enum Endpoint: String {
    case Music = "https://rss.itunes.apple.com/api/v1/us/apple-music/hot-tracks/all/10/explicit.json"
    case Apps = "https://rss.itunes.apple.com/api/v1/us/ios-apps/new-apps-we-love/all/10/explicit.json"
}

class MainViewModel: NSObject {
    
    let appleMusicEndpoint = "https://rss.itunes.apple.com/api/v1/us/apple-music/hot-tracks/all/10/explicit.json"
    let iOSAppsEndpoint = "https://rss.itunes.apple.com/api/v1/us/ios-apps/new-apps-we-love/all/10/explicit.json"
    var musicMediaResults: [Media] = []
    var appsMediaResults: [Media] = []
    
    override init() {
        super.init()
    }
    
    func makeRequest(endpoint: String, completion: @escaping ((_ success: Bool) -> Void)) {
        if let url = URL(string: endpoint) {
            let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                
                if let data = data {
                    do {
                        // Convert the data to JSON
                        let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                        
                        if let json = jsonSerialized, let feed = json["feed"] as? [String: Any], let results = feed["results"] as? [Any] {
                            for result in results {
                                if let result = result as? [String: Any],
                                    let name = result["name"]  as? String,
                                    let thumb = result["artworkUrl100"] as? String {
                                    if endpoint == Endpoint.Music.rawValue {
                                        let media = Media(name: name, type: "Apple Music", thumbnail: thumb)
                                        self?.musicMediaResults.append(media)
                                    } else {
                                        let media = Media(name: name, type: "iOS Apps", thumbnail: thumb)
                                        self?.appsMediaResults.append(media)
                                    }
                                }
                            }
                            completion(true)
                        }
                    }  catch let error as NSError {
                        print(error)
                        completion(false)
                    }
                } else if let error = error {
                    print(error)
                    completion(false)
                }
            }
            task.resume()
        }
    }
}
