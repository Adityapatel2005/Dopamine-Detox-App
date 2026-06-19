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

                    Section("Privacy & Legal") {
                        complianceRow(.privacyPolicy)
                        complianceRow(.termsOfService)
                        complianceRow(.privacyRights)
                        complianceRow(.deleteLocalData)
                    }

                    Section("Access & Safety") {
                        complianceRow(.accessibility)
                        complianceRow(.medicalDisclaimer)
                    }

                    Section("Subscription") {
                        complianceRow(.subscriptionTerms)
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
