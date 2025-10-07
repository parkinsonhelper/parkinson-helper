import SwiftUI

struct MainView: View {
    @EnvironmentObject var scheduleManager: ScheduleManager
    @EnvironmentObject var uiState: UIState
    @AppStorage("userSurname") var userSurname: String = NSLocalizedString("USER_NAME_PLACEHOLDER", comment: "")
    
    @State private var selectedTab: TabItem = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(TabItem.home.localizedString, systemImage: TabItem.home.sfSymbol, value: .home) {
                HomeView()
            }
            
            Tab(TabItem.history.localizedString, systemImage: TabItem.history.sfSymbol, value: .history) {
                HistoryView()
            }
            
            Tab(TabItem.support.localizedString, systemImage: TabItem.support.sfSymbol, value: .support) {
                SupportView()
            }
            
            Tab(TabItem.settings.localizedString, systemImage: TabItem.settings.sfSymbol, value: .settings) {
                MedicationProfileView()
            }
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
