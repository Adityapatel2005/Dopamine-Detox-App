import Foundation

struct WeakSpotPredictor {
    func predictNextWindow(from signals: [WeakSpotSignal]) -> WeakSpotWindow {
        guard !signals.isEmpty else {
            return WeakSpotWindow(
                hour: 21,
                riskLevel: .learning,
                explanation: "Lockd needs a few more sessions before it can predict a weak spot."
            )
        }

        let groupedByHour = Dictionary(grouping: signals, by: \.hour)
        let ranked = groupedByHour
            .map { hour, hourSignals in
                (hour: hour, score: riskScore(for: hourSignals), count: hourSignals.count)
            }
            .sorted { lhs, rhs in
                if lhs.score == rhs.score {
                    return lhs.count > rhs.count
                }
                return lhs.score > rhs.score
            }

        guard let strongest = ranked.first else {
            return WeakSpotWindow(hour: 21, riskLevel: .learning, explanation: "Lockd is still learning your pattern.")
        }

        return WeakSpotWindow(
            hour: strongest.hour,
            riskLevel: riskLevel(for: strongest.score),
            explanation: "Your highest-risk pattern clusters around \(formattedHour(strongest.hour))."
        )
    }

    private func riskScore(for signals: [WeakSpotSignal]) -> Int {
        signals.reduce(0) { partial, signal in
            switch signal.outcome {
            case .openedDistractingApp:
                return partial + 4
            case .softFrictionIgnored:
                return partial + 3
            case .sessionInterrupted:
                return partial + 2
            case .sessionCompleted:
                return partial - 1
            }
        }
    }

    private func riskLevel(for score: Int) -> RiskLevel {
        switch score {
        case 8...:
            return .high
        case 4...7:
            return .medium
        case 1...3:
            return .low
        default:
            return .learning
        }
    }

    private func formattedHour(_ hour: Int) -> String {
        let normalized = ((hour % 24) + 24) % 24
        let suffix = normalized >= 12 ? "PM" : "AM"
        let twelveHour = normalized % 12 == 0 ? 12 : normalized % 12
        return "\(twelveHour):00 \(suffix)"
    }
}
