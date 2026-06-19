import Foundation

#if canImport(DeviceActivity)
import DeviceActivity
#endif

struct LockdDeviceActivityScheduleRequest: Equatable {
    let startDate: Date
    let endDate: Date

    init(startDate: Date = Date(), durationMinutes: Int) {
        self.startDate = startDate
        self.endDate = Calendar.current.date(byAdding: .minute, value: durationMinutes, to: startDate) ?? startDate
    }
}

enum DeviceActivityScheduleControllerError: Error {
    case unavailable
}

struct DeviceActivityScheduleController {
    func startMonitoring(_ request: LockdDeviceActivityScheduleRequest) throws {
        #if canImport(DeviceActivity)
        let calendar = Calendar.current
        let start = calendar.dateComponents([.hour, .minute], from: request.startDate)
        let end = calendar.dateComponents([.hour, .minute], from: request.endDate)
        let schedule = DeviceActivitySchedule(intervalStart: start, intervalEnd: end, repeats: false)
        try DeviceActivityCenter().startMonitoring(.lockdActiveSession, during: schedule)
        #else
        throw DeviceActivityScheduleControllerError.unavailable
        #endif
    }

    func stopMonitoring() {
        #if canImport(DeviceActivity)
        DeviceActivityCenter().stopMonitoring([.lockdActiveSession])
        #endif
    }
}

#if canImport(DeviceActivity)
extension DeviceActivityName {
    static let lockdActiveSession = Self("lockd.activeSession")
}
#endif
