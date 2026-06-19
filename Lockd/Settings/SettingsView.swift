import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var phaseOneViewModel = PhaseOneSettingsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                LockdTheme.background.ignoresSafeArea()
                List {
                    Section("iPhone Setup") {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Why Lockd needs Screen Time")
                                .font(.subheadline.weight(.semibold))
                            Text("Lockd uses Apple's Screen Time and Family Controls permission to block only the apps you select while a lock-in is active.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                        .accessibilityElement(children: .combine)

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
                        .accessibilityHint("Opens Apple's Screen Time permission request for Lockd.")

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
                        .accessibilityHint("Opens Apple's notification permission request for Lockd reminders.")

                        Button {
                            openAppSettings()
                        } label: {
                            Label("Open iPhone Settings", systemImage: "gearshape")
                        }
                        .accessibilityHint("Opens the Lockd page in iPhone Settings to review permissions.")
                    }

                    Section("Protection Defaults") {
                        settingsSummaryRow(
                            title: "Screen Time app blocking",
                            subtitle: "Protects the apps, categories, and websites selected in Apple's picker.",
                            systemImage: "shield.lefthalf.filled"
                        )

                        settingsSummaryRow(
                            title: "Private app selections",
                            subtitle: "Family Controls stores opaque tokens, not readable app lists.",
                            systemImage: "checkmark.seal"
                        )

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

                    Section("Notification Preferences") {
                        ForEach(LockdNotificationKind.allCases) { kind in
                            notificationRow(kind)
                        }
                    }

                    Section("Account & Legal") {
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

                        settingsSummaryRow(
                            title: "Subscription & purchases",
                            subtitle: "Lockd Pro purchases and restore flows are handled through Apple's App Store system.",
                            systemImage: "creditcard"
                        )

                        if let saveErrorMessage = phaseOneViewModel.saveErrorMessage {
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
    }

    private func openAppSettings() {
        #if canImport(UIKit)
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
        #endif
    }

    private func settingsSummaryRow(title: String, subtitle: String, systemImage: String) -> some View {
        Label {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: systemImage)
        }
        .accessibilityElement(children: .combine)
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
