//
//  StrategySettingsView.swift
//  Stock Sell Orders Calculator
//
//  Created by Kate on 28/09/2024.
//

import SwiftUI

struct StrategySettingsView: View {
    @StateObject private var settingsManager = StrategySettingsManager()
    @State private var totalAllocation: Double = 0
    @State private var showingAllocationWarning = false
    @State private var newSetupName = ""
    @State private var showingSaveAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Presets")) {
                    Button("Reset to Default") {
                        settingsManager.currentSettings = .default
                        updateTotalAllocation()
                    }
                    
                    ForEach(settingsManager.savedSettings) { savedSetting in
                        Button(savedSetting.name) {
                            settingsManager.currentSettings = savedSetting
                            updateTotalAllocation()
                        }
                    }
                    .onDelete(perform: deleteSettings)
                }
                
                Section(header: Text("Stop Loss Targets")) {
                    ForEach($settingsManager.currentSettings.stopLossTargets) { $target in
                        TargetRow(target: $target, isStopLoss: true, onDelete: {
                            settingsManager.currentSettings.stopLossTargets.removeAll { $0.id == target.id }
                            updateTotalAllocation()
                        })
                    }
                    
                    if settingsManager.currentSettings.stopLossTargets.count < 3 {
                        Button("Add Stop Loss Target") {
                            settingsManager.currentSettings.stopLossTargets.append(StrategySettings.Target(percentage: 0, allocation: 0))
                        }
                    }
                }
                
                Section(header: Text("Profit Taking Targets")) {
                    ForEach($settingsManager.currentSettings.profitTakingTargets) { $target in
                        TargetRow(target: $target, isStopLoss: false, onDelete: {
                            settingsManager.currentSettings.profitTakingTargets.removeAll { $0.id == target.id }
                            updateTotalAllocation()
                        })
                    }
                    
                    if settingsManager.currentSettings.profitTakingTargets.count < 3 {
                        Button("Add Profit Taking Target") {
                            settingsManager.currentSettings.profitTakingTargets.append(StrategySettings.Target(percentage: 0, allocation: 0))
                        }
                    }
                }
                
                Section {
                    Text("Total Allocation: \(totalAllocation, specifier: "%.2f")%")
                        .foregroundColor(totalAllocation > 100 ? .red : .primary)
                }
                
                Section {
                    Button("Save Current Setup") {
                        showingSaveAlert = true
                    }
                }
            }
            .navigationTitle("Strategy Settings")
            .navigationBarItems(trailing: Button("Done") {
                if totalAllocation <= 100 {
                    dismiss()
                } else {
                    showingAllocationWarning = true
                }
            })
            .alert("Save Setup", isPresented: $showingSaveAlert) {
                TextField("Setup Name", text: $newSetupName)
                Button("Save") {
                    if !newSetupName.isEmpty {
                        settingsManager.saveCurrentSettings(name: newSetupName)
                        newSetupName = ""
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter a name for your current setup")
            }
            .alert(isPresented: $showingAllocationWarning) {
                Alert(
                    title: Text("Invalid Allocation"),
                    message: Text("Total allocation exceeds 100%. Please adjust your allocations."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                updateTotalAllocation()
            }
        }
    }
    
    private func updateTotalAllocation() {
        totalAllocation = settingsManager.currentSettings.stopLossTargets.reduce(0) { $0 + $1.allocation } +
                          settingsManager.currentSettings.profitTakingTargets.reduce(0) { $0 + $1.allocation }
    }
    
    private func deleteSettings(at offsets: IndexSet) {
        offsets.forEach { index in
            settingsManager.deleteSavedSettings(at: index)
        }
    }
}

struct TargetRow: View {
    @Binding var target: StrategySettings.Target
    let isStopLoss: Bool
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            TextField(isStopLoss ? "Loss %" : "Gain %", value: $target.percentage, format: .number)
                .keyboardType(.decimalPad)
            Text("%")
            Spacer()
            TextField("Allocation", value: $target.allocation, format: .number)
                .keyboardType(.decimalPad)
            Text("%")
            Button(action: onDelete) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
            }
        }
    }
}

struct StrategySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        StrategySettingsView()
    }
}
