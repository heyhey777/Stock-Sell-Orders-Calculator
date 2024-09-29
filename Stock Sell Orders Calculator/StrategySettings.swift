//
//  StrategySettings.swift
//  Stock Sell Orders Calculator
//
//  Created by Kate on 28/09/2024.
//

import Foundation

struct StrategySettings: Codable, Identifiable {
    let id: UUID
    var name: String
    var stopLossTargets: [Target]
    var profitTakingTargets: [Target]
    
    struct Target: Identifiable, Codable {
        let id: UUID
        var percentage: Double
        var allocation: Double
        
        init(id: UUID = UUID(), percentage: Double, allocation: Double) {
            self.id = id
            self.percentage = percentage
            self.allocation = allocation
        }
    }
    
    init(id: UUID = UUID(), name: String, stopLossTargets: [Target], profitTakingTargets: [Target]) {
        self.id = id
        self.name = name
        self.stopLossTargets = stopLossTargets
        self.profitTakingTargets = profitTakingTargets
    }
    
    static let `default` = StrategySettings(
        name: "Default",
        stopLossTargets: [Target(percentage: 5, allocation: 50)],
        profitTakingTargets: [Target(percentage: 4, allocation: 25), Target(percentage: 7, allocation: 25)]
    )
}

class StrategySettingsManager: ObservableObject {
    @Published var currentSettings: StrategySettings
    @Published var savedSettings: [StrategySettings]
    
    private let maxSavedSettings = 5
    private let saveKey = "savedStrategySettings"
    
    init() {
        self.currentSettings = StrategySettings.default
        self.savedSettings = []
        loadSavedSettings()
    }
    
    func saveCurrentSettings(name: String) {
        let newSettings = StrategySettings(name: name, stopLossTargets: currentSettings.stopLossTargets, profitTakingTargets: currentSettings.profitTakingTargets)
        
        if savedSettings.count >= maxSavedSettings {
            savedSettings.removeFirst()
        }
        
        savedSettings.append(newSettings)
        saveToDisk()
    }
    
    func deleteSavedSettings(at index: Int) {
        savedSettings.remove(at: index)
        saveToDisk()
    }
    
    private func saveToDisk() {
        if let encoded = try? JSONEncoder().encode(savedSettings) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadSavedSettings() {
        if let savedData = UserDefaults.standard.data(forKey: saveKey),
           let decodedSettings = try? JSONDecoder().decode([StrategySettings].self, from: savedData) {
            savedSettings = decodedSettings
        }
    }
}
