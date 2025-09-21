import Foundation
import CoreData
import Combine

@MainActor
class BloodPressureViewModel: ObservableObject {
    @Published var pairedReadings: [BPPair] = []
    
    private var viewContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        
        // Listen for changes in the Core Data store and refetch automatically
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: viewContext)
            .sink { [weak self] _ in
                self?.fetchReadings()
            }
            .store(in: &cancellables)
        
        fetchReadings()
    }

    func fetchReadings() {
        let request = NSFetchRequest<BPEntity>(entityName: "BPEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BPEntity.timestamp, ascending: false)]
        
        do {
            let results = try viewContext.fetch(request)
            processFetchedResults(results)
        } catch {
            print("Failed to fetch BP readings: \(error)")
        }
    }
    
    private func processFetchedResults(_ results: [BPEntity]) {
        // Group by correlationID, filtering out any entities that are missing this ID.
        let groupedByCorrelation = Dictionary(grouping: results.filter { $0.correlationID != nil }, by: { $0.correlationID! })
        
        let pairs = groupedByCorrelation.compactMap { (_, readings) -> BPPair? in
            // Find the sitting and standing readings for a given correlationID.
            guard let sitting = readings.first(where: { $0.position == "sitting" }),
                  let standing = readings.first(where: { $0.position == "standing" }) else {
                return nil
            }
            
            // Safely unwrap the correlationID and timestamp from the sitting reading.
            guard let id = sitting.correlationID, let timestamp = sitting.timestamp else {
                return nil
            }
            
            // Create the BPPair object with safely unwrapped values.
            return BPPair(
                id: id,
                timestamp: timestamp,
                sittingSystolic: sitting.systolic,
                sittingDiastolic: sitting.diastolic,
                standingSystolic: standing.systolic,
                standingDiastolic: standing.diastolic
            )
        }
        .sorted(by: { $0.timestamp > $1.timestamp })
        
        // We now take the 5 most recent pairs
        self.pairedReadings = Array(pairs.prefix(5)).reversed() // reverse to show oldest to newest
    }
}
