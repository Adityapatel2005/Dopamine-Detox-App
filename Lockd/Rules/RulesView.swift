import SwiftUI

struct RulesView: View {
    @StateObject private var viewModel = RulesViewModel(screenTimeController: MockScreenTimeController(entitlementState: .proRequired))
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
        }
    }
}
