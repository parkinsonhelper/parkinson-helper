
import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var uiState: UIState
    @AppStorage("userSurname") var userSurname: String = NSLocalizedString("USER_NAME_PLACEHOLDER", comment: "") // Default value from localization

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(NSLocalizedString("GREETING_HELLO", comment: ""))
                    .font(.body)
                    .foregroundColor(.gray)
                Text(userSurname) // Use the persisted surname
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            Spacer()
            Button(action: {
                uiState.showingProfileSheet = true
            }) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView()
    }
}
