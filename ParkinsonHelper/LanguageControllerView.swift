import SwiftUI

struct LanguageControllerView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var uiState = UIState()
    
    // State for splash screen
    @State private var viewId = UUID()
    @State private var showSplash = false
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    
    @State private var needsProfileSetup: Bool = false

    var body: some View {
        ZStack {
            if showSplash {
                LaunchScreenView()
            } else {
                ContentView()
                    .environmentObject(uiState)
                    .id(viewId)
            }
        }
        .onAppear(perform: decideInitialView)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                checkLanguage()
            }
        }
        .fullScreenCover(isPresented: $needsProfileSetup) {
            ProfileView(isFirstTimeSetup: true)
        }
    }

    private func decideInitialView() {
        // Check if a start date has been saved. If not, trigger the setup.
        if UserDefaults.standard.object(forKey: "medicationStartDate") == nil {
            needsProfileSetup = true
        }
    }

    private func checkLanguage() {
        let currentLanguage = Locale.preferredLanguages.first?.components(separatedBy: "-").first ?? "en"
        if appLanguage != currentLanguage {
            appLanguage = currentLanguage
            showSplash = true
            // Reload the view after the splash screen to apply language changes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showSplash = false
                self.viewId = UUID()
            }
        }
    }
}

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            Image("Splashscreen")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
        }
    }
}