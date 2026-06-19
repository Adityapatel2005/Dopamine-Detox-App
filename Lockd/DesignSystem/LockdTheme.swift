import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum LockdTheme {
    static let background = Color(.systemBackground)
    static let surface = Color(.secondarySystemGroupedBackground)
    static let elevatedSurface = Color(.tertiarySystemGroupedBackground)
    static let protectedGreen = Color(.systemGreen)
    static let riskOrange = Color(.systemOrange)
    static let insightBlue = Color(.systemBlue)
    static let primaryText = Color(.label)
    static let secondaryText = Color(.secondaryLabel)

    static let cornerRadius: CGFloat = 18
    static let compactRadius: CGFloat = 12
    static let minimumTouchTarget: CGFloat = 44
}
