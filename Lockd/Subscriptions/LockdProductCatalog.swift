import Foundation

enum LockdProductCatalog {
    static let monthlyProductID = "com.lockd.pro.monthly"
    static let yearlyProductID = "com.lockd.pro.yearly"

    static let productIdentifiers: Set<String> = [
        monthlyProductID,
        yearlyProductID
    ]

    static let fallbackPlans = [
        LockdSubscriptionPlan(
            id: yearlyProductID,
            title: "Lockd Pro Yearly",
            displayPrice: "$39.99 / year",
            subtitle: "7-day trial, best for monk mode and serious resets.",
            isBestValue: true
        ),
        LockdSubscriptionPlan(
            id: monthlyProductID,
            title: "Lockd Pro Monthly",
            displayPrice: "$5.99 / month",
            subtitle: "Flexible protection with advanced insights.",
            isBestValue: false
        )
    ]
}
