import Foundation

enum EventStatus: String, Codable {
    case pending
    case completed
    case missed
}

enum EventType: String, Codable {
    case medication
    case bloodPressure
    case meal
    case exercise
}

class ScheduledEvent: Codable, Identifiable {
    let id: UUID
    var time: Date
    var type: EventType
    var titleKey: String
    var descriptionKey: String
    var status: EventStatus

    init(time: Date, type: EventType, titleKey: String, descriptionKey: String) {
        self.id = UUID()
        self.time = time
        self.type = type
        self.titleKey = titleKey
        self.descriptionKey = descriptionKey
        self.status = .pending
    }

    enum CodingKeys: String, CodingKey {
        case time, type, titleKey, descriptionKey, status
    }

    // Keep old keys for migration if necessary
    enum OldCodingKeys: String, CodingKey {
        case completed
        case title
        case description
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.time = try container.decode(Date.self, forKey: .time)
        self.type = try container.decode(EventType.self, forKey: .type)

        // Handle new and old keys for title/description
        if let titleKey = try? container.decode(String.self, forKey: .titleKey) {
            self.titleKey = titleKey
        } else {
            let oldContainer = try decoder.container(keyedBy: OldCodingKeys.self)
            self.titleKey = try oldContainer.decode(String.self, forKey: .title)
        }

        if let descriptionKey = try? container.decode(String.self, forKey: .descriptionKey) {
            self.descriptionKey = descriptionKey
        } else {
            let oldContainer = try decoder.container(keyedBy: OldCodingKeys.self)
            self.descriptionKey = try oldContainer.decode(String.self, forKey: .description)
        }

        // Handle new and old keys for status/completed
        if let status = try? container.decode(EventStatus.self, forKey: .status) {
            self.status = status
        } else {
            let oldContainer = try decoder.container(keyedBy: OldCodingKeys.self)
            if let completed = try? oldContainer.decode(Bool.self, forKey: .completed) {
                self.status = completed ? .completed : .pending
            } else {
                self.status = .pending
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(time, forKey: .time)
        try container.encode(type, forKey: .type)
        try container.encode(titleKey, forKey: .titleKey)
        try container.encode(descriptionKey, forKey: .descriptionKey)
        try container.encode(status, forKey: .status)
    }

    func copy() -> ScheduledEvent {
        let newEvent = ScheduledEvent(time: self.time, type: self.type, titleKey: self.titleKey, descriptionKey: self.descriptionKey)
        newEvent.status = self.status
        return newEvent
    }
    
    func copy(with newDate: Date) -> ScheduledEvent {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: self.time)
        var newDateComponents = calendar.dateComponents([.year, .month, .day], from: newDate)
        newDateComponents.hour = timeComponents.hour
        newDateComponents.minute = timeComponents.minute
        newDateComponents.second = timeComponents.second
        
        let finalDate = calendar.date(from: newDateComponents) ?? newDate
        
        let newEvent = ScheduledEvent(time: finalDate, type: self.type, titleKey: self.titleKey, descriptionKey: self.descriptionKey)
        newEvent.status = .pending
        return newEvent
    }
}

class SchedulePhase: Codable, Identifiable {
    let id: UUID
    var startDate: Date
    var endDate: Date?
    var events: [ScheduledEvent]

    init(startDate: Date, endDate: Date?, events: [ScheduledEvent]) {
        self.id = UUID()
        self.startDate = startDate
        self.endDate = endDate
        self.events = events
    }

    enum CodingKeys: String, CodingKey {
        case startDate, endDate, events
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.endDate = try container.decodeIfPresent(Date.self, forKey: .endDate)
        self.events = try container.decode([ScheduledEvent].self, forKey: .events)
    }
}

class MedicationProfile: Codable, Identifiable {
    let id: UUID
    var nameKey: String
    var phases: [SchedulePhase]

    init(nameKey: String, phases: [SchedulePhase]) {
        self.id = UUID()
        self.nameKey = nameKey
        self.phases = phases
    }

    enum CodingKeys: String, CodingKey {
        case nameKey, phases
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.nameKey = try container.decode(String.self, forKey: .nameKey)
        self.phases = try container.decode([SchedulePhase].self, forKey: .phases)
    }
}
