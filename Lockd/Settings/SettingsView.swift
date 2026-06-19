import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var phaseOneViewModel = PhaseOneSettingsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                LockdTheme.background.ignoresSafeArea()
                List {
                    Section("Protection") {
                        Label("Screen Time access is mocked in this build", systemImage: "shield.lefthalf.filled")
                        Label("Family Controls entitlement comes before release", systemImage: "checkmark.seal")
                    }

                    Section("iPhone Setup") {
                        statusRow(
                            title: "Screen Time",
                            status: phaseOneViewModel.settings.permissionSnapshot.screenTime,
                            systemImage: "hourglass"
                        )
                        Button {
                            Task {
                                await phaseOneViewModel.requestScreenTimeAuthorization()
                            }
                        } label: {
                            Label("Request Screen Time Access", systemImage: "person.crop.circle.badge.checkmark")
                        }

                        statusRow(
                            title: "Notifications",
                            status: phaseOneViewModel.settings.permissionSnapshot.notifications,
                            systemImage: "bell.badge"
                        )
                        Button {
                            Task {
                                await phaseOneViewModel.requestNotificationAuthorization()
                            }
                        } label: {
                            Label("Request Notification Access", systemImage: "bell.badge.fill")
                        }
                    }

                    Section("Lock Defaults") {
                        Stepper(
                            value: Binding(
                                get: { phaseOneViewModel.settings.defaultLockDurationMinutes },
                                set: { phaseOneViewModel.setDefaultLockDuration($0) }
                            ),
                            in: 5...180,
                            step: 5
                        ) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Default duration")
                                Text("\(phaseOneViewModel.settings.defaultLockDurationMinutes) minutes")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Toggle("Hard block", isOn: Binding(
                            get: { phaseOneViewModel.settings.hardBlockEnabled },
                            set: { phaseOneViewModel.setHardBlockEnabled($0) }
                        ))

                        Toggle("Predictive Protection", isOn: Binding(
                            get: { phaseOneViewModel.settings.predictiveProtectionEnabled },
                            set: { phaseOneViewModel.setPredictiveProtectionEnabled($0) }
                        ))
                    }

                    Section("Notifications") {
                        ForEach(LockdNotificationKind.allCases) { kind in
                            notificationRow(kind)
                        }
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

                    if let saveErrorMessage = phaseOneViewModel.saveErrorMessage {
                        Section("Local Data") {
                            Text(saveErrorMessage)
                                .foregroundStyle(LockdTheme.riskOrange)
                            Button(role: .destructive) {
                                phaseOneViewModel.resetLocalSettings()
                            } label: {
                                Label("Reset Local Settings", systemImage: "arrow.counterclockwise")
                            }
                        }
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

    private func statusRow(title: String, status: LockdPermissionStatus, systemImage: String) -> some View {
        Label {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                Text(status.displayName)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: systemImage)
        }
        .accessibilityElement(children: .combine)
    }

    private func notificationRow(_ kind: LockdNotificationKind) -> some View {
        Toggle(isOn: Binding(
            get: { phaseOneViewModel.isNotificationEnabled(kind) },
            set: { phaseOneViewModel.toggleNotification(kind, isEnabled: $0) }
        )) {
            VStack(alignment: .leading, spacing: 4) {
                Text(kind.title)
                Text(kind.defaultBody)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
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
