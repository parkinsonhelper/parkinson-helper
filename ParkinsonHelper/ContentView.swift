import SwiftUI

struct ContentView: View {
    @State private var showMainView = true

    var body: some View {
        if showMainView {
            MainView()
        } else {
            LanguageSelectionView(showMainView: $showMainView)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}