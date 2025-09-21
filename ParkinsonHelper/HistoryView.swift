import SwiftUI
import CoreData

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var events: FetchedResults<EventEntity>

    init() {
        let fetchRequest: NSFetchRequest<EventEntity> = EventEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \EventEntity.timestamp, ascending: false)]
        _events = FetchRequest(fetchRequest: fetchRequest, animation: .default)
    }

    struct DayEvents: Identifiable {
        let id: Date
        let events: [ScheduledEvent]
    }

    private var groupedEvents: [DayEvents] {
        // Group by start of day, filtering out any events that don't have a timestamp.
        let groupedByDate = Dictionary(grouping: events.compactMap { event -> (Date, EventEntity)? in
            guard let timestamp = event.timestamp else { return nil }
            return (Calendar.current.startOfDay(for: timestamp), event)
        }, by: { $0.0 })

        // Map the grouped events into DayEvents, filtering out any malformed entities.
        return groupedByDate.compactMap { (date, eventPairs) -> DayEvents? in
            let scheduledEvents = eventPairs.compactMap { (_, entity) -> ScheduledEvent? in
                guard let title = entity.title,
                      let desc = entity.desc,
                      let timestamp = entity.timestamp else {
                    return nil // Skip this event if essential data is missing
                }
                
                let eventType = EventType(rawValue: entity.type ?? "") ?? .medication
                let eventStatus = EventStatus(rawValue: entity.status ?? "") ?? .pending
                
                let scheduledEvent = ScheduledEvent(time: timestamp, type: eventType, titleKey: title, descriptionKey: desc)
                scheduledEvent.status = eventStatus
                return scheduledEvent
            }
            
            // Only create a DayEvents object if there are valid events for that day.
            guard !scheduledEvents.isEmpty else { return nil }
            
            return DayEvents(id: date, events: scheduledEvents.sorted(by: { $0.time < $1.time }))
        }.sorted(by: { $0.id > $1.id })
    }

    var body: some View {
        NavigationView {
            VStack {
                Text(NSLocalizedString("COMPLETED_TASK_TITLE", comment: "Title for the completed tasks screen"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                List {
                    ForEach(groupedEvents) { day in
                        Section(header: Text(day.id, style: .date).font(.headline).fontWeight(.bold)) {
                            ForEach(day.events) { event in
                                TaskRow(event: event, isHistoryRow: true)
                                    .listRowInsets(EdgeInsets())
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
