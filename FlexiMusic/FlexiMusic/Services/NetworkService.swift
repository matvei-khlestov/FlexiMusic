//
//  NetworkService.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 05.01.2025.
//

import Foundation

protocol TracksFetching {
    func fetchTracks(searchTerm: String, completion: @escaping (Result<[Track], NetworkError>) -> Void)
}

final class NetworkService: TracksFetching {
    
    private let apiManager: APIService
    private let session: URLSession
    
    static let shared = NetworkService()
    
    init(apiManager: APIService = .shared, session: URLSession = .shared) {
        self.apiManager = apiManager
        self.session = session
    }
    
    func fetchTracks(searchTerm: String, completion: @escaping (Result<[Track], NetworkError>) -> Void) {
        guard let request = apiManager.createRequest(searchTerm: searchTerm) else {
            completeOnMain(.failure(.invalidRequest), completion: completion)
            return
        }
        
        session.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            
            if let error {
                self.completeOnMain(.failure(.noData(description: error.localizedDescription)), completion: completion)
                return
            }
            
            guard let data else {
                self.completeOnMain(.failure(.noData(description: "No data")), completion: completion)
                return
            }
            
            do {
                let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
                self.completeOnMain(.success(searchResponse.results), completion: completion)
            } catch {
                self.completeOnMain(.failure(.decodingError(description: error.localizedDescription)), completion: completion)
            }
        }.resume()
    }
    
    private func completeOnMain(
        _ result: Result<[Track], NetworkError>,
        completion: @escaping (Result<[Track], NetworkError>) -> Void
    ) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
}
