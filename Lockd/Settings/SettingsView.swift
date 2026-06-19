import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LockdTheme.background.ignoresSafeArea()
                List {
                    Section("Protection") {
                        Label("Screen Time access is mocked in this build", systemImage: "shield.lefthalf.filled")
                        Label("Family Controls entitlement comes before release", systemImage: "checkmark.seal")
                    }

                    Section("Policies & Compliance") {
                        NavigationLink {
                            ComplianceCenterView()
                        } label: {
                            Label {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Policies & Compliance")
                                    Text("Privacy, terms, data rights, accessibility, subscriptions, and safety.")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            } icon: {
                                Image(systemName: "doc.text.magnifyingglass")
                            }
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .toolbar {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct ComplianceCenterView: View {
    var body: some View {
        ZStack {
            LockdTheme.background.ignoresSafeArea()
            List {
                ForEach(ComplianceSection.allCases) { section in
                    Section(section.title) {
                        ForEach(section.resources) { resource in
                            complianceRow(resource)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Policies")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }

    private func complianceRow(_ resource: ComplianceResource) -> some View {
        Label {
            VStack(alignment: .leading, spacing: 4) {
                Text(resource.title)
                Text(resource.subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: resource.systemImage)
        }
        .accessibilityElement(children: .combine)
    }
}
