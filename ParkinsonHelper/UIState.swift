import Foundation
import Combine

// An object to hold global UI state, especially for sheet presentations
// that need to survive view reloads.
class UIState: ObservableObject {
    @Published var showingProfileSheet = false
    @Published var eventToProcessForSheet: ScheduledEvent?
    @Published var eventToProcessForAlert: ScheduledEvent?
    @Published var showingStandardConfirmationAlert = false
}