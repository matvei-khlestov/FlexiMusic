//
//  SearchViewController.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 06.01.2025.
//  Copyright (c) 2025 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import Kingfisher

protocol SearchDisplayLogic: AnyObject {
    func displayData(viewModel: Search.Model.ViewModel.ViewModelData)
}

final class SearchViewController: UITableViewController, SearchDisplayLogic {
    
    var interactor: SearchBusinessLogic?
    var router: (NSObjectProtocol & SearchRoutingLogic)?
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchTimer: Timer?
    private var searchViewModel = SearchViewModel(cells: [])
    
    // MARK: Routing
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        registerTableViewCell()
        
        setupSearchBar()
    }
    
    // MARK: SearchDisplayLogic
    func displayData(viewModel: Search.Model.ViewModel.ViewModelData) {
        switch viewModel {
        case .some:
            print("viewController .some")
        case .displayTracks(let searchViewModel):
            self.searchViewModel = searchViewModel
            tableView.reloadData()
        }
    }
    
    // MARK: Setup
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
            UITableViewCell.self,
            forCellReuseIdentifier: "cell"
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let cellViewModel = searchViewModel.cells[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = cellViewModel.trackName
        content.secondaryText = cellViewModel.artistName
        
        if let url = cellViewModel.iconUrl {
            let imageView = UIImageView()
            imageView.kf.setImage(with: url)
            content.image = imageView.image
        }
        cell.contentConfiguration = content
        return cell
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
