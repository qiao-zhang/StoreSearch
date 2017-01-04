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
                     completion: @escaping ([SearchResultCellItem]) -> Void)
}

class SearchView: UIViewController {
  
  fileprivate enum State {
    case notSearchedYet
    case searching
    case results([SearchResultCellItem])
    case noResults
  }
  fileprivate var state: State = .notSearchedYet {
    didSet {
      switch state {
      case .results, .noResults:
        tableView.reloadData()
      default:
        break
      }
    }
  }
  
  fileprivate enum Cell {
    case searchResultCell
    case nothingFoundCell
    
    var nibName: String? {
      switch self {
      case .searchResultCell:
        return "SearchResultCell"
      default:
        return nil
      }
    }
    
    var identifier: String {
      switch self {
      case .searchResultCell:
        return "SearchResultCell"
      case .nothingFoundCell:
        return "NothingFoundCell"
      }
    }
    
    static var allCells: [Cell] = [.searchResultCell, .nothingFoundCell]
  }
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  var output: SearchViewOutput!
  
  // MARK: view lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 80
    let searchResultCellNib = UINib(nibName: Cell.searchResultCell.nibName!,
                                    bundle: nil)
    tableView.register(searchResultCellNib,
                       forCellReuseIdentifier: Cell.searchResultCell.identifier)
  }

}

extension SearchView: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    if let query = searchBar.text, !query.isEmpty {
      searchBar.resignFirstResponder()
      state = .searching
      output.performSearch(for: query) { results in
        if results.isEmpty { self.state = .noResults }
        else { self.state = .results(results) }
      }
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
    case .results(let results):
      return results.count
    case .noResults:
      return 1
    default:
      return 0
    }
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch state {
    case .results(let results):
      let cell =
          tableView.dequeueReusableCell(
              withIdentifier: Cell.searchResultCell.identifier,
              for: indexPath) as! SearchResultCell
      let cellItem = results[indexPath.row]
      cell.config(with: cellItem)
      return cell
    case .noResults:
      return tableView.dequeueReusableCell(
          withIdentifier: Cell.nothingFoundCell.identifier,
          for: indexPath)
    default:
      fatalError("\(#function) should never be called in \(state)")
    }
  }
}

extension SearchView: UITableViewDelegate {
  func tableView(_ tableView: UITableView,
                 willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    switch state {
    case .results:
      return indexPath
    default:
      return nil
    }
  }

  func tableView(_ tableView: UITableView,
                 didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
