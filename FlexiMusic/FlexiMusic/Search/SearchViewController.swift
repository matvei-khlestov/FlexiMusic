//
//  SearchViewController.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 06.01.2025.
//  Copyright (c) 2025 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

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
    weak var tabBarDelegate: TabBarControllerDelegate?

    deinit {
        searchTimer?.invalidate()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        configureTableViewCell()
        setupSearchBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchTimer?.invalidate()
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

private extension SearchViewController {

    func configureTableViewCell() {
        tableView.register(
            TrackTableViewCell.self,
            forCellReuseIdentifier: TrackTableViewCell.reuseId
        )

        tableView.tableFooterView = footerView
    }

    func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
    }

    func adjacentTrackViewModel(isNext: Bool) -> SearchViewModel.Cell? {
        guard let indexPath = tableView.indexPathForSelectedRow else { return nil }
        guard !searchViewModel.cells.isEmpty else { return nil }

        tableView.deselectRow(at: indexPath, animated: true)

        var nextIndexPath = indexPath

        if isNext {
            nextIndexPath.row += 1
            if nextIndexPath.row >= searchViewModel.cells.count {
                nextIndexPath.row = 0
            }
        } else {
            nextIndexPath.row -= 1
            if nextIndexPath.row < 0 {
                nextIndexPath.row = searchViewModel.cells.count - 1
            }
        }

        tableView.selectRow(at: nextIndexPath, animated: true, scrollPosition: .none)
        return searchViewModel.cells[nextIndexPath.row]
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
        let cellViewModel = searchViewModel.cells[indexPath.row]
        tabBarDelegate?.maximizeTrackDetailController(viewModel: cellViewModel)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard searchViewModel.cells.isEmpty else { return nil }

        let label = UILabel()
        label.text = "Please enter a search term above..."
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        searchViewModel.cells.isEmpty ? 250 : 0
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer?.invalidate()

        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let self else { return }
            interactor?.makeRequest(request: Search.Model.Request.RequestType.getTracks(searchTerm: trimmed))
        }
    }
}

// MARK: - TrackNavigationDelegate

extension SearchViewController: TrackNavigationDelegate {

    func previousTrackViewModel() -> SearchViewModel.Cell? {
        adjacentTrackViewModel(isNext: false)
    }

    func nextTrackViewModel() -> SearchViewModel.Cell? {
        adjacentTrackViewModel(isNext: true)
    }
}
