//
//  SearchPresenter.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 06.01.2025.
//  Copyright (c) 2025 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol SearchPresentationLogic: AnyObject {
    func presentData(response: Search.Model.Response.ResponseType)
}

final class SearchPresenter: SearchPresentationLogic {
    
    weak var viewController: SearchDisplayLogicProtocol?
    
    func presentData(response: Search.Model.Response.ResponseType) {
        switch response {
        case .some:
            print("presenter .some")
        case .presentTracks(let searchResults):
            let cells = searchResults?.compactMap({ track in
                cellViewModel(from: track)
            }) ?? []
            
            let searchViewModel = SearchViewModel(cells: cells)
            print("presenter .presentTracks")
            viewController?.displayData(viewModel: Search.Model.ViewModel.ViewModelData.displayTracks(SearchViewModel: searchViewModel))
        }
    }
    
    private func cellViewModel(from track: Track) -> SearchViewModel.Cell {
        return SearchViewModel.Cell(
            iconUrl: track.artworkUrl100,
            trackName: track.trackName,
            collectionName: track.collectionName ?? "",
            artistName: track.artistName,
            previewUrl: track.previewUrl
        )
    }
}
