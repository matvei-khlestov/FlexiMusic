//
//  NetworkService.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 05.01.2025.
//

import Foundation

final class NetworkService {
    private let apiManager = APIService.shared
    
    static let shared = NetworkService()
    
    private init() {}
    
    func fetchTracks(searchTerm: String, completion: @escaping (Result<[Track], NetworkError>) -> Void) {
        guard let request = apiManager.createRequest(searchTerm: searchTerm) else {
            completion(.failure(.invalidRequest))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse {
                print("Response status code: \(response.statusCode)")
            }
            
            guard let data = data else {
                sendFailure(with: .noData(description: error?.localizedDescription ?? "No error description"))
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let searchResponse = try decoder.decode(SearchResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(searchResponse.results))
                }
            } catch {
                sendFailure(with: .decodingError(description: error.localizedDescription))
            }
            
            func sendFailure(with error: NetworkError) {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
