
import SwiftUI

enum Tab {
    case home
    case history
    case support
    case settings
}

struct BottomNavBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack {
            Spacer()
            Button(action: { selectedTab = .home }) {
                VStack {
                    Image(systemName: "house.fill")
                        .font(.system(size: 22))
                    Text(NSLocalizedString("NAV_BAR_HOME", comment: ""))
                        .font(.system(size: 12))
                }
                .foregroundColor(selectedTab == .home ? .blue : .gray)
            }
            Spacer()
            Button(action: { selectedTab = .history }) {
                VStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 22))
                    Text(NSLocalizedString("NAV_BAR_HISTORY", comment: ""))
                        .font(.system(size: 12))
                }
                .foregroundColor(selectedTab == .history ? .blue : .gray)
            }
            Spacer()
            Button(action: { selectedTab = .support }) {
                VStack {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 22))
                    Text(NSLocalizedString("NAV_BAR_SUPPORT", comment: ""))
                        .font(.system(size: 12))
                }
                .foregroundColor(selectedTab == .support ? .blue : .gray)
            }
            Spacer()
            Button(action: { selectedTab = .settings }) {
                VStack {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 22))
                    Text(NSLocalizedString("NAV_BAR_SETTINGS", comment: ""))
                        .font(.system(size: 12))
                }
                .foregroundColor(selectedTab == .settings ? .blue : .gray)
            }
            Spacer()
        }
        .padding(.top)
        .background(Color(.systemGray6))
    }
}

struct BottomNavBar_Previews: PreviewProvider {
    static var previews: some View {
        BottomNavBar(selectedTab: .constant(.home))
    }
}
