import Foundation

struct UserProfile: Codable {
    var surname: String
    var name: String?
    var gender: Gender
    var age: Int

    enum Gender: String, Codable, CaseIterable, Identifiable {
        case man = "Man"
        case lady = "Lady"

        var id: String { self.rawValue }
    }
}
