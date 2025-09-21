import Foundation

class MedicationData {
    // This function now acts as a template generator for a specific medication profile.
    // It takes a start date and builds the entire phased schedule based on that date.
    static func createLowDosageMadopar(startDate: Date) -> MedicationProfile {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        // Base events define the times and types of tasks for a standard day.
        let baseEvents = [
            ScheduledEvent(time: formatter.date(from: "08:00")!, type: .medication, titleKey: "MEDICATION_NAME_MADOPAR", descriptionKey: "DOSAGE_ONE_QUARTER_TABLET"),
            ScheduledEvent(time: formatter.date(from: "08:05")!, type: .bloodPressure, titleKey: "ACTIVITY_BLOOD_PRESSURE", descriptionKey: "ACTIVITY_TAKE_BLOOD_PRESSURE"),
            ScheduledEvent(time: formatter.date(from: "08:30")!, type: .meal, titleKey: "MEAL_BREAKFAST", descriptionKey: "MEAL_BREAKFAST"),
            ScheduledEvent(time: formatter.date(from: "09:00")!, type: .exercise, titleKey: "ACTIVITY_EXERCISE", descriptionKey: "ACTIVITY_30_MINUTES"),
            ScheduledEvent(time: formatter.date(from: "12:00")!, type: .medication, titleKey: "MEDICATION_NAME_MADOPAR", descriptionKey: "DOSAGE_ONE_QUARTER_TABLET"),
            ScheduledEvent(time: formatter.date(from: "12:05")!, type: .bloodPressure, titleKey: "ACTIVITY_BLOOD_PRESSURE", descriptionKey: "ACTIVITY_TAKE_BLOOD_PRESSURE"),
            ScheduledEvent(time: formatter.date(from: "12:30")!, type: .meal, titleKey: "MEAL_LUNCH", descriptionKey: "MEAL_LUNCH")
        ]

        // Each phase builds upon the base events, modifying dosages or adding new events.
        let phase1Events = baseEvents.map { $0.copy() }

        var phase2Events = baseEvents.map { $0.copy() }
        phase2Events.append(contentsOf: [
            ScheduledEvent(time: formatter.date(from: "17:00")!, type: .medication, titleKey: "MEDICATION_NAME_MADOPAR", descriptionKey: "DOSAGE_ONE_QUARTER_TABLET"),
            ScheduledEvent(time: formatter.date(from: "17:05")!, type: .bloodPressure, titleKey: "ACTIVITY_BLOOD_PRESSURE", descriptionKey: "ACTIVITY_TAKE_BLOOD_PRESSURE"),
            ScheduledEvent(time: formatter.date(from: "17:30")!, type: .meal, titleKey: "MEAL_DINNER", descriptionKey: "MEAL_DINNER")
        ])
        phase2Events.sort { $0.time < $1.time }

        var phase3Events = phase2Events.map { $0.copy() }
        if let index = phase3Events.firstIndex(where: { $0.time == formatter.date(from: "08:00") }) {
            phase3Events[index].descriptionKey = "DOSAGE_ONE_HALF_TABLET"
        }
        phase3Events.sort { $0.time < $1.time }

        var phase4Events = phase3Events.map { $0.copy() }
        if let index = phase4Events.firstIndex(where: { $0.time == formatter.date(from: "12:00") }) {
            phase4Events[index].descriptionKey = "DOSAGE_ONE_HALF_TABLET"
        }
        phase4Events.sort { $0.time < $1.time }

        var movingForwardEvents = phase4Events.map { $0.copy() }
        if let index = movingForwardEvents.firstIndex(where: { $0.time == formatter.date(from: "17:00") }) {
            movingForwardEvents[index].descriptionKey = "DOSAGE_ONE_HALF_TABLET"
        }
        movingForwardEvents.sort { $0.time < $1.time }

        // The phases are defined with start and end dates relative to the user-provided startDate.
        let phases = [
            SchedulePhase(startDate: startDate, endDate: Calendar.current.date(byAdding: .day, value: 14, to: startDate)!, events: phase1Events),
            SchedulePhase(startDate: Calendar.current.date(byAdding: .day, value: 14, to: startDate)!, endDate: Calendar.current.date(byAdding: .day, value: 28, to: startDate)!, events: phase2Events),
            SchedulePhase(startDate: Calendar.current.date(byAdding: .day, value: 28, to: startDate)!, endDate: Calendar.current.date(byAdding: .day, value: 42, to: startDate)!, events: phase3Events),
            SchedulePhase(startDate: Calendar.current.date(byAdding: .day, value: 42, to: startDate)!, endDate: Calendar.current.date(byAdding: .day, value: 56, to: startDate)!, events: phase4Events),
            SchedulePhase(startDate: Calendar.current.date(byAdding: .day, value: 56, to: startDate)!, endDate: nil, events: movingForwardEvents)
        ]

        return MedicationProfile(nameKey: "MEDICATION_PROFILE_LOW_DOSAGE", phases: phases)
    }
}