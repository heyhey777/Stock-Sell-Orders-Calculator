import SwiftUI

struct StrategySettingsView: View {
    @ObservedObject var settingsManager: StrategySettingsManager
    @State private var totalAllocation: Double = 0
    @State private var showingAllocationWarning = false
    @State private var newSetupName = ""
    @State private var showingSaveAlert = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        totalAllocationCard
                        
                        targetSection(title: "Profit Taking Targets", targets: $settingsManager.currentSettings.profitTakingTargets, isStopLoss: false)
                        
                        targetSection(title: "Stop Loss Targets", targets: $settingsManager.currentSettings.stopLossTargets, isStopLoss: true)
                        
                        presetsSection
                        
                        saveStrategyButton
                    }
                    .padding()
                }
            }
            .navigationTitle("Strategy Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if totalAllocation <= 100 {
                            dismiss()
                        } else {
                            showingAllocationWarning = true
                        }
                    }
                    .foregroundColor(.blue)
                }
            }
            .alert("Save Strategy", isPresented: $showingSaveAlert) {
                TextField("Strategy Name", text: $newSetupName)
                Button("Save") {
                    if !newSetupName.isEmpty {
                        settingsManager.saveCurrentSettings(name: newSetupName)
                        newSetupName = ""
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter a name for your current strategy")
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
    
    private var totalAllocationCard: some View {
        VStack(spacing: 8) {
            Text("Total Allocation")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("\(totalAllocation, specifier: "%.2f")%")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(totalAllocation > 100 ? .red : (colorScheme == .dark ? .white : .black))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.customBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private func targetSection(title: String, targets: Binding<[StrategySettings.Target]>, isStopLoss: Bool) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            
            ForEach(targets) { $target in
                TargetRow(target: $target, isStopLoss: isStopLoss, onDelete: {
                    withAnimation {
                        targets.wrappedValue.removeAll { $0.id == target.id }
                        updateTotalAllocation()
                    }
                })
            }
            
            if targets.wrappedValue.count < 3 {
                Button(action: {
                    withAnimation {
                        targets.wrappedValue.append(StrategySettings.Target(percentage: 0, allocation: 0))
                    }
                }) {
                    Label("Add Target", systemImage: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .padding(.vertical, 8)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.customBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Presets")
                .font(.title3)
                .fontWeight(.bold)
            
            Button("Reset to Default") {
                withAnimation {
                    settingsManager.currentSettings = .default
                    updateTotalAllocation()
                }
            }
            .buttonStyle(ModernButtonStyle())
            
            ForEach(settingsManager.savedSettings) { savedSetting in
                Button(savedSetting.name) {
                    withAnimation {
                        settingsManager.currentSettings = savedSetting
                        updateTotalAllocation()
                    }
                }
                .buttonStyle(ModernButtonStyle())
            }
            .onDelete(perform: deleteSettings)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.customBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var saveStrategyButton: some View {
        Button(action: {
            showingSaveAlert = true
        }) {
            Text("Save Current Strategy")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue)
                )
        }
    }
    
    private func updateTotalAllocation() {
        totalAllocation = settingsManager.currentSettings.stopLossTargets.reduce(0) { $0 + $1.allocation } +
        settingsManager.currentSettings.profitTakingTargets.reduce(0) { $0 + $1.allocation }
    }
    
    private func deleteSettings(at offsets: IndexSet) {
        withAnimation {
            offsets.forEach { index in
                settingsManager.deleteSavedSettings(at: index)
            }
        }
    }
}

struct TargetRow: View {
    @Binding var target: StrategySettings.Target
    let isStopLoss: Bool
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(isStopLoss ? "Loss %" : "Gain %")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("", value: $target.percentage, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Allocation")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("", value: $target.allocation, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .frame(maxWidth: .infinity)
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .imageScale(.large)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.customRectangleFill)
        )
    }
}

struct ModernButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}
