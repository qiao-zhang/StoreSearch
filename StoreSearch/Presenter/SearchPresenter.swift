//
// Created by Qiao Zhang on 1/2/17.
// Copyright (c) 2017 Qiao Zhang. All rights reserved.
//

import Foundation

protocol SearchResultStore {
  func search(with query: String,
              completion: @escaping ([SearchResult]?) -> Void)
  func cancelCurrentSearch()
}

class SearchPresenter: SearchViewOutput {
  
  private var searchResultStore: SearchResultStore
  
  init(searchResultStore: SearchResultStore) {
    self.searchResultStore = searchResultStore
  }
  
  func performSearchAsync(
      with query: String,
      completion: @escaping ([SearchResultCellItem]?) -> Void) {
    
    cancelCurrentSearch()
    
    searchResultStore.search(with: query) {
      [unowned self] results in
      
      guard let results = results else {
        completion(nil)
        return
      }
      
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
  
  func cancelCurrentSearch() {
    searchResultStore.cancelCurrentSearch()
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
