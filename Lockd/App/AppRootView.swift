import SwiftUI

struct AppRootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasUnlockedPro") private var hasUnlockedPro = false
    @StateObject private var storeKitController = StoreKitSubscriptionController()

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            } else if hasUnlockedPro || storeKitController.entitlement.unlocksAdvancedInsights {
                MainTabView()
            } else {
                PaywallView(storeKitController: storeKitController, allowsDismissal: false, onPurchased: {
                    hasUnlockedPro = true
                })
            }
        }
        .task {
            await storeKitController.refreshCurrentEntitlements()
            hasUnlockedPro = storeKitController.entitlement.unlocksAdvancedInsights
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "lock.shield")
                }

            RulesView()
                .tabItem {
                    Label("Rules", systemImage: "slider.horizontal.3")
                }

            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
                }
        }
        .tint(LockdTheme.protectedGreen)
    }
}
