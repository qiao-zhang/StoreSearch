//
// Created by Qiao Zhang on 1/2/17.
// Copyright (c) 2017 Qiao Zhang. All rights reserved.
//

import Foundation

protocol RemoteAPI {
  func search(with query: String) -> [SearchResult]?
}

class SearchPresenter: SearchViewOutput {
  
  var remoteAPI: RemoteAPI
  
  init(remoteAPI: RemoteAPI) {
    self.remoteAPI = remoteAPI
  }
  
  func performSearchAsync(with query: String,
                     completion: @escaping ([SearchResultCellItem]) -> Void) {
    print("Search \(query)")
    
    let queue = DispatchQueue.global()
    queue.async {
      let results = self.remoteAPI.search(with: query) ?? []

      let items =
          results.map { (result: SearchResult) -> SearchResultCellItem in
        let kind = self.kindForDisplay(result.kind)
        let artistName =
            result.artistName.isEmpty ? "Unknown" : result.artistName
        let title = result.name + (kind.isEmpty ? "" : " (\(kind))")
        return SearchResultCellItem(title: title, artistName: artistName)
      }.sorted(by: <)

      completion(items)
    }
  }
  
  private func kindForDisplay(_ kind: String) -> String {
    switch kind {
    case "album": return "Album"
    case "audiobook": return "Audio Book"
    case "book": return "Book"
    case "ebook": return "E-Book"
    case "feature-movie": return "Movie"
    case "music-video": return "Music Video"
    case "podcast": return "Podcast"
    case "software": return "App"
    case "song": return "Song"
    case "tv-episode": return "TV Episode"
    default: return kind
    }
  }
}
