//
//  SearchInteractor.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 06.01.2025.
//  Copyright (c) 2025 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol SearchBusinessLogic: AnyObject {
    func makeRequest(request: Search.Model.Request.RequestType)
}

final class SearchInteractor: SearchBusinessLogic {
    
    var presenter: SearchPresentationLogic?
    var service: SearchService?
    var networkService = NetworkService.shared
    
    func makeRequest(request: Search.Model.Request.RequestType) {
        if service == nil {
            service = SearchService()
        }
        
        switch request {
        case .some:
            print("interactor .some")
        case .getTracks(let searchTerm):
            print("interactor .getTracks")
            
            networkService.fetchTracks(searchTerm: searchTerm) { [weak self] result in
                switch result {
                case .success(let tracks):
                    guard let self = self else { return }
                    self.presenter?.presentData(response: Search.Model.Response.ResponseType.presentTracks(tracks: tracks))
                case .failure(let error):
                    print("Error in fetch tracks: \(error)")
                }
            }
        }
    }
}
