import SwiftUI

struct MainView: View {
    @EnvironmentObject var scheduleManager: ScheduleManager
    @EnvironmentObject var uiState: UIState
    @AppStorage("userSurname") var userSurname: String = NSLocalizedString("USER_NAME_PLACEHOLDER", comment: "")
    
    @State private var selectedTab: Tab = .home
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                if selectedTab == .home {
                    ScrollView {
                        VStack(spacing: 0) {
                            HeaderView()
                            ScheduleView(events: scheduleManager.upcomingEvents)
                            if #available(iOS 16.0, *) {
                                BloodPressureView(context: viewContext)
                            }
                        }
                        .padding(.bottom, 100)
                    }
                } else if selectedTab == .history {
                    HistoryView()
                } else if selectedTab == .support {
                    SupportView()
                } else if selectedTab == .settings {
                    MedicationProfileView()
                } else {
                    // Other tabs can be implemented here
                    Spacer()
                    Text("\(String(describing: selectedTab).capitalized)\(NSLocalizedString("GENERIC_SCREEN_SUFFIX", comment: ""))")
                    Spacer()
                }
            }
            .environmentObject(scheduleManager)

            BottomNavBar(selectedTab: $selectedTab)
                .padding(.bottom, 0)
                .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .sheet(isPresented: $uiState.showingProfileSheet) {
            ProfileView()
        }
        .sheet(item: $uiState.eventToProcessForSheet) { event in
            BPEntryView(eventToComplete: event)
                .environmentObject(scheduleManager)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(ScheduleManager())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}