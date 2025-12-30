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
                case getTracks(searchTerm: String)
            }
        }
        
        struct Response {
            enum ResponseType {
                case presentTracks(tracks: [Track]?)
                case presentFooterView
            }
        }
        
        struct ViewModel {
            enum ViewModelData {
                case displayTracks(SearchViewModel: SearchViewModel)
                case displayFooterView
            }
        }
    }
}

struct SearchViewModel {
    struct Cell: TrackTableViewCellViewModel {
        var iconUrl: URL?
        var trackName: String
        var collectionName: String
        var artistName: String
        var previewUrl: URL?
    }
    
    let cells: [Cell]
}
