//
//  Stock.swift
//  Stock Sell Orders Calculator
//
//  Created by Kate on 28/09/2024.
//

import Foundation

struct Stock: Codable, Identifiable {
    let id: UUID
    var name: String
    var averagePrice: Double
    var sharesAmount: Int
    
    init(id: UUID = UUID(), name: String, averagePrice: Double, sharesAmount: Int) {
        self.id = id
        self.name = name
        self.averagePrice = averagePrice
        self.sharesAmount = sharesAmount
    }
}
