//
//  SearchView.swift
//  StoreSearch
//
//  Created by Qiao Zhang on 1/1/17.
//  Copyright © 2017 Qiao Zhang. All rights reserved.
//

import UIKit

protocol SearchViewOutput {
  func performSearchAsync(
      with query: String,
      categoryString: String,
      completion: @escaping ([SearchResultCellItem]?) -> Void)
}

class SearchView: UIViewController {
  
  enum State {
    case initializing
    case beforeSearching
    case searching
    case results([SearchResultCellItem])
    case noResults
  }
  
  var state: State = .initializing {
    didSet {
      switch state {
      case .beforeSearching, .searching, .noResults:
        tableView.reloadData()
      case .results:
        tableView.reloadData()
        segmentedControl.isHidden = false
      default:
        break
      }
    }
  }
  
  enum Cell {
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
  
  var output: SearchViewOutput!
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  
  @IBAction func segmentChanged(_ sender: UISegmentedControl) {
    if let query = searchBar.text, !query.isEmpty {
      performSearch(with: query,
                    categoryIndex: segmentedControl.selectedSegmentIndex)
    }
  }
  
  // MARK: view lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 80
    let searchResultCellNib = UINib(nibName: Cell.searchResultCell.nibName!,
                                    bundle: nil)
    tableView.register(searchResultCellNib,
                       forCellReuseIdentifier: Cell.searchResultCell.identifier)
    state = .beforeSearching
  }
  
  func performSearch(with query: String, categoryIndex: Int) {
    
    guard let categoryString = segmentedControl.titleForSegment(
        at: categoryIndex) else {
      return
    }
    
    state = .searching
    
    self.output.performSearchAsync(with: query,
                                   categoryString: categoryString) {
      [unowned self] results in
      
      DispatchQueue.main.async {
        guard let results = results else {
          return self.alertNetworkError()
        }
        if results.isEmpty {
          self.state = .noResults
        } else {
          self.state = .results(results)
        }
      }
    }
  }

  func alertNetworkError() {
    let alert = UIAlertController(
        title: "Whoops...",
        message: "There was an error reading from the iTunes Store." +
            " Please try again.",
        preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default) { _ in
      self.state = .beforeSearching
    }
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
}

extension SearchView: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let query = searchBar.text, !query.isEmpty else { return }
    searchBar.resignFirstResponder()
    performSearch(with: query,
                  categoryIndex: segmentedControl.selectedSegmentIndex)
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
      let cell = tableView.dequeueReusableCell(
          withIdentifier: Cell.searchingCell.identifier,
          for: indexPath) 
      (cell.viewWithTag(1) as? UIActivityIndicatorView)?.startAnimating()
      return cell
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
