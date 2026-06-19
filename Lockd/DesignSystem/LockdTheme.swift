import SwiftUI

enum LockdTheme {
    static let background = Color(red: 0.035, green: 0.039, blue: 0.047)
    static let surface = Color(red: 0.075, green: 0.082, blue: 0.096)
    static let elevatedSurface = Color(red: 0.105, green: 0.113, blue: 0.133)
    static let protectedGreen = Color(red: 0.42, green: 1.0, blue: 0.48)
    static let riskOrange = Color(red: 1.0, green: 0.42, blue: 0.18)
    static let insightBlue = Color(red: 0.27, green: 0.58, blue: 1.0)
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.68)

    static let cornerRadius: CGFloat = 18
    static let compactRadius: CGFloat = 12
    static let minimumTouchTarget: CGFloat = 44
}
