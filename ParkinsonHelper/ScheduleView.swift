import SwiftUI
import AVFoundation

struct ScheduleView: View {
    @EnvironmentObject var scheduleManager: ScheduleManager
    @EnvironmentObject var uiState: UIState
    let events: [ScheduledEvent]

    var body: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("TODAYS_SCHEDULE_TITLE", comment: ""))
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)

            if events.isEmpty {
                emptyStateView
            } else {
                taskList
            }
        }
        .alert(isPresented: $uiState.showingStandardConfirmationAlert) {
            Alert(
                title: Text(NSLocalizedString("CONFIRM_TITLE", comment: "Confirmation dialog title")),
                primaryButton: .destructive(Text(NSLocalizedString("YES_BUTTON", comment: "Yes button"))) {
                    if let event = uiState.eventToProcessForAlert {
                        scheduleManager.completeEvent(event)
                    }
                },
                secondaryButton: .cancel(Text(NSLocalizedString("NO_BUTTON", comment: "No button")))
            )
        }
    }

    private var emptyStateView: some View {
        VStack {
            //Spacer()
            Image(systemName: "face.smiling")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundColor(.yellow)
            Text(NSLocalizedString("ALL_TASKS_COMPLETED_MESSAGE", comment: "Message shown when all tasks for the day are complete"))
                .font(.title)
                .fontWeight(.bold)
                .padding()
            //Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var taskList: some View {
        VStack(spacing: 15) {
            ForEach(events) { event in
                TaskRow(event: event, isHistoryRow: false) { tappedEvent in
                    handleTaskCompletion(tappedEvent)
                }
            }
        }
        .padding()
    }

    private func handleTaskCompletion(_ event: ScheduledEvent) {
        if event.type == .bloodPressure {
            uiState.eventToProcessForSheet = event
        } else {
            uiState.eventToProcessForAlert = event
            uiState.showingStandardConfirmationAlert = true
        }
    }
}

struct TaskRow: View {
    @EnvironmentObject var scheduleManager: ScheduleManager
    let event: ScheduledEvent
    var isHistoryRow: Bool = false
    var onComplete: ((ScheduledEvent) -> Void)? = nil // Closure to handle completion

    @StateObject private var speechManager = SpeechSynthesizerManager()
    @Environment(\.sizeCategory) private var sizeCategory

    var body: some View {
        if sizeCategory.isAccessibilityCategory {
            accessibleLayout
        } else {
            defaultLayout
        }
    }

    private var defaultLayout: some View {
        HStack(spacing: 15) {
            Button(action: {
                speak()
            }) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 22))
                    .foregroundColor(event.type.color)
                    .padding(.leading, 10)
                    .opacity(speechManager.isSpeaking ? 0.6 : 1.0)
                    .animation(speechManager.isSpeaking ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: speechManager.isSpeaking)
            }

            Image(systemName: event.type.icon)
                .font(.system(size: 22))
                .foregroundColor(event.type.color)
                .padding(10)
                .background(event.type.color.opacity(0.2))
                .cornerRadius(10)

            VStack(alignment: .leading) {
                Text(event.time, style: .time)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text(NSLocalizedString(event.titleKey, comment: ""))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text(NSLocalizedString(event.descriptionKey,comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if isHistoryRow {
                historyStatusIcon
            } else {
                completionButton
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }

    private var accessibleLayout: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: event.type.icon)
                    .font(.system(size: 34))
                    .foregroundColor(event.type.color)
                
                VStack(alignment: .leading) {
                    Text(event.time, style: .time)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(NSLocalizedString(event.titleKey, comment: ""))
                        .font(.title2)
                        .fontWeight(.bold)
                }
                Spacer()
                if isHistoryRow {
                    historyStatusIcon
                } else {
                    completionButton
                }
            }

            Text(NSLocalizedString(event.descriptionKey, comment: ""))
                .font(.body)

            Button(action: {
                speak()
            }) {
                HStack {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title2)
                    Text("Read Aloud")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(event.type.color.opacity(0.2))
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
    
    private func speak() {
        if speechManager.isSpeaking {
            speechManager.stopSpeaking()
        } else {
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            let timeString = timeFormatter.string(from: event.time)

            let title = NSLocalizedString(event.titleKey, comment: "")
            let description = NSLocalizedString(event.descriptionKey, comment: "")
            let speechString = "\(timeString). \(title). \(description)."
            let languageCode = Locale.current.language.languageCode?.identifier
            speechManager.speak(text: speechString, languageCode: languageCode)
        }
    }

    @ViewBuilder
    private var historyStatusIcon: some View {
        switch event.status {
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(.green)
                .padding(.trailing, 10)
        case .missed:
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(.red)
                .padding(.trailing, 10)
        case .pending:
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(.gray)
                .padding(.trailing, 10)
        }
    }

    @ViewBuilder
    private var completionButton: some View {
        Button(action: {
            onComplete?(event)
        }) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(event.type.color.opacity(0.5))
                .padding(.trailing, 10)
        }
    }
}

extension EventType {
    var icon: String {
        switch self {
        case .medication:
            return "pill.fill"
        case .bloodPressure:
            return "heart.fill"
        case .meal:
            return "fork.knife"
        case .exercise:
            return "figure.walk"
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView(events: [])
            .environmentObject(ScheduleManager())
    }
}
