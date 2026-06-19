import Foundation
import Combine

#if canImport(StoreKit)
import StoreKit
#endif

@MainActor
final class StoreKitSubscriptionController: ObservableObject {
    @Published private(set) var availablePlans = LockdProductCatalog.fallbackPlans
    @Published private(set) var entitlement: LockdProEntitlement = .free
    @Published private(set) var purchaseState: StoreKitPurchaseState = .idle

    #if canImport(StoreKit)
    private var products: [Product] = []
    #endif

    func loadProducts() async {
        #if canImport(StoreKit)
        purchaseState = .loading
        do {
            products = try await Product.products(for: LockdProductCatalog.productIdentifiers)
            availablePlans = products
                .sorted { $0.price < $1.price }
                .map { product in
                    LockdSubscriptionPlan(
                        id: product.id,
                        title: product.displayName,
                        displayPrice: product.displayPrice,
                        subtitle: product.id == LockdProductCatalog.yearlyProductID ? "Best for Monk Mode." : "Flexible monthly protection.",
                        isBestValue: product.id == LockdProductCatalog.yearlyProductID
                    )
                }
            await refreshCurrentEntitlements()
            purchaseState = .idle
        } catch {
            availablePlans = LockdProductCatalog.fallbackPlans
            purchaseState = .failed("Unable to load StoreKit 2 products.")
        }
        #else
        purchaseState = .unavailable
        #endif
    }

    func purchase(planID: String) async {
        #if canImport(StoreKit)
        guard let product = products.first(where: { $0.id == planID }) else {
            purchaseState = .failed("This subscription is not available yet.")
            return
        }

        purchaseState = .loading

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try verifiedTransaction(from: verification)
                entitlement = .pro(expirationDate: transaction.expirationDate)
                await transaction.finish()
                purchaseState = .purchased
            case .pending:
                purchaseState = .pending
            case .userCancelled:
                purchaseState = .cancelled
            @unknown default:
                purchaseState = .failed("StoreKit returned an unknown purchase state.")
            }
        } catch {
            purchaseState = .failed("Purchase could not be completed.")
        }
        #else
        purchaseState = .unavailable
        #endif
    }

    func restorePurchases() async {
        #if canImport(StoreKit)
        purchaseState = .loading
        do {
            try await AppStore.sync()
            await refreshCurrentEntitlements()
            purchaseState = entitlement.unlocksAdvancedInsights ? .purchased : .idle
        } catch {
            purchaseState = .failed("Restore could not be completed.")
        }
        #else
        purchaseState = .unavailable
        #endif
    }

    func refreshCurrentEntitlements() async {
        #if canImport(StoreKit)
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? verifiedTransaction(from: result),
                  LockdProductCatalog.productIdentifiers.contains(transaction.productID) else {
                continue
            }
            entitlement = .pro(expirationDate: transaction.expirationDate)
            return
        }

        entitlement = .free
        #endif
    }

    #if canImport(StoreKit)
    private func verifiedTransaction(from result: VerificationResult<Transaction>) throws -> Transaction {
        switch result {
        case .verified(let transaction):
            return transaction
        case .unverified:
            throw StoreKitSubscriptionError.unverifiedTransaction
        }
    }
    #endif
}

enum StoreKitSubscriptionError: Error {
    case unverifiedTransaction
}
