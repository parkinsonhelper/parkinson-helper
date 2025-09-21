import SwiftUI
import Charts
import CoreData

// Enum to manage the toggle state
enum BpMetric: String, CaseIterable, Identifiable {
    case systolic = "SYS"
    case diastolic = "DIA"
    var id: Self { self }
}

// Struct to hold a matched pair of sitting and standing readings
struct BPPair: Identifiable {
    let id: UUID
    let timestamp: Date
    let sittingSystolic: Int16
    let sittingDiastolic: Int16
    let standingSystolic: Int16
    let standingDiastolic: Int16
}

struct BloodPressureView: View {
    @StateObject private var viewModel: BloodPressureViewModel
    @State private var selectedMetric: BpMetric = .systolic // Default to SYS

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: BloodPressureViewModel(context: context))
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("BLOOD_PRESSURE_TREND_TITLE", comment: ""))
                .font(.title2)
                .fontWeight(.bold)
                .padding([.leading, .top])

            Picker("Metric", selection: $selectedMetric) {
                ForEach(BpMetric.allCases) { metric in
                    Text(metric.rawValue).tag(metric)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            if viewModel.pairedReadings.isEmpty {
                emptyStateView
            } else {
                chartView
            }
        }
        .frame(height: 500)
    }
    
    private var chartView: some View {
        Chart(viewModel.pairedReadings) { pair in
            // Plot based on the selected metric (SYS or DIA)
            if selectedMetric == .systolic {
                LineMark(
                    x: .value("Time", pair.timestamp),
                    y: .value("Sitting", pair.sittingSystolic)
                )
                .foregroundStyle(by: .value("Position", NSLocalizedString("CHART_AXIS_SITTING", comment: "")))
                .symbol(by: .value("Position", NSLocalizedString("CHART_AXIS_SITTING", comment: "")))

                LineMark(
                    x: .value("Time", pair.timestamp),
                    y: .value("Standing", pair.standingSystolic)
                )
                .foregroundStyle(by: .value("Position", NSLocalizedString("CHART_AXIS_STANDING", comment: "")))
                .symbol(by: .value("Position", NSLocalizedString("CHART_AXIS_STANDING", comment: "")))
            } else {
                LineMark(
                    x: .value("Time", pair.timestamp),
                    y: .value("Sitting", pair.sittingDiastolic)
                )
                .foregroundStyle(by: .value("Position", NSLocalizedString("CHART_AXIS_SITTING", comment: "")))
                .symbol(by: .value("Position", NSLocalizedString("CHART_AXIS_SITTING", comment: "")))

                LineMark(
                    x: .value("Time", pair.timestamp),
                    y: .value("Standing", pair.standingDiastolic)
                )
                .foregroundStyle(by: .value("Position", NSLocalizedString("CHART_AXIS_STANDING", comment: "")))
                .symbol(by: .value("Position", NSLocalizedString("CHART_AXIS_STANDING", comment: "")))
            }
        }
        .chartYAxisLabel(NSLocalizedString("CHART_AXIS_BLOOD_PRESSURE_MMHG", comment: ""))
        .chartYScale(domain: 70...150)
                .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel(format: .dateTime.day().month(.twoDigits))
            }
        }
        .padding()
        //.frame(height: 200)
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Text(NSLocalizedString("BP_GRAPH_EMPTY_STATE", comment: ""))
                .font(.headline)
                .foregroundColor(.gray)
            Spacer()
        }
        //.frame(height: 200)
        .frame(maxWidth: .infinity)
    }
}

struct BloodPressureView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        BloodPressureView(context: context)
            .environment(\.managedObjectContext, context)
    }
}
