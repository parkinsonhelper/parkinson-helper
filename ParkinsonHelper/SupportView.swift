import SwiftUI

struct SupportView: View {
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Image(systemName: "sun.dust")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width * 0.2)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text("SUPPORT_VIEW_NOTE")
                        .padding()
                }
            }
        }
    }
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView()
    }
}