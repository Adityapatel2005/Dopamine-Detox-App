import SwiftUI

struct PaywallView: View {
    let onClose: () -> Void
    @StateObject private var storeKitController = StoreKitSubscriptionController()

    var body: some View {
        ZStack {
            LockdTheme.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 18) {
                Text("Unlock Predictive Protection")
                    .font(.largeTitle.bold())
                    .foregroundStyle(LockdTheme.primaryText)
                Text("Automatic weak-spot detection, unlimited lock-ins, advanced schedules, weekly insight cards, premium recap cards, and challenge packs.")
                    .foregroundStyle(LockdTheme.secondaryText)

                ForEach(storeKitController.availablePlans) { plan in
                    pricing(plan)
                        .onTapGesture {
                            Task {
                                await storeKitController.purchase(planID: plan.id)
                            }
                        }
                }

                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(LockdTheme.secondaryText)

                LockdButton("Start 7-day trial", systemImage: "lock.open.fill", isLoading: storeKitController.purchaseState == .loading) {
                    guard let plan = storeKitController.availablePlans.first(where: { $0.id == LockdProductCatalog.yearlyProductID }) else { return }
                    Task {
                        await storeKitController.purchase(planID: plan.id)
                    }
                }
                LockdButton("Restore Purchases", systemImage: "arrow.clockwise", style: .secondary, isLoading: storeKitController.purchaseState == .loading) {
                    Task {
                        await storeKitController.restorePurchases()
                    }
                }
                Button("Maybe later", action: onClose)
                    .foregroundStyle(LockdTheme.secondaryText)
                    .frame(maxWidth: .infinity, minHeight: LockdTheme.minimumTouchTarget)
            }
            .padding(24)
        }
        .task {
            await storeKitController.loadProducts()
        }
    }

    private func pricing(_ plan: LockdSubscriptionPlan) -> some View {
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
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LockdTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: LockdTheme.cornerRadius, style: .continuous))
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
