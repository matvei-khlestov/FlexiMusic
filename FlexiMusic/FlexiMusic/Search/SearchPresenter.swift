//
//  SearchPresenter.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 06.01.2025.
//  Copyright (c) 2025 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

protocol SearchPresentationLogic: AnyObject {
    func presentData(response: Search.Model.Response.ResponseType)
}

final class SearchPresenter: SearchPresentationLogic {

    weak var viewController: SearchDisplayLogicProtocol?

    func presentData(response: Search.Model.Response.ResponseType) {
        switch response {

        case .presentTracks(let searchResults):
            let cells = searchResults?.compactMap { cellViewModel(from: $0) } ?? []
            let searchViewModel = SearchViewModel(cells: cells)

            viewController?.displayData(
                viewModel: .displayTracks(SearchViewModel: searchViewModel)
            )

        case .presentFooterView:
            viewController?.displayData(viewModel: .displayFooterView)
        }
    }

    private func cellViewModel(from track: Track) -> SearchViewModel.Cell {
        SearchViewModel.Cell(
            iconUrl: track.artworkUrl100,
            trackName: track.trackName,
            collectionName: track.collectionName ?? "",
            artistName: track.artistName,
            previewUrl: track.previewUrl
        )
    }
}
