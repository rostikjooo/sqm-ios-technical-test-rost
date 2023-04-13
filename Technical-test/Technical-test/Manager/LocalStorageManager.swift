//
//  LocalStorageManager.swift
//  Technical-test
//
//  Created by Rost Balanyuk on 11.04.2023.
//

import Foundation

/// Manager for internal storage of Quotes which is added to favorites
/// they stored as array of `Quote: Codable & Equatable`
/// you need to call save() to fix all changes
/// it could be storage for IDs of which is favorite, but Quote doesn't have ID
/// can be dependency-inverted as protocol with associated type
final class LocalStorageManager {
    
    private static let favoriteQuotesKey = "FavoriteQuotes"
    private let storage = UserDefaults.standard
    private var buffer: [Quote]?
    
    func fetchQuotes() -> [Quote] {
        guard buffer == nil else {
            return buffer ?? []
        }
        
        let fetched = try? storage.fetchObject(
            forKey: Self.favoriteQuotesKey,
            castTo: [Quote].self
        )
        buffer = fetched ?? []
        
        return buffer ?? []
    }
    
    func save() {
        guard let buffer = buffer else { return }
        
        try! storage.saveObject(buffer, forKey: Self.favoriteQuotesKey)
    }
    
    func add(quote: Quote) {
        var buffer = fetchQuotes()
        guard !buffer.contains(quote) else { return }
        
        buffer.append(quote)
        self.buffer = buffer
    }
    
    func remove(quote: Quote) {
        var buffer = fetchQuotes()
        guard let index = buffer.firstIndex(of: quote) else { return }
        
        buffer.remove(at: index)
        self.buffer = buffer
    }
    
    func find(quote: Quote) -> Bool {
        let buffer = fetchQuotes()
        
        return buffer.contains(quote)
    }
    
}


fileprivate extension UserDefaults {
    
    enum ObjectSavableError: Error {
        case unableToEncode
        case noValue
        case unableToDecode
    }
    
    func saveObject<Object>(
        _ object: Object, forKey: String
    ) throws where Object: Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey)
        } catch {
            throw ObjectSavableError.unableToEncode
        }
    }
    
    func fetchObject<Object>(
        forKey: String, castTo type: Object.Type
    ) throws -> Object where Object: Decodable {
        guard let data = data(forKey: forKey) else { throw ObjectSavableError.noValue }
        
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw ObjectSavableError.unableToDecode
        }
    }
    
}
