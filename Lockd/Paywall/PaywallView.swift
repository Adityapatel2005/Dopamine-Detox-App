import SwiftUI

struct PaywallView: View {
    let allowsDismissal: Bool
    let onPurchased: () -> Void
    let onClose: () -> Void
    @ObservedObject private var storeKitController: StoreKitSubscriptionController

    init(
        storeKitController: StoreKitSubscriptionController = StoreKitSubscriptionController(),
        allowsDismissal: Bool = true,
        onPurchased: @escaping () -> Void = {},
        onClose: @escaping () -> Void = {}
    ) {
        _storeKitController = ObservedObject(wrappedValue: storeKitController)
        self.allowsDismissal = allowsDismissal
        self.onPurchased = onPurchased
        self.onClose = onClose
    }

    var body: some View {
        ZStack {
            LockdTheme.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 18) {
                Text("Your Lockd plan is ready")
                    .font(.largeTitle.bold())
                    .foregroundStyle(LockdTheme.primaryText)
                Text("Start with 7 days free. Then Lockd protects selected apps, weak spots, schedules, insight cards, rescue mode, and recap cards with one subscription.")
                    .foregroundStyle(LockdTheme.secondaryText)

                ForEach(storeKitController.availablePlans) { plan in
                    pricing(plan)
                }

                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(LockdTheme.secondaryText)

                LockdButton(
                    "Start 7-day trial",
                    systemImage: "lock.open.fill",
                    isLoading: storeKitController.purchaseState == .loading,
                    accessibilityHint: "Starts the 7-day Lockd trial using the best-value plan."
                ) {
                    guard let plan = storeKitController.availablePlans.first(where: { $0.id == LockdProductCatalog.yearlyProductID }) else { return }
                    Task {
                        await storeKitController.purchase(planID: plan.id)
                    }
                }
                LockdButton(
                    "Restore Purchases",
                    systemImage: "arrow.clockwise",
                    style: .secondary,
                    isLoading: storeKitController.purchaseState == .loading,
                    accessibilityHint: "Checks App Store purchases and restores Lockd Pro if available."
                ) {
                    Task {
                        await storeKitController.restorePurchases()
                    }
                }
                Text("7 days free, then your selected App Store plan renews automatically unless cancelled at least 24 hours before renewal.")
                    .font(.caption)
                    .foregroundStyle(LockdTheme.secondaryText)

                if allowsDismissal {
                    Button("Close", action: onClose)
                        .foregroundStyle(LockdTheme.secondaryText)
                        .frame(maxWidth: .infinity, minHeight: LockdTheme.minimumTouchTarget)
                        .accessibilityHint("Closes the subscription screen.")
                }
            }
            .padding(24)
        }
        .task {
            await storeKitController.loadProducts()
        }
        .onChange(of: storeKitController.purchaseState) { newValue in
            if newValue == .purchased {
                onPurchased()
            }
        }
    }

    private func pricing(_ plan: LockdSubscriptionPlan) -> some View {
        Button {
            Task {
                await storeKitController.purchase(planID: plan.id)
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(plan.displayPrice)
                        .font(.headline)
                        .foregroundStyle(LockdTheme.primaryText)
                    Spacer()
                    if plan.isBestValue {
                        Text("Best value")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(LockdTheme.protectedGreen)
                            .clipShape(Capsule())
                    }
                }
                Text(plan.title)
                    .font(.headline)
                    .foregroundStyle(LockdTheme.primaryText)
                Text(plan.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(LockdTheme.secondaryText)
                Text(plan.isBestValue ? "7 days free, then yearly billing." : "7 days free, then monthly billing.")
                    .font(.caption)
                    .foregroundStyle(LockdTheme.secondaryText)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LockdTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: LockdTheme.cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(storeKitController.purchaseState == .loading)
        .accessibilityLabel("\(plan.title), \(plan.displayPrice)")
        .accessibilityValue(plan.subtitle)
        .accessibilityHint("Purchases this Lockd Pro subscription plan.")
    }

    private var statusMessage: String {
        switch storeKitController.purchaseState {
        case .idle:
            return "StoreKit 2 products load from App Store Connect on device."
        case .loading:
            return "Contacting StoreKit."
        case .purchased:
            return "Lockd Pro is active."
        case .pending:
            return "Purchase is pending approval."
        case .cancelled:
            return "Purchase cancelled."
        case .failed(let message):
            return message
        case .unavailable:
            return "StoreKit is unavailable in this preview build."
        }
    }
}
