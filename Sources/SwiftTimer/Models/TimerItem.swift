import Foundation

public struct TimerItem: Identifiable, Codable {
    public var id: UUID = UUID()
    var duration: TimeInterval // Duration in seconds
    public var category: String // A generic category or tag for the timer
    public var title: String // A title for the timer, for display purposes
    var completed: Bool = false // Indicates whether the timer is completed or not
    
    init(duration: TimeInterval, category: String, title: String) {
        self.duration = duration
        self.category = category
        self.title = title
    }
    
    mutating func updateTimer(
        duration: TimeInterval? = nil,
        title: String? = nil,
        category: String? = nil,
        completed: Bool? = nil) {
        
        if let duration = duration {
            self.duration = duration
        }
        if let title = title {
            self.title = title
        }
        if let category = category {
            self.category = category
        }
        if let completed = completed {
            self.completed = completed
        }
    }
    
    /*
     Example usage
     let timerItem = TimerItem(duration: 120, category: "cooking", title: "Boil Eggs")
     if let data = timerItem.serialize() {
         // Persist data (e.g., save to UserDefaults or a file)
         
         // To retrieve and deserialize:
         if let retrievedTimerItem = deserialize(from: data) {
             // Use the deserialized TimerItem
         }
     }
     */
    func serialize() -> Data? {
        try? JSONEncoder().encode(self)
    }

    func deserialize(from data: Data) -> TimerItem? {
        try? JSONDecoder().decode(TimerItem.self, from: data)
    }

}
