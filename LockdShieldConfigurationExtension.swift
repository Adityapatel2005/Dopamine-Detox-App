import Foundation

#if canImport(FamilyControls) && canImport(ManagedSettingsUI) && canImport(UIKit)
import FamilyControls
import ManagedSettingsUI
import UIKit

final class LockdShieldConfigurationExtension: ShieldConfigurationDataSource {
    private let defaultTitle = "Protected by Lockd"
    private let defaultSecondaryButtonTitle = "Emergency unlock"
    private let rescueStore = ShieldRescueStore()

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        makeConfiguration()
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        makeConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfiguration()
    }

    private func makeConfiguration() -> ShieldConfiguration {
        let state = rescueStore.loadState()
        let copy = ShieldCopy.copy(for: state.mode)

        return ShieldConfiguration(
            backgroundBlurStyle: .systemChromeMaterialDark,
            backgroundColor: UIColor(red: 0.035, green: 0.039, blue: 0.047, alpha: 1),
            icon: UIImage(systemName: "lock.shield.fill"),
            title: ShieldConfiguration.Label(
                text: copy.title.isEmpty ? defaultTitle : copy.title,
                color: UIColor.white
            ),
            subtitle: ShieldConfiguration.Label(
                text: copy.subtitle,
                color: UIColor.white.withAlphaComponent(0.74)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: copy.primaryButtonTitle,
                color: UIColor.black
            ),
            primaryButtonBackgroundColor: UIColor(red: 0.42, green: 1.0, blue: 0.48, alpha: 1),
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: copy.secondaryButtonTitle.isEmpty ? defaultSecondaryButtonTitle : copy.secondaryButtonTitle,
                color: UIColor.white
            )
        )
    }
}
#endif
