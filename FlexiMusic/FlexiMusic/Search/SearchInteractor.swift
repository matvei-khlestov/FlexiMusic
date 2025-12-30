//
//  SearchInteractor.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 06.01.2025.
//  Copyright (c) 2025 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

protocol SearchBusinessLogic: AnyObject {
    func makeRequest(request: Search.Model.Request.RequestType)
}

final class SearchInteractor: SearchBusinessLogic {

    var presenter: SearchPresentationLogic?

    private let tracksFetcher: TracksFetching

    init(tracksFetcher: TracksFetching = NetworkService.shared) {
        self.tracksFetcher = tracksFetcher
    }

    func makeRequest(request: Search.Model.Request.RequestType) {
        switch request {
        case .getTracks(let searchTerm):

            presenter?.presentData(response: .presentFooterView)

            tracksFetcher.fetchTracks(searchTerm: searchTerm) { [weak self] result in
                guard let self else { return }

                switch result {
                case .success(let tracks):
                    self.presenter?.presentData(response: .presentTracks(tracks: tracks))

                case .failure(let error):
                    #if DEBUG
                    print("SearchInteractor: fetchTracks error: \(error)")
                    #endif
                }
            }
        }
    }
}
