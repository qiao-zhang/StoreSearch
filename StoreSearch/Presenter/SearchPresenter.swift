//
// Created by Qiao Zhang on 1/2/17.
// Copyright (c) 2017 Qiao Zhang. All rights reserved.
//

import Foundation

class SearchPresenter: SearchViewOutput {
  func performSearch(`for` query: String,
                     completion: @escaping ([SearchResultCellItem]) -> Void) {
    if query == "Bieber" {
      completion([])
      return
    }
    
    let results = ["1", "2", "3"].map {
      SearchResultCellItem(name: "Fake result \($0) for",
                           artistName: query)
    }
    completion(results)
  }
}
