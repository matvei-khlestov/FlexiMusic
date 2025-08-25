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
    
    private lazy var footerView = FooterView()
    
    // MARK: - Routing
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        configureTableViewCell()
        
        setupSearchBar()
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - SearchDisplayLogic
    
    func displayData(viewModel: Search.Model.ViewModel.ViewModelData) {
        switch viewModel {
        case .displayTracks(let searchViewModel):
            self.searchViewModel = searchViewModel
            tableView.reloadData()
            footerView.hideLoader()
        case .displayFooterView:
            footerView.showLoader()
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
    private func configureTableViewCell() {
        tableView.register(
            TrackTableViewCell.self,
            forCellReuseIdentifier: TrackTableViewCell.reuseId
        )
        
        tableView.tableFooterView = footerView
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        let cellViewModel = searchViewModel.cells[indexPath.row]
        let trackDetailView = TrackDetailView()
        trackDetailView.frame = window.bounds
        trackDetailView.configure(viewModel: cellViewModel)
        window.addSubview(trackDetailView)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Please enter a search term above..."
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        searchViewModel.cells.count > 0 ? 0 : 250
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
            guard let self = self else { return }
            self.interactor?.makeRequest(request: Search.Model.Request.RequestType.getTracks(searchTerm: searchText))
        })
    }
}
