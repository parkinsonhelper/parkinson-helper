import SwiftUI

struct ProfileView: View {
    // Environment
    @Environment(\.dismiss) var dismiss
    
    // AppStorage for persistence
    @AppStorage("userSurname") private var userSurname: String = ""
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("userGender") private var userGender: UserProfile.Gender = .man
    @AppStorage("userAge") private var userAge: String = ""
    
    
    // Local state for form inputs
    @State private var surname: String
    @State private var name: String
    @State private var gender: UserProfile.Gender
    @State private var age: String
    @State private var startDate: Date
    
    // View control
    var isFirstTimeSetup: Bool = false
    
    // Alerts
    @State private var showingConfirmationAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""

    init(isFirstTimeSetup: Bool = false) {
        self.isFirstTimeSetup = isFirstTimeSetup
        
        // Initialize local state from AppStorage
        _surname = State(initialValue: UserDefaults.standard.string(forKey: "userSurname") ?? "")
        _name = State(initialValue: UserDefaults.standard.string(forKey: "userName") ?? "")
        _gender = State(initialValue: UserProfile.Gender(rawValue: UserDefaults.standard.string(forKey: "userGender") ?? "Man") ?? .man)
        _age = State(initialValue: UserDefaults.standard.string(forKey: "userAge") ?? "")
        
        // For the date, we need to check if it has been set before.
        // If not, we use today, otherwise we use the stored date.
        if let storedDate = UserDefaults.standard.object(forKey: "medicationStartDate") as? Date {
            _startDate = State(initialValue: storedDate)
        } else {
            _startDate = State(initialValue: Date())
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Surname (Mandatory)", text: $surname)
                    TextField("Name (Optional)", text: $name)
                    Picker("Gender (Mandatory)", selection: $gender) {
                        ForEach(UserProfile.Gender.allCases) { g in
                            Text(g.rawValue).tag(g)
                        }
                    }
                    .pickerStyle(.segmented)
                    TextField("Age (Mandatory)", text: $age)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Medication Schedule")) {
                    VStack(alignment: .leading) {
                        Text("Start Date")
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                            .labelsHidden()
                    }
                }

                Button("Save") {
                    validateAndConfirm()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !isFirstTimeSetup {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
            .alert("Confirm Start Date", isPresented: $showingConfirmationAlert) {
                Button("Yes", action: saveProfile)
                Button("No", role: .cancel) { }
            } message: {
                Text("You have selected \(startDate, formatter: itemFormatter). Is this correct?")
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func validateAndConfirm() {
        guard !surname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Surname is mandatory."
            showingErrorAlert = true
            return
        }

        guard let ageInt = Int(age), ageInt > 0 else {
            errorMessage = "Age must be a valid number."
            showingErrorAlert = true
            return
        }
        
        showingConfirmationAlert = true
    }
    
    private func saveProfile() {
        // Save all data to AppStorage
        userSurname = surname
        userName = name
        userGender = gender
        userAge = age
        UserDefaults.standard.set(startDate, forKey: "medicationStartDate")
        
        // Post notification to reload schedule
        NotificationCenter.default.post(name: .profileSaved, object: nil)
        
        // For debugging
        let userProfile = UserProfile(surname: surname, name: name.isEmpty ? nil : name, gender: gender, age: Int(age) ?? 0)
        print("Saving profile: \(userProfile) with start date: \(startDate)")

        dismiss()
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
}()

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview for first-time setup
        ProfileView(isFirstTimeSetup: true)
        
        // Preview for editing existing profile
        ProfileView()
    }
}