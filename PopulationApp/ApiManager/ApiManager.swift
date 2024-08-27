//
//  ApiManager.swift
//  PopulationApp
//
//  Created by João Santos on 27/08/2024.
//

import Foundation

enum ApiError: Error {
    case invalidResponse
    case request
}

extension ApiError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .request:
            return "Invalid request"
        case .invalidResponse:
            return "Got an invalid response from the server."
        }
    }
}

class ApiManager {
    
    // Ideally URL should come from a Configuration file.
    // Using hardcoded for the sake of simplicity
    private let url = "https://datausa.io/api/data"
    private let session: URLSession
    private let decoder = JSONDecoder()
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func fetchStateData() async throws -> StateData {
        let url = URL(string: self.url + "?drilldowns=State&measures=Population&year=latest")!
        let request = URLRequest(url: url)

        return try await self.fetch(request: request, type: StateData.self)
    }
    
    func fetchNationData() async throws -> NationData {
        let url = URL(string: self.url + "?drilldowns=Nation&measures=Population")!
        let request = URLRequest(url: url)

        return try await self.fetch(request: request, type: NationData.self)
    }
    
    private func fetch<T: Codable>(request: URLRequest, type: T.Type) async throws -> T {
        let (data, response) = try await self.session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw ApiError.invalidResponse
        }
        
        return try self.decoder.decode(type, from: data)
    }
    
}
