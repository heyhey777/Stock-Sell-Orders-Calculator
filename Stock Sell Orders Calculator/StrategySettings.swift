//
//  StrategySettings.swift
//  Stock Sell Orders Calculator
//
//  Created by Kate on 28/09/2024.
//

import Foundation

struct StrategySettings {
    struct Target: Identifiable {
        let id = UUID()
        var percentage: Double
        var allocation: Double
    }
    
    var stopLossTargets: [Target]
    var profitTakingTargets: [Target]
    
    static let `default` = StrategySettings(
        stopLossTargets: [Target(percentage: 2, allocation: 25), Target(percentage: 3, allocation: 25)],
        profitTakingTargets: [Target(percentage: 2, allocation: 25), Target(percentage: 3, allocation: 25)]
    )
}
