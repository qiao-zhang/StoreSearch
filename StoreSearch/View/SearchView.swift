//
//  SearchView.swift
//  StoreSearch
//
//  Created by Qiao Zhang on 1/1/17.
//  Copyright © 2017 Qiao Zhang. All rights reserved.
//

import UIKit

protocol SearchViewOutput {
  func performSearchAsync(with query: String,
                          completion: @escaping ([SearchResultCellItem]) -> Void)
}

class SearchView: UIViewController {
  
  fileprivate enum State {
    case notSearchedYet
    case searching
    case results([SearchResultCellItem])
    case noResults
  }
  fileprivate var state: State = .notSearchedYet
  
  fileprivate enum Cell {
    case searchResultCell
    case nothingFoundCell
    case searchingCell
    
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
      case .searchingCell:
        return "SearchingCell"
      }
    }
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
    searchBar.becomeFirstResponder()
  }

}

extension SearchView: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    if let query = searchBar.text, !query.isEmpty {
      searchBar.resignFirstResponder()
      state = .searching
      tableView.reloadData()

      self.output.performSearchAsync(with: query) { [unowned self] results in
        DispatchQueue.main.async {
          if results.isEmpty {
            self.state = .noResults
          } else {
            self.state = .results(results)
          }
          self.tableView.reloadData()
        }
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
    case .noResults, .searching:
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
    case .searching:
      return tableView.dequeueReusableCell(
          withIdentifier: Cell.searchingCell.identifier,
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
