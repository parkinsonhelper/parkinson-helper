import SwiftUI
import CoreData

struct BPEntryView: View {
    
    enum BPEntryPhase {
        case sitting, timer, standing
    }
    
    // MARK: - Properties
    let eventToComplete: ScheduledEvent
    
    // MARK: - State
    @State private var currentPhase: BPEntryPhase = .sitting
    
    // Form inputs
    @State private var sittingSystolic: String = ""
    @State private var sittingDiastolic: String = ""
    @State private var standingSystolic: String = ""
    @State private var standingDiastolic: String = ""
    
    // Timer state
    @State private var timerRemaining = 2 // TEST VALUE for 2 secs for testing only.
    //@State private var timerRemaining = 180  //ACTUAL VALUE for 3 Minutes
    @State private var isTimerRunning = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Environment
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var scheduleManager: ScheduleManager
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(Color.white.opacity(0.2))
                .frame(width: 48, height: 6)
                .padding(.vertical, 8)
            
            // Content switching based on phase
            switch currentPhase {
            case .sitting:
                bpEntryPhaseView(isSitting: true)
            case .timer:
                timerPhaseView()
            case .standing:
                bpEntryPhaseView(isSitting: false)
            }
        }
        .background(Color(red: 23/255, green: 23/255, blue: 23/255)) // bg-neutral-950
        .foregroundColor(.white)
        .cornerRadius(24)
        .shadow(radius: 20)
        .padding(.horizontal)
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func bpEntryPhaseView(isSitting: Bool) -> some View {
        VStack {
            Text(NSLocalizedString(isSitting ? "BP_ENTRY_SITTING_TITLE" : "BP_ENTRY_STANDING_TITLE", comment: ""))
                .font(.largeTitle).bold()
                .padding()

            Image("BPimage")
                .resizable()
                .scaledToFit()
                .cornerRadius(16)
                .padding(.horizontal)

            // Systolic Input
            bpInputRow(label: NSLocalizedString("BP_SYSTOLIC_LABEL", comment: ""), 
                         shortLabel: "SYS", 
                         value: isSitting ? $sittingSystolic : $standingSystolic, 
                         color: Color(red: 4/255, green: 116/255, blue: 186/255)) // #0474BA
            
            // Diastolic Input
            bpInputRow(label: NSLocalizedString("BP_DIASTOLIC_LABEL", comment: ""), 
                         shortLabel: "DIA", 
                         value: isSitting ? $sittingDiastolic : $standingDiastolic, 
                         color: Color(red: 241/255, green: 119/255, blue: 32/255)) // #F17720
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(NSLocalizedString("BP_CANCEL_BUTTON", comment: "")) { dismiss() }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                
                Button(NSLocalizedString("BP_SAVE_BUTTON", comment: "")) { handleSaveOrNext() }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(12)
                    .disabled(isSaveDisabled(isSitting: isSitting))
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func timerPhaseView() -> some View {
        VStack {
            Text(NSLocalizedString("BP_TIMER_TITLE", comment: ""))
                .font(.largeTitle).bold()
                .padding()
            
            Text(NSLocalizedString("BP_TIMER_INSTRUCTION", comment: ""))
                .foregroundColor(.gray)
                .padding(.bottom)

            Text(formattedTime(timerRemaining))
                .font(.system(size: 60, weight: .bold, design: .monospaced))
                .padding(40)
                .background(Color.white.opacity(0.1))
                .cornerRadius(24)
                .onReceive(timer) { _ in
                    if isTimerRunning && timerRemaining > 0 {
                        timerRemaining -= 1
                    } else if timerRemaining == 0 {
                        isTimerRunning = false
                        currentPhase = .standing
                    }
                }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(NSLocalizedString("BP_CANCEL_BUTTON", comment: "")) { dismiss() }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                
                Button(isTimerRunning ? NSLocalizedString("BP_TIMER_RUNNING_BUTTON", comment: "") : NSLocalizedString("BP_START_TIMER_BUTTON", comment: "")) { isTimerRunning = true }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(12)
                    .disabled(isTimerRunning)
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func bpInputRow(label: String, shortLabel: String, value: Binding<String>, color: Color) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(shortLabel)
                    .font(.caption).bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.2))
                    .cornerRadius(8)
                Text(label)
                    .foregroundColor(.gray)
            }
            
            TextField("120", text: value)
                .font(.system(size: 48, weight: .bold))
                .keyboardType(.numberPad)
                .padding(12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // MARK: - Logic
    
    private func handleSaveOrNext() {
        if currentPhase == .sitting {
            currentPhase = .timer
        } else {
            saveAndComplete()
        }
    }
    
    private func saveAndComplete() {
        let correlationId = UUID()
        let now = Date()
        
        // Create Sitting Reading
        let sittingReading = BPEntity(context: viewContext)
        sittingReading.id = UUID()
        sittingReading.correlationID = correlationId
        sittingReading.timestamp = now // Use current time for both for now
        sittingReading.position = "sitting"
        sittingReading.systolic = Int16(sittingSystolic) ?? 0
        sittingReading.diastolic = Int16(sittingDiastolic) ?? 0
        
        // Create Standing Reading
        let standingReading = BPEntity(context: viewContext)
        standingReading.id = UUID()
        standingReading.correlationID = correlationId
        standingReading.timestamp = now
        standingReading.position = "standing"
        standingReading.systolic = Int16(standingSystolic) ?? 0
        standingReading.diastolic = Int16(standingDiastolic) ?? 0
        
        do {
            try viewContext.save()
            // Only complete the event after a successful save
            scheduleManager.completeEvent(eventToComplete)
            dismiss()
        } catch {
            // Handle the error appropriately
            print("Failed to save BP readings: \(error.localizedDescription)")
        }
    }
    
    private func isSaveDisabled(isSitting: Bool) -> Bool {
        if isSitting {
            return sittingSystolic.isEmpty || sittingDiastolic.isEmpty
        } else {
            return standingSystolic.isEmpty || standingDiastolic.isEmpty
        }
    }
    
    private func formattedTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

struct BPEntryView_Previews: PreviewProvider {
    static var previews: some View {
        // Creating a dummy event for previewing purposes
        let event = ScheduledEvent(time: Date(), type: .bloodPressure, titleKey: "Preview", descriptionKey: "Preview Desc")
        
        BPEntryView(eventToComplete: event)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ScheduleManager())
    }
}
