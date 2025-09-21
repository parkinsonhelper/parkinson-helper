
import SwiftUI

struct LanguageSelectionView: View {
    @Binding var showMainView: Bool

    var body: some View {
        VStack {
            Text("Welcome")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.bottom, 1)

            Text("Please select your language.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 30)

            Button(action: {
                // Action for English
            }) {
                HStack {
                    Text("🇬🇧")
                        .font(.largeTitle)
                    Text("English")
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }

            Button(action: {
                // Action for Chinese
            }) {
                HStack {
                    Text("🇨🇳")
                        .font(.largeTitle)
                    Text("中文 (Mandarin)")
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }

            Button(action: {
                // Action for Malay
            }) {
                HStack {
                    Text("🇲🇾")
                        .font(.largeTitle)
                    Text("Bahasa Melayu")
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }

            Button(action: {
                // Action for Tamil
            }) {
                HStack {
                    Text("🇮🇳")
                        .font(.largeTitle)
                    Text("தமிழ் (Tamil)")
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }

            Spacer()

            Button(action: {
                showMainView = true
            }) {
                Text(NSLocalizedString("CONTINUE_BUTTON", comment: ""))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

struct LanguageSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageSelectionView(showMainView: .constant(false))
    }
}
