import Foundation
import Combine
import UserNotifications


@available(iOS 17.0, *)
public class TimerSequence {
    public static let shared = TimerSequence()
    
    public let timerManager = TimerManager()
    private var notificationManager = NotificationManager.shared
    
    public var current: Double  {
        Double(timerManager.remainingTime ?? 0.0)
    }
    
    private(set) var currentState: TimersState {
        didSet {
            // TODO: Should persist the state somehow?
        }
    }
    
    var currentActiveTimer: TimerItem? {
        currentState.timers.first { $0.id == currentState.activeTimerID }
    }
    
    public init() {
        currentState = TimersState(
            activeTimerID: nil,
            timers: []
        )
    }
    
    func addTimer(_ timer: TimerItem) {
        currentState.timers.append(timer)
    }
    
    public func addTimer(duration: TimeInterval, category: String, title: String) {
        var timerModel = TimerItem(duration: duration, category: category, title: title)
        self.addTimer(timerModel)
    }

    public func startTimer() {
        guard let firstTimer = currentState.timers.first else { return }
        currentState.activeTimerID = firstTimer.id
        timerManager.startTimer(firstTimer) {
            self.transitionToNextTimer()
        }
       
    }

    func startTimer(_ timer: TimerItem) {
        currentState.activeTimerID = timer.id
        timerManager.startTimer(timer) {
            self.transitionToNextTimer()
        }
    }
    
    public func pauseTimer() {
        timerManager.pauseTimer()
    }

    public func resumeTimer() {
        timerManager.resumeTimer()
    }
    
    public func stopTimer() {
        timerManager.stopTimer()
        // Invalidate the current timer, clear the active timer ID
        currentState.activeTimerID = nil
    }
    
    func updateTimer(for id: UUID, duration: TimeInterval? = nil, title: String? = nil, category: String? = nil, completed: Bool? = nil) {
        if let index = currentState.timers.firstIndex(where: { $0.id == id }) {
            var timer = currentState.timers[index]
            if let duration = duration {
                timer.duration = duration
            }
            if let title = title {
                timer.title = title
            }
            if let category = category {
                timer.category = category
            }
            if let completed = completed {
                timer.completed = completed
            }
            currentState.timers[index] = timer
        }
    }

    func removeTimer(_ id: UUID) {
        currentState.timers.removeAll { $0.id == id }
    }

    func transitionToNextTimer() {
        if let currentIndex = currentState.timers.firstIndex(where: { $0.id == currentState.activeTimerID }), currentIndex < currentState.timers.count - 1 {
            // Set the current timers completed flag
            currentState.timers[currentIndex].completed = true
            // Start the next Timer
            let nextTimer = currentState.timers[currentIndex + 1]
            startTimer(nextTimer)
        } else {
            // No more timers, handle completion
            timerManager.stopTimer()
        }
    }
    
    func serialize(_ timerItem: TimerItem) -> Data? {
        try? JSONEncoder().encode(currentState)
    }

    func deserialize(from data: Data) -> TimersState? {
        try? JSONDecoder().decode(TimersState.self, from: data)
    }

    func appMovedToBackground() {
        // Assuming `currentState.timers` contains all the timers in sequence
        var cumulativeDuration: TimeInterval = 0

        for timer in currentState.timers where !timer.completed {
            cumulativeDuration += timer.duration
            notificationManager.scheduleNotification(for: timer, delay: cumulativeDuration)
        }
    }

    func appBecameActive() {
        // Cancel all scheduled notifications as the first step
        notificationManager.cancelAllNotifications()
    
        guard let backgroundTimestamp = currentState.backgroundTimestamp else { return }
        let elapsedTime = Date().timeIntervalSince1970 - backgroundTimestamp
        
        // Logic to adjust timers based on elapsed time
        adjustTimersBasedOnElapsedTime(elapsedTime)
        
        currentState.backgroundTimestamp = nil // Clear the timestamp
    }
    
    // TODO: This should cancel any pending notifications
    private func adjustTimersBasedOnElapsedTime(_ elapsedTime: TimeInterval) {
        var elapsedTimeRemaining = elapsedTime
        var updatedTimers: [TimerItem] = []
        var activeTimerFound = false

        for timer in currentState.timers {
            if elapsedTimeRemaining <= 0 || activeTimerFound {
                updatedTimers.append(timer)
                continue
            }

            if let activeTimerID = currentState.activeTimerID, timer.id == activeTimerID || currentState.activeTimerID == nil {
                if elapsedTimeRemaining < timer.duration {
                    var adjustedTimer = timer
                    adjustedTimer.duration -= elapsedTimeRemaining
                    updatedTimers.append(adjustedTimer)
                    currentState.activeTimerID = adjustedTimer.id
                    activeTimerFound = true
                } else {
                    elapsedTimeRemaining -= timer.duration
                }
            }
        }

        currentState.timers = updatedTimers
        if !activeTimerFound && !currentState.timers.isEmpty {
            // This case handles if the app was in background longer than the total duration of all timers
            currentState.activeTimerID = nil
        }
    }
}
