//
//  QuotesDataManager.swift
//  Technical-test
//
//  Created by Patrice MIAKASSISSA on 29.04.21.
//

import Foundation


enum FetchError: Error {
    case noConnection
    case serverError
}

class QuotesDataManager {
    
    private let networkManager = NetworkManager()
    private let favoriteQuoteStorage = LocalStorageManager()
    
    func fetchQuotes() async -> Result<[Quote], FetchError> {
        let requestURL = URL(string: Self.path)!
        
        let fetchResult = await networkManager.fetchDecodable(ofType: [Quote].self, url: requestURL)
        
        return fetchResult.mapError { networkError in
            switch networkError {
            case .transportError:
                return .noConnection
            default:
                return .serverError
            }
        }
    }
    
    func markQuotesWhichFavoriteIfNeeded(_ quote: Quote) -> Quote {
        let isFavorite = favoriteQuoteStorage.find(quote: quote)
        var quote = quote
        
        quote.isFavorite = isFavorite
        
        return quote
    }
    
    func toggleIsFavorite(for quote: Quote) -> Quote {
        var quote = quote
        if !quote.isFavorite {
            favoriteQuoteStorage.add(quote: quote)
        } else {
            favoriteQuoteStorage.remove(quote: quote)
        }
        quote.isFavorite.toggle()
        
        return quote
    }
    
    func saveLocalStorage() {
        favoriteQuoteStorage.save()
    }
    
    private static let path = "https://www.swissquote.ch/mobile/iphone/Quote.action?formattedList&formatNumbers=true&listType=SMI&addServices=true&updateCounter=true&&s=smi&s=$smi&lastTime=0&&api=2&framework=6.1.1&format=json&locale=en&mobile=iphone&language=en&version=80200.0&formatNumbers=true&mid=5862297638228606086&wl=sq"
    
}
