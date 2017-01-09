//
// Created by Qiao Zhang on 1/2/17.
// Copyright (c) 2017 Qiao Zhang. All rights reserved.
//

import Foundation

protocol SearchResultStore {
  func search(with query: String,
              category: SearchResultCategory,
              completion: @escaping ([SearchResult]?) -> Void)
  func cancelCurrentSearch()
}

enum SearchResultCategory {
  case music
  case software
  case ebooks
  case unspecified
}

class SearchPresenter: SearchViewOutput {
  
  private var searchResultStore: SearchResultStore
  
  init(searchResultStore: SearchResultStore) {
    self.searchResultStore = searchResultStore
  }
  
  func performSearchAsync(
      with query: String,
      categoryString: String,
      completion: @escaping ([SearchResultCellItem]?) -> Void) {
    
    cancelCurrentSearch()
    
    let category: SearchResultCategory
    switch categoryString {
    case "Music":
      category = .music
    case "Software":
      category = .software
    case "E-books":
      category = .ebooks
    default:
      category = .unspecified
    }
    
    searchResultStore.search(with: query, category: category) {
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
          let name = result.name
          return SearchResultCellItem(name: name,
                                      category: kind,
                                      artistName: artistName)
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
