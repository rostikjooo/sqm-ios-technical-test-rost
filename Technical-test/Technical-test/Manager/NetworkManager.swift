//
//  NetworkManager.swift
//  Technical-test
//
//  Created by Rost Balanyuk on 11.04.2023.
//

import Foundation

enum NetworkError: Error {
    case wrongResponse(URLResponse)
    case wrongStatusCode(Int)
    case noValidData(error: DecodingError)
    case transportError(error: Error)
}

final class NetworkManager {
    
    private let acceptableCodes = 200..<300
    private let decoder = JSONDecoder()
    private let session = URLSession.shared
    
    func fetchDecodable<T: Decodable>(ofType: T.Type, url: URL) async -> Result<T, NetworkError> {
        let result: Result<T, NetworkError>
        let urlRequest: URLRequest = .init(url: url)
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.wrongResponse(response)
            }
            
            guard acceptableCodes.contains(response.statusCode) else {
                throw NetworkError.wrongStatusCode(response.statusCode)
            }
            
            let decoded = try decoder.decode(T.self, from: data)
            result = .success(decoded)
        } catch let localError as NetworkError {
            result = .failure(localError)
        } catch let decodingError as DecodingError {
            result = .failure(.noValidData(error: decodingError))
        } catch {
            result = .failure(.transportError(error: error))
        }
        
        return result
    }
    
}
