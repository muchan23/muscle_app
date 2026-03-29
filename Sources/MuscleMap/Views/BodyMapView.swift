import SwiftUI

struct BodyMapView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: BodyViewModel
    @State private var showDetail = false
    @State private var viewDirection: BodyViewDirection = .front

    init() {
        _viewModel = StateObject(wrappedValue: BodyViewModel(context: PersistenceController.shared.container.viewContext))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                BodySceneView(
                    selectedMuscleId: $viewModel.selectedMuscleId,
                    viewDirection: $viewDirection,
                    lastTrainedByMuscle: viewModel.lastTrainedByMuscle
                ) { muscleId in
                    viewModel.selectedMuscleId = muscleId
                    showDetail = true
                }
                .ignoresSafeArea(edges: .top)

                VStack(spacing: 12) {
                    directionPicker
                    legend
                }
                .padding(.bottom, 16)
            }
            .navigationTitle("MuscleMap")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showDetail, onDismiss: { viewModel.fetchLastTrained() }) {
                if let group = viewModel.selectedMuscleGroup {
                    MuscleDetailView(muscleGroup: group)
                }
            }
        }
    }

    private var directionPicker: some View {
        Picker("", selection: $viewDirection) {
            Text("前面").tag(BodyViewDirection.front)
            Text("背面").tag(BodyViewDirection.back)
        }
        .pickerStyle(.segmented)
        .frame(width: 160)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    private var legend: some View {
        HStack(spacing: 16) {
            legendItem(color: .systemGreen,  label: "今日")
            legendItem(color: .systemBlue,   label: "〜3日")
            legendItem(color: .systemYellow, label: "〜7日")
            legendItem(color: .systemRed,    label: "7日以上")
            legendItem(color: .systemGray4,  label: "未記録")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding(.bottom, 16)
    }

    private func legendItem(color: UIColor, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color(color))
                .frame(width: 10, height: 10)
            Text(label)
                .font(.caption2)
        }
    }
}
