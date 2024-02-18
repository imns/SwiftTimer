import Foundation

let backgroundTimestampKey = "backgroundTimestampKey"

struct TimersState: Codable {
    var activeTimerID: UUID?
    var timers: [TimerItem]
    var backgroundTimestamp: TimeInterval? {
        get {
            UserDefaults.standard.double(forKey: backgroundTimestampKey)
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: backgroundTimestampKey)
            } else {
                UserDefaults.standard.removeObject(forKey: backgroundTimestampKey)
            }
        }
    }
    
    init(activeTimerID: UUID? = nil, timers: [TimerItem]) {
        self.activeTimerID = activeTimerID
        self.timers = timers
        self.backgroundTimestamp = nil
    }
   
}
