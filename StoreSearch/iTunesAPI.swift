//
// Created by Qiao Zhang on 1/4/17.
// Copyright (c) 2017 Qiao Zhang. All rights reserved.
//

import Foundation

class iTunesAPI {
  
  static let shared = iTunesAPI()
  private init() {}
  
  func iTunesURL(query: String) -> URL {
    let escapedQuery =
        query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    let urlString = String(format: "https://itunes.apple.com/search?term=%@",
                           escapedQuery!)
    let url = URL(string: urlString)
    return url!
  }
}

extension iTunesAPI: RemoteAPI {
  func search(with query: String) -> [SearchResult]? {
    do {
      let url = iTunesURL(query: query)
      let jsonString = try String(contentsOf: url, encoding: .utf8)
      return parse(json: jsonString)
    } catch {
      print("Download Error: \(error)")
      return nil
    }
  }
  
  private func parse(json: String) -> [SearchResult]? {
    guard let data = json.data(using: .utf8, allowLossyConversion: false) else {
      return nil
    }
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
  
  private func parse(dictionary: [String: Any]) -> [SearchResult] {
    guard let array = dictionary["results"] as? [Any] else {
      print("Expected 'results' array")
      return []
    }
    
    var searchResults: [SearchResult] = []
    for resultDict in array {
      if let resultDict = resultDict as? [String: Any] {
        var searchResult: SearchResult!
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
    }
    
    return searchResults
  }
  
  private func parse(track dict: [String: Any]) -> SearchResult {
    let name = dict["trackName"] as! String
    let artistName = dict["artistName"] as! String
    let artworkSmallURL = dict["artworkUrl60"] as! String
    let artworkLargeURL = dict["artworkUrl100"] as! String
    let storeURL = dict["trackViewUrl"] as! String
    let kind = dict["kind"] as! String
    let currency = dict["currency"] as! String
    let price = dict["trackPrice"] as? Double ?? 0.0
    let genre = dict["primaryGenreName"] as? String ?? ""
    return SearchResult(name: name, artistName: artistName,
                        artworkSmallURL: artworkSmallURL,
                        artworkLargeURL: artworkLargeURL,
                        storeURL: storeURL, kind: kind,
                        currency: currency, price: price, genre: genre)
  }
  
  private func parse(audiobook dict: [String: Any]) -> SearchResult {
    let name = dict["collectionName"] as? String ?? ""
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
  
  private func parse(software dict: [String: Any]) -> SearchResult {
    let name = dict["trackName"] as? String ?? ""
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
  
  private func parse(ebook dict: [String: Any]) -> SearchResult {
    let name = dict["trackName"] as? String ?? ""
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
