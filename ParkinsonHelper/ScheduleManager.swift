import Foundation
import SwiftUI
import UserNotifications
import CoreData

class ScheduleManager: ObservableObject {
    @Published var upcomingEvents: [ScheduledEvent] = []
    
    // The user's specific, generated profile. It's now an optional.
    var profile: MedicationProfile?
    private var allEventsForToday: [ScheduledEvent] = []
    
    // Key for storing the user-set medication start date in UserDefaults.
    private let lastLaunchDateKey = "lastLaunchDate"

    private var dataURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("scheduleData.json")
    }
    
    private let viewContext = PersistenceController.shared.container.viewContext

    init() {
        // Listen for when the profile is saved so we can reload the schedule.
        NotificationCenter.default.addObserver(self, selector: #selector(handleProfileSaved), name: .profileSaved, object: nil)
        
        // Initial setup
        setupProfileAndSchedule()
    }
    
    @objc private func handleProfileSaved() {
        print("Profile saved notification received. Reloading schedule.")
        setupProfileAndSchedule()
    }
    
    // A single function to orchestrate profile loading and schedule generation.
    private func setupProfileAndSchedule() {
        // Ensure we have a start date. If not, we can't proceed.
        guard let startDate = UserDefaults.standard.object(forKey: "medicationStartDate") as? Date else {
            print("Medication start date not found. Waiting for profile setup.")
            return
        }
        
        // Generate the user-specific profile using the template.
        self.profile = MedicationData.createLowDosageMadopar(startDate: startDate)
        
        requestNotificationAuthorization()
        checkForDailyRollover()
        
        if !loadData() {
            loadAllEventsForToday()
            saveData()
        }
        
        updateUpcomingEvents()
        scheduleNotifications()
    }
    
    func checkForDailyRollover() {
        let userDefaults = UserDefaults.standard
        let lastLaunch = userDefaults.object(forKey: lastLaunchDateKey) as? Date

        guard let lastLaunchDate = lastLaunch else {
            userDefaults.set(Date(), forKey: lastLaunchDateKey)
            return
        }

        if Calendar.current.isDateInToday(lastLaunchDate) {
            return
        }

        if loadData() {
            let missedTasks = allEventsForToday.filter { $0.status == .pending }
            if !missedTasks.isEmpty {
                archiveTasks(missedTasks, as: .missed, on: lastLaunchDate)
            }
        }

        loadAllEventsForToday()
        saveData()
        userDefaults.set(Date(), forKey: lastLaunchDateKey)
    }
    
    private func archiveTasks(_ tasks: [ScheduledEvent], as status: EventStatus, on date: Date) {
        for task in tasks {
            let newEvent = EventEntity(context: viewContext)
            newEvent.id = task.id
            
            let taskTime = task.time
            var components = Calendar.current.dateComponents([.hour, .minute, .second], from: taskTime)
            components.year = Calendar.current.component(.year, from: date)
            components.month = Calendar.current.component(.month, from: date)
            components.day = Calendar.current.component(.day, from: date)
            
            newEvent.timestamp = Calendar.current.date(from: components) ?? date
            newEvent.title = NSLocalizedString(task.titleKey, comment: "")
            newEvent.desc = NSLocalizedString(task.descriptionKey, comment: "")
            newEvent.status = status.rawValue
            newEvent.type = task.type.rawValue
        }
        do {
            try viewContext.save()
        } catch {
            print("Error saving archived events: \(error)")
        }
    }

    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    private func scheduleNotifications() {
        cancelAllNotifications()
        for event in allEventsForToday where event.status == .pending {
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString(event.titleKey, comment: "")
            content.body = NSLocalizedString(event.descriptionKey, comment: "")
            content.sound = UNNotificationSound(named: UNNotificationSoundName("AlertChime.mp3"))

            let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.hour, .minute], from: event.time), repeats: false)
            let request = UNNotificationRequest(identifier: event.id.uuidString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request)
        }
    }

    private func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private func loadAllEventsForToday() {
        guard let profile = self.profile else { return }
        let now = Date()
        
        if let currentPhase = profile.phases.first(where: { now >= $0.startDate && (now < $0.endDate ?? Date.distantFuture) }) {
            self.allEventsForToday = currentPhase.events.map { event in
                let newEvent = event.copy(with: now) // Ensure event time is for today
                newEvent.status = .pending
                return newEvent
            }
        } else {
            // Handle case where there is no current phase (e.g., before schedule starts)
            self.allEventsForToday = []
        }
    }

    func updateUpcomingEvents() {
        let upcoming = allEventsForToday.filter { $0.status == .pending }
        self.upcomingEvents = Array(upcoming.prefix(2))
    }

    func completeEvent(_ event: ScheduledEvent) {
        if let index = allEventsForToday.firstIndex(where: { $0.id == event.id }) {
            archiveTasks([event], as: .completed, on: Date())
            allEventsForToday.remove(at: index)
            updateUpcomingEvents()
            saveData()
        }
    }

    private func saveData() {
        do {
            let data = try JSONEncoder().encode(allEventsForToday)
            try data.write(to: dataURL)
            scheduleNotifications()
        } catch {
            print("Error saving data: \(error)")
        }
    }

    private func loadData() -> Bool {
        guard let data = try? Data(contentsOf: dataURL) else { return false }
        do {
            allEventsForToday = try JSONDecoder().decode([ScheduledEvent].self, from: data)
            return true
        } catch {
            print("Error loading data: \(error)")
            return false
        }
    }
}

extension Notification.Name {
    static let profileSaved = Notification.Name("profileSaved")
}