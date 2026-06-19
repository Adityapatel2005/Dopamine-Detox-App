import Foundation

protocol AppSettingsStoring: AnyObject {
    func load() -> LockdAppSettings
    func save(_ settings: LockdAppSettings) throws
    func reset() throws
}

enum AppSettingsStoreError: Error, Equatable {
    case encodingFailed
}

final class UserDefaultsAppSettingsStore: AppSettingsStoring {
    private let userDefaults: UserDefaults
    private let key: String
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        userDefaults: UserDefaults = .standard,
        key: String = "lockd.phase1.appSettings"
    ) {
        self.userDefaults = userDefaults
        self.key = key
    }

    func load() -> LockdAppSettings {
        guard let data = userDefaults.data(forKey: key),
              let settings = try? decoder.decode(LockdAppSettings.self, from: data) else {
            return .defaults
        }
        return settings
    }

    func save(_ settings: LockdAppSettings) throws {
        var settingsToSave = settings
        settingsToSave.lastSavedAt = Date()
        guard let data = try? encoder.encode(settingsToSave) else {
            throw AppSettingsStoreError.encodingFailed
        }
        userDefaults.set(data, forKey: key)
    }

    func reset() throws {
        userDefaults.removeObject(forKey: key)
    }
}

final class InMemoryAppSettingsStore: AppSettingsStoring {
    private var settings: LockdAppSettings

    init(settings: LockdAppSettings = .defaults) {
        self.settings = settings
    }

    func load() -> LockdAppSettings {
        settings
    }

    func save(_ settings: LockdAppSettings) throws {
        self.settings = settings
    }

    func reset() throws {
        settings = .defaults
    }
}
