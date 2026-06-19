import Foundation

struct WeakSpotPredictor {
    func predict(signals: [WeakSpotSignal], now: Date = Date()) -> WeakSpotWindow {
        guard !signals.isEmpty else {
            return WeakSpotWindow(
                hour: Calendar.current.component(.hour, from: now),
                riskLevel: .learning,
                explanation: "Lockd will learn your pattern after 2 days."
            )
        }

        let grouped = Dictionary(grouping: signals) { $0.hour }
        let strongest = grouped.max { left, right in
            riskScore(left.value) < riskScore(right.value)
        }

        guard let hour = strongest?.key, let hourSignals = strongest?.value else {
            return WeakSpotWindow(
                hour: Calendar.current.component(.hour, from: now),
                riskLevel: .low,
                explanation: "No strong drift window found yet."
            )
        }

        let score = riskScore(hourSignals)
        let riskLevel: RiskLevel
        if score >= 5 {
            riskLevel = .high
        } else if score >= 3 {
            riskLevel = .medium
        } else {
            riskLevel = .low
        }

        let topApp = Dictionary(grouping: hourSignals) { $0.appName }
            .max { $0.value.count < $1.value.count }?
            .key ?? "distracting apps"

        return WeakSpotWindow(
            hour: hour,
            riskLevel: riskLevel,
            explanation: "\(topApp) opens usually spike here."
        )
    }

    private func riskScore(_ signals: [WeakSpotSignal]) -> Int {
        signals.reduce(0) { total, signal in
            switch signal.outcome {
            case .openedDistractingApp:
                return total + 2
            case .softFrictionIgnored:
                return total + 2
            case .sessionInterrupted:
                return total + 1
            case .sessionCompleted:
                return total - 1
            }
        }
    }
}
