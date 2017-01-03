//
//  SearchView.swift
//  StoreSearch
//
//  Created by Qiao Zhang on 1/1/17.
//  Copyright © 2017 Qiao Zhang. All rights reserved.
//

import UIKit

protocol SearchViewOutput {
  func performSearch(for query: String,
                     completion: @escaping ([String]) -> Void)
}

class SearchView: UIViewController {
  
  fileprivate enum State {
    case beforeAnySearching
    case searching(String)
    case showingResults([String])
  }
  fileprivate var state: State = .beforeAnySearching {
    didSet {
      switch state {
      case .showingResults:
        tableView.reloadData()
      case .searching(let query):
        output.performSearch(for: query) { results in
          self.state = .showingResults(results)
        }
      default:
        break
      }
    }
  }
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  
  var output: SearchViewOutput!
}

extension SearchView: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    if let query = searchBar.text, !query.isEmpty {
      searchBar.resignFirstResponder()
      state = .searching(query)
    }
  }

  func position(`for` bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
}

extension SearchView: UITableViewDataSource {
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    switch state {
    case .showingResults(let results):
      return results.count
    case .beforeAnySearching:
      return 0
    default:
      fatalError("Table view should not reload in state: \(state)")
    }
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard case .showingResults(let results) = state else {
      fatalError("")
    }
    var cell: UITableViewCell! =
        tableView.dequeueReusableCell(withIdentifier: "SearchResultCell")
    if cell == nil {
      cell = UITableViewCell(style: .default,
                             reuseIdentifier: "SearchResultCell")
    }
    cell.textLabel!.text = results[indexPath.row]
    return cell
  }

}

extension SearchView: UITableViewDelegate {
  
}
