//
//  SearchTableViewController.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 05.01.2025.
//

import UIKit
import Kingfisher

final class SearchTableViewController: UITableViewController {
    
    private var tracks = [Track]()
    private var searchTimer: Timer?
    private let networkService = NetworkService.shared
    private let searchController = UISearchController(
        searchResultsController: nil
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableViewCell()
        setupSearchBar()
    }
}

// MARK: - Private Methods
extension SearchTableViewController {
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
    
    private func fetchTracks(searchTerm: String) {
        networkService.fetchTracks(searchTerm: searchTerm) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let tracks):
                self.tracks = tracks
            case .failure(let error):
                print("Error in fetch tracks: \(error)")
            }
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource
extension SearchTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let track = tracks[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = track.trackName
        content.secondaryText = track.artistName
        if let url = track.artworkUrl100 {
            let imageView = UIImageView()
            imageView.kf.setImage(with: url)
            content.image = imageView.image
        }
        
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UISearchBarDelegate
extension SearchTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedText.isEmpty else {
            self.tracks = []
            self.tableView.reloadData()
            return
        }
        
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            self.fetchTracks(searchTerm: trimmedText)
        })
    }
}
