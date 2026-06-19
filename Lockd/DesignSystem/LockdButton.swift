import SwiftUI
#if os(iOS)
import UIKit
#endif

enum LockdButtonStyle: Equatable {
    case primary
    case secondary
    case warning
}

struct LockdButton: View {
    let title: String
    let systemImage: String
    let style: LockdButtonStyle
    let isLoading: Bool
    let accessibilityHint: String?
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false

    init(
        _ title: String,
        systemImage: String,
        style: LockdButtonStyle = .primary,
        isLoading: Bool = false,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.isLoading = isLoading
        self.accessibilityHint = accessibilityHint
        self.action = action
    }

    var body: some View {
        Button {
            triggerHaptic()
            action()
        } label: {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(foreground)
                } else {
                    Image(systemName: systemImage)
                }

                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, minHeight: LockdTheme.minimumTouchTarget)
            .padding(.vertical, 6)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: LockdTheme.compactRadius, style: .continuous))
            .scaleEffect(isPressed && !reduceMotion ? 0.97 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .animation(reduceMotion ? nil : .spring(response: 0.16, dampingFraction: 0.72), value: isPressed)
        .accessibilityLabel(title)
        .accessibilityHint(Text(accessibilityHint ?? "Activates \(title)."))
    }

    private func triggerHaptic() {
        #if os(iOS)
        if style == .primary {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        #endif
    }

    private var foreground: Color {
        switch style {
        case .primary:
            return .black
        case .secondary, .warning:
            return .white
        }
    }

    private var background: Color {
        switch style {
        case .primary:
            return LockdTheme.protectedGreen
        case .secondary:
            return LockdTheme.elevatedSurface
        case .warning:
            return LockdTheme.riskOrange
        }
    }
}
