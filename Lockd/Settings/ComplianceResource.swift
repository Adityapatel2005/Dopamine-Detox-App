import Foundation

enum ComplianceResource: String, CaseIterable, Identifiable {
    case privacyPolicy
    case termsOfService
    case privacyRights
    case deleteLocalData
    case accessibility
    case subscriptionTerms
    case medicalDisclaimer

    var id: String { rawValue }

    var title: String {
        switch self {
        case .privacyPolicy:
            return "Privacy Policy"
        case .termsOfService:
            return "Terms of Service"
        case .privacyRights:
            return "Privacy Rights"
        case .deleteLocalData:
            return "Delete Local Data"
        case .accessibility:
            return "Accessibility"
        case .subscriptionTerms:
            return "Subscription Terms"
        case .medicalDisclaimer:
            return "Medical Disclaimer"
        }
    }

    var subtitle: String {
        switch self {
        case .privacyPolicy:
            return "Lockd is local-first with no tracking or third-party analytics in this build."
        case .termsOfService:
            return "Use Lockd as a focus tool with Apple In-App Purchase for Pro."
        case .privacyRights:
            return "Review GDPR, California, access, correction, and deletion rights."
        case .deleteLocalData:
            return "Remove on-device focus history, rules, predictions, goals, and recap drafts."
        case .accessibility:
            return "Designed for VoiceOver, Dynamic Type, Reduced Motion, and 44 pt touch targets."
        case .subscriptionTerms:
            return "See pricing, trial, auto-renewal, restore, and cancellation terms before purchase."
        case .medicalDisclaimer:
            return "Lockd is not medical advice and does not diagnose or treat health conditions."
        }
    }

    var systemImage: String {
        switch self {
        case .privacyPolicy:
            return "lock.document"
        case .termsOfService:
            return "doc.text"
        case .privacyRights:
            return "person.text.rectangle"
        case .deleteLocalData:
            return "trash"
        case .accessibility:
            return "accessibility"
        case .subscriptionTerms:
            return "creditcard"
        case .medicalDisclaimer:
            return "cross.case"
        }
    }
}

enum ComplianceSection: String, CaseIterable, Identifiable {
    case privacyLegal
    case dataRights
    case accessSafety
    case subscription

    var id: String { rawValue }

    var title: String {
        switch self {
        case .privacyLegal:
            return "Privacy & Legal"
        case .dataRights:
            return "Data Rights"
        case .accessSafety:
            return "Access & Safety"
        case .subscription:
            return "Subscription"
        }
    }

    var resources: [ComplianceResource] {
        switch self {
        case .privacyLegal:
            return [.privacyPolicy, .termsOfService]
        case .dataRights:
            return [.privacyRights, .deleteLocalData]
        case .accessSafety:
            return [.accessibility, .medicalDisclaimer]
        case .subscription:
            return [.subscriptionTerms]
        }
    }
}
