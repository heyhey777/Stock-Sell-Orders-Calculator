import Foundation
import SwiftUI

struct StrategySettings: Codable, Identifiable {
    let id: UUID
    var name: String
    var stopLossTargets: [Target]
    var profitTakingTargets: [Target]
    
    init(id: UUID = UUID(), name: String, stopLossTargets: [Target], profitTakingTargets: [Target]) {
        self.id = id
        self.name = name
        self.stopLossTargets = stopLossTargets
        self.profitTakingTargets = profitTakingTargets
    }
    
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
    
    static var `default`: StrategySettings {
        StrategySettings(
            name: "Default",
            stopLossTargets: [
                Target(percentage: 5, allocation: 25),
                Target(percentage: 10, allocation: 25)
            ],
            profitTakingTargets: [
                Target(percentage: 10, allocation: 25),
                Target(percentage: 20, allocation: 25)
            ]
        )
    }
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
        guard index >= 0 && index < savedSettings.count else { return }
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
