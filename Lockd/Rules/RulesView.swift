import SwiftUI

#if canImport(FamilyControls)
import FamilyControls
#endif

struct RulesView: View {
    @StateObject private var viewModel = RulesViewModel(screenTimeController: RealScreenTimeController())
    #if canImport(FamilyControls)
    @State private var isShowingFamilyActivityPicker = false
    @State private var familyActivitySelection = FamilyActivitySelection()
    #endif

    private let sampleApps = [
        DistractingApp(name: "TikTok", symbolName: "music.note"),
        DistractingApp(name: "Instagram", symbolName: "camera"),
        DistractingApp(name: "YouTube", symbolName: "play.rectangle"),
        DistractingApp(name: "Reddit", symbolName: "bubble.left.and.bubble.right"),
        DistractingApp(name: "Safari", symbolName: "safari")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LockdTheme.background.ignoresSafeArea()
                List {
                    Section("Distracting apps") {
                        ForEach(sampleApps) { app in
                            Button {
                                viewModel.chooseApp(app)
                            } label: {
                                Label(app.name, systemImage: app.symbolName)
                            }
                            .foregroundStyle(LockdTheme.primaryText)
                        }
                    }

                    Section("Screen Time selection") {
                        #if canImport(FamilyControls)
                        Button {
                            isShowingFamilyActivityPicker = true
                        } label: {
                            Label("Choose apps with Screen Time", systemImage: "lock.shield")
                        }
                        .foregroundStyle(LockdTheme.primaryText)

                        Button {
                            viewModel.saveFamilyActivitySelection(familyActivitySelection)
                        } label: {
                            Label("Save Screen Time selection", systemImage: "checkmark.shield")
                        }
                        .foregroundStyle(LockdTheme.protectedGreen)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(viewModel.selectionState.totalSelectionCount) protected items")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(LockdTheme.primaryText)
                            Text(viewModel.selectionMessage)
                                .font(.footnote)
                                .foregroundStyle(LockdTheme.secondaryText)
                        }
                        .padding(.vertical, 4)
                        #else
                        Text("FamilyActivityPicker requires a real iOS build with Family Controls.")
                            .foregroundStyle(LockdTheme.secondaryText)
                        #endif
                    }

                    Section("Goal") {
                        Picker("Goal", selection: Binding(get: { viewModel.goal }, set: { viewModel.setGoal($0) })) {
                            ForEach(GoalPreset.allCases) { goal in
                                Text(goal.rawValue).tag(goal)
                            }
                        }
                    }

                    Section("Protection") {
                        Picker("Friction", selection: Binding(get: { viewModel.frictionLevel }, set: { viewModel.setFrictionLevel($0) })) {
                            ForEach(FrictionLevel.allCases) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                        Button("Enable Predictive Protection") {
                            viewModel.enablePredictiveProtection()
                        }
                        Text("Predictive Protection requires Pro in this mock build.")
                            .foregroundStyle(LockdTheme.secondaryText)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Rules")
            #if canImport(FamilyControls)
            .familyActivityPicker(isPresented: $isShowingFamilyActivityPicker, selection: $familyActivitySelection)
            .onAppear {
                familyActivitySelection = viewModel.loadFamilyActivitySelection()
            }
            #endif
        }
    }
}
