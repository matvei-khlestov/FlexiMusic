//
//  SearchModels.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 06.01.2025.
//  Copyright (c) 2025 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

enum Search {
    enum Model {
        struct Request {
            enum RequestType {
                case some
                case getTracks(searchTerm: String)
            }
        }
        struct Response {
            enum ResponseType {
                case some
                case presentTracks(tracks: [Track]?)
            }
        }
        struct ViewModel {
            enum ViewModelData {
                case some
                case displayTracks(SearchViewModel: SearchViewModel)
            }
        }
    }
}

struct SearchViewModel {
    struct Cell: TrackCellViewModelProtocol {
        var iconUrl: URL?
        var trackName: String
        var collectionName: String
        var artistName: String
        var previewUrl: URL?
    }
    
    let cells: [Cell]
}
