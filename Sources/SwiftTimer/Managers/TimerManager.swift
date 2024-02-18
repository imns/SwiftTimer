import Foundation
import Combine

@available(iOS 17.0, *)
@Observable public class TimerManager {
    public var currentTimer: TimerItem?
    var timerState: TimerState = .stopped
    public var remainingTime: TimeInterval?

    private var cancellables: Set<AnyCancellable> = []
    private var activeTimerSubscription: AnyCancellable?

    enum TimerState {
        case running, paused, stopped
    }
   
    func startTimer(_ timer: TimerItem, completion: @escaping () -> Void) {
        currentTimer = timer
        timerState = .running
        remainingTime = timer.duration

        activeTimerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let remainingTime = self.remainingTime, remainingTime > 0 else {
                    completion()  // Call the completion closure when the timer ends
                    return
                }
                self.onTick()
            }
    }
    
    private func onTick() {
        if let remainingTime = remainingTime, remainingTime > 0 {
            if timerState == .running {
                self.remainingTime = remainingTime - 1
            }
        } else {
            timerCompleted() // Call the completion handler when the timer finishes.
        }
    }

    func pauseTimer() {
        timerState = .paused
    }
    
    func resumeTimer() {
        timerState = .running
    }

    func stopTimer() {
        timerState = .stopped
        activeTimerSubscription?.cancel()
        currentTimer = nil
        remainingTime = 0
    }

    func timerCompleted() {
        // Handle timer completion
        // Move to next timer or stop
        // Cancel the scheduled local notification for the completed timer
    }
}
