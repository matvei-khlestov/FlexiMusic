//
//  APIService.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 05.01.2025.
//

import Foundation

final class APIService {
    static let shared = APIService()
    
    private init() {}
    
    func createRequest(searchTerm: String) -> URLRequest? {
        let parameters = prepareParameters(searchTerm: searchTerm)
        
        guard let url = self.url(parameters: parameters) else {
            return nil
        }
        
        print("Request URL: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
    
    private func prepareParameters(searchTerm: String) -> [String: String] {
        let limit: Int = 100
        let media: String = "music"
        let formattedSearchTerm = searchTerm.replacingOccurrences(of: " ", with: "+")
        return [
            "term": formattedSearchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? formattedSearchTerm,
            "limit": String(limit),
            "media": media
        ]
    }
    
    private func url(parameters: [String: String]) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "itunes.apple.com"
        components.path = "/search"
        components.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
        return components.url
    }
}

