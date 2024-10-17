import SwiftUI
import Combine

struct StrategySettingsView: View {
    @ObservedObject var settingsManager: StrategySettingsManager
    @EnvironmentObject var store: Store
    @State private var totalAllocation: Double = 0
    @State private var showingAllocationWarning = false
    @State private var newSetupName = ""
    @State private var showingSaveAlert = false
    @State private var showPurchaseView = false
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: UUID?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 12) {
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
                    .foregroundColor(.accentColor)
                }
            }
            .alert("Save Strategy", isPresented: $showingSaveAlert) {
                TextField("Strategy Name", text: $newSetupName)
                Button("Save") {
                    if !newSetupName.isEmpty {
                        if totalAllocation <= 100 {
                            Task {
                                await settingsManager.saveCurrentSettings(name: newSetupName, store: store)
                                newSetupName = ""
                                if settingsManager.showPurchaseView {
                                    settingsManager.showPurchaseView = false
                                    showPurchaseView = true
                                }
                            }
                        } else {
                            showingAllocationWarning = true
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter a name for your current strategy")
            }
            .sheet(isPresented: $showPurchaseView) {
                PurchaseView()
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
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
    
    private var totalAllocationCard: some View {
        VStack(spacing: 8) {
            Text("Total Allocation")
                .font(.headline)
                .foregroundColor(.secondary)
            Text(String(format: "%.2f", totalAllocation).replacingOccurrences(of: ".00", with: "") + "%")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(totalAllocation > 100 ? .red : .primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.customRectangleFill)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }

    private func targetSection(title: String, targets: Binding<[StrategySettings.Target]>, isStopLoss: Bool) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            
            ForEach(targets.wrappedValue, id: \.id) { target in
                TargetRow(target: binding(for: target, in: targets), isStopLoss: isStopLoss, focusedField: _focusedField, onDelete: {
                    withAnimation {
                        targets.wrappedValue.removeAll { $0.id == target.id }
                        updateTotalAllocation()
                    }
                }, onUpdate: {
                    updateTotalAllocation()
                })
            }
            
            if targets.wrappedValue.count < 3 {
                Button(action: {
                    withAnimation {
                        let newTarget = StrategySettings.Target(percentage: nil, allocation: nil)
                        targets.wrappedValue.append(newTarget)
                        focusedField = newTarget.id
                    }
                }) {
                    Label("Add Target", systemImage: "plus.circle.fill")
                        .foregroundColor(.accentColor)
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
    
    private func binding(for target: StrategySettings.Target, in targets: Binding<[StrategySettings.Target]>) -> Binding<StrategySettings.Target> {
        Binding<StrategySettings.Target>(
            get: {
                targets.wrappedValue.first { $0.id == target.id } ?? target
            },
            set: { newValue in
                if let index = targets.wrappedValue.firstIndex(where: { $0.id == target.id }) {
                    targets.wrappedValue[index] = newValue
                }
            }
        )
    }
    
    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Saved Strategies")
                .font(.title3)
                .fontWeight(.bold)
            
            Button("Default") {
                withAnimation {
                    settingsManager.currentSettings = .default
                    updateTotalAllocation()
                }
            }
            .buttonStyle(ModernButtonStyle())
            
            ForEach(settingsManager.savedSettings.indices, id: \.self) { index in
                HStack {
                    Button(settingsManager.savedSettings[index].name) {
                        withAnimation {
                            settingsManager.currentSettings = settingsManager.savedSettings[index]
                            updateTotalAllocation()
                        }
                    }
                    .buttonStyle(ModernButtonStyle())
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            settingsManager.deleteSavedSettings(at: index)
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.gray)
                    }
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
                        .fill(Color.accentColor)
                )
        }
        .padding(.horizontal, 20)
    }
    
    private func updateTotalAllocation() {
        totalAllocation = settingsManager.currentSettings.stopLossTargets.reduce(0) { $0 + ($1.allocation ?? 0) } +
        settingsManager.currentSettings.profitTakingTargets.reduce(0) { $0 + ($1.allocation ?? 0) }
    }
}

struct TargetRow: View {
    @Binding var target: StrategySettings.Target
    let isStopLoss: Bool
    @FocusState var focusedField: UUID?
    let onDelete: () -> Void
    let onUpdate: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var percentageString: String = ""
    @State private var allocationString: String = ""
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(isStopLoss ? "Loss" : "Gain")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack {
                    TextField("", text: $percentageString)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: target.id)
                        .onChange(of: percentageString) { newValue in
                            let filtered = newValue.filter { "0123456789.".contains($0) }
                            if filtered != newValue {
                                percentageString = filtered
                            }
                            if let value = Double(filtered) {
                                target.percentage = value
                            }
                            onUpdate()
                        }
                    Image(systemName: "percent")
                        .foregroundColor(.secondary)
                        .frame(width: 16, height: 16)
                }
                .padding()
                .background(Color.secondarySystemBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
            }
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Allocation")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack {
                
                    TextField("", text: $allocationString)
                        .keyboardType(.decimalPad)
                        .onChange(of: allocationString) { newValue in
                            let filtered = newValue.filter { "0123456789.".contains($0) }
                            if filtered != newValue {
                                allocationString = filtered
                            }
                            if let value = Double(filtered) {
                                target.allocation = value
                            }
                            onUpdate()
                        }
                    Image(systemName: "percent")
                        .foregroundColor(.secondary)
                        .frame(width: 16, height: 16)
                }
                .padding()
                .background(Color.secondarySystemBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
            }
            .frame(maxWidth: .infinity)
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.gray)
                    .imageScale(.large)
            }
            .frame(height: 44)
            .padding(.top, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.customBackground)
        )
        .onAppear {
            percentageString = target.percentage.map { String($0) } ?? ""
            allocationString = target.allocation.map { String($0) } ?? ""
        }
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

