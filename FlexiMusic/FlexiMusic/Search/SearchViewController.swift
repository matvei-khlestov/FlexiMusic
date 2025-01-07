//
//  SearchViewController.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 06.01.2025.
//  Copyright (c) 2025 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import Kingfisher

// MARK: - SearchDisplayLogicProtocol
protocol SearchDisplayLogicProtocol: AnyObject {
    func displayData(viewModel: Search.Model.ViewModel.ViewModelData)
}

// MARK: - SearchViewController
final class SearchViewController: UITableViewController, SearchDisplayLogicProtocol {
    
    // MARK: - Properties
    var interactor: SearchBusinessLogic?
    var router: (NSObjectProtocol & SearchRoutingLogic)?
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchTimer: Timer?
    private var searchViewModel = SearchViewModel(cells: [])
    
    // MARK: - Routing
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        registerTableViewCell()
        
        setupSearchBar()
    }
    
    // MARK: - SearchDisplayLogic
    func displayData(viewModel: Search.Model.ViewModel.ViewModelData) {
        switch viewModel {
        case .some:
            print("viewController .some")
        case .displayTracks(let searchViewModel):
            self.searchViewModel = searchViewModel
            tableView.reloadData()
        }
    }
    
    // MARK: - Setup
    private func setup() {
        let viewController = self
        let interactor = SearchInteractor()
        let presenter = SearchPresenter()
        let router = SearchRouter()
        
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
    }
}

// MARK: - Private Methods
extension SearchViewController {
    private func registerTableViewCell() {
        tableView.register(
            TrackTableViewCell.self,
            forCellReuseIdentifier: TrackTableViewCell.reuseId
        )
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
    }
}

// MARK: - UITableViewDataSource
extension SearchViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchViewModel.cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackTableViewCell.reuseId, for: indexPath)
        guard let cell = cell as? TrackTableViewCell else { return UITableViewCell() }
        
        let cellViewModel = searchViewModel.cells[indexPath.row]
        cell.configure(viewModel: cellViewModel)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        84
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        //
        //        guard !trimmedText.isEmpty else {
        //            //            self.tracks = []
        //            self.tableView.reloadData()
        //            return
        //        }
        
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
            guard let self = self else { return }
            self.interactor?.makeRequest(request: Search.Model.Request.RequestType.getTracks(searchTerm: searchText))
        })
    }
}
