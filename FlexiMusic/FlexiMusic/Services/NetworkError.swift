//
//  NetworkError.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 05.01.2025.
//

// MARK: - NetworkError
extension NetworkService {
    enum NetworkError: Error {
        case invalidRequest
        case noData(description: String)
        case decodingError(description: String)
    }
}
