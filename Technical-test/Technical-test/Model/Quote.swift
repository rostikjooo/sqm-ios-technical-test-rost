//
//  Quote.swift
//  Technical-test
//
//  Created by Patrice MIAKASSISSA on 29.04.21.
//

import Foundation

// TODO: Quote entity needs clarification: is it has ID? how it's Equatable?
struct Quote: Codable, Equatable {
    let symbol: String?
    let name: String?
    let currency: String?
    let readableLastChangePercent: String?
    let last: String?
    let variationColor: String?
    
    var isFavorite: Bool = false
    var myMarket: Market?
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.symbol == rhs.symbol &&
        lhs.name == rhs.name &&
        lhs.currency == rhs.currency
    }
    
    private enum CodingKeys: String, CodingKey {
        case symbol, name, currency, readableLastChangePercent, last, variationColor
    }
}
