//
// Created by Qiao Zhang on 1/4/17.
// Copyright (c) 2017 Qiao Zhang. All rights reserved.
//

import Foundation

class iTunesAPI: SearchResultStore {
  
  static let shared = iTunesAPI()
  private init() {}
  
  private var currentSearchDataTask: URLSessionDataTask?
  
  func iTunesURL(query: String, category: SearchResultCategory) -> URL {
    
    let entityString: String
    switch category {
    case .music:
      entityString = "musicTrack"
    case .software:
      entityString = "software"
    case .ebooks:
      entityString = "ebook"
    default:
      entityString = ""
    }
    
    let escapedQuery =
        query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    let urlString = String(
        format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@", 
        escapedQuery!, entityString)
    let url = URL(string: urlString)
    return url!
  }
  
  func search(with query: String,
              category: SearchResultCategory,
              completion: @escaping ([SearchResult]?) -> Void) {
    
    let url = iTunesURL(query: query, category: category)
    
    currentSearchDataTask = URLSession.shared.dataTask(with: url) {
      data, response, error in
      
      if let error = error as? NSError, error.code == -999 {
        return // Search was cancelled
      }
      
      if error != nil {
        return completion(nil)
      }
      
      if let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 {
        return completion(self.parse(json: data!))
      }
      
      return completion(nil)
    }
    currentSearchDataTask?.resume()
  }

  func cancelCurrentSearch() {
    currentSearchDataTask?.cancel()
  }


  private func parse(json data: Data) -> [SearchResult]? {
    do {
      guard let jsonDict = try JSONSerialization.jsonObject(
          with: data, options: []) as? [String: Any] else {
        return nil
      }
      return parse(dictionary: jsonDict)
    } catch {
      print("JSON Error: \(error)")
      return nil
    }
  }
  
  private func parse(dictionary: [String: Any]) -> [SearchResult]? {
    guard let array = dictionary["results"] as? [Any] else {
      print("Expected 'results' array")
      return nil
    }
    
    var searchResults: [SearchResult] = []
    array.flatMap { $0 as? [String: Any] }.forEach { resultDict in
          var searchResult: SearchResult?
          if let wrapperType = resultDict["wrapperType"] as? String {
            switch wrapperType {
            case "track":
              searchResult = parse(track: resultDict)
            case "audiobook":
              searchResult = parse(audiobook: resultDict)
            case "software":
              searchResult = parse(software: resultDict)
            default:
              break
            }
          } else if let kind = resultDict["kind"] as? String, kind == "ebook" {
            searchResult = parse(ebook: resultDict)
          }
          
          if let result = searchResult {
            searchResults.append(result)
          }
        }
    
    return searchResults
  }
  
  private func parse(track dict: [String: Any]) -> SearchResult? {
    guard let name = dict["trackName"] as? String else { return nil }
    let artistName = dict["artistName"] as? String ?? ""
    let artworkSmallURL = dict["artworkUrl60"] as? String ?? ""
    let artworkLargeURL = dict["artworkUrl100"] as? String ?? ""
    let storeURL = dict["trackViewUrl"] as? String ?? ""
    let kind = dict["kind"] as? String ?? ""
    let currency = dict["currency"] as? String ?? ""
    let price = dict["trackPrice"] as? Double ?? 0.0
    let genre = dict["primaryGenreName"] as? String ?? ""
    return SearchResult(name: name, artistName: artistName,
                        artworkSmallURL: artworkSmallURL,
                        artworkLargeURL: artworkLargeURL,
                        storeURL: storeURL, kind: kind,
                        currency: currency, price: price, genre: genre)
  }
  
  private func parse(audiobook dict: [String: Any]) -> SearchResult? {
    guard let name = dict["collectionName"] as? String else { return nil }
    let artistName = dict["artistName"] as? String ?? ""
    let artworkSmallURL = dict["artworkUrl60"] as? String ?? ""
    let artworkLargeURL = dict["artworkUrl100"] as? String ?? ""
    let storeURL = dict["collectionViewUrl"] as? String ?? ""
    let kind = "audiobook"
    let currency = dict["currency"] as? String ?? ""
    let price = dict["collectionPrice"] as? Double ?? 0.0
    let genre = dict["primaryGenreName"] as? String ?? ""
    return SearchResult(name: name, artistName: artistName,
                        artworkSmallURL: artworkSmallURL,
                        artworkLargeURL: artworkLargeURL,
                        storeURL: storeURL, kind: kind,
                        currency: currency, price: price, genre: genre)
  }
  
  private func parse(software dict: [String: Any]) -> SearchResult? {
    guard let name = dict["trackName"] as? String else { return nil }
    let artistName = dict["artistName"] as? String ?? ""
    let artworkSmallURL = dict["artworkUrl60"] as? String ?? ""
    let artworkLargeURL = dict["artworkUrl100"] as? String ?? ""
    let storeURL = dict["trackViewUrl"] as? String ?? ""
    let kind = dict["kind"] as? String ?? ""
    let currency = dict["currency"] as? String ?? ""
    let price = dict["price"] as? Double ?? 0.0
    let genre = dict["primaryGenreName"] as? String ?? ""
    return SearchResult(name: name, artistName: artistName,
                        artworkSmallURL: artworkSmallURL,
                        artworkLargeURL: artworkLargeURL,
                        storeURL: storeURL, kind: kind,
                        currency: currency, price: price, genre: genre)
  }
  
  private func parse(ebook dict: [String: Any]) -> SearchResult? {
    guard let name = dict["trackName"] as? String else { return nil }
    let artistName = dict["artistName"] as? String ?? ""
    let artworkSmallURL = dict["artworkUrl60"] as? String ?? ""
    let artworkLargeURL = dict["artworkUrl100"] as? String ?? ""
    let storeURL = dict["trackViewUrl"] as? String ?? ""
    let kind = dict["kind"] as? String ?? ""
    let currency = dict["currency"] as? String ?? ""
    let price = dict["price"] as? Double ?? 0.0
    var genre = ""
    if let genres = dict["genres"] as? [String] {
      genre = genres.joined(separator: ", ")
    }
    return SearchResult(name: name, artistName: artistName,
                        artworkSmallURL: artworkSmallURL,
                        artworkLargeURL: artworkLargeURL,
                        storeURL: storeURL, kind: kind,
                        currency: currency, price: price, genre: genre)
  }
}
