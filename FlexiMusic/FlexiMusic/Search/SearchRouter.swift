//
//  SearchRouter.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 06.01.2025.
//  Copyright (c) 2025 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol SearchRoutingLogic: AnyObject {
    
}

protocol SearchDataPassing {
    //  var dataStore: SearchDataStore? { get }
}

final class SearchRouter: NSObject, SearchRoutingLogic {
    
    weak var viewController: SearchViewController?
    
    // MARK: Routing
    
}
