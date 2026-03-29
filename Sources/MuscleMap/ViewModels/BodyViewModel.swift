import SwiftUI
import CoreData

final class BodyViewModel: ObservableObject {
    @Published var selectedMuscleId: String?
    @Published var lastTrainedByMuscle: [String: Date] = [:]

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchLastTrained()
    }

    func fetchLastTrained() {
        let request = TrainingEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrainingEntry.session?.date, ascending: false)]

        guard let entries = try? context.fetch(request) else { return }

        var result: [String: Date] = [:]
        for entry in entries {
            let id = entry.muscleGroupId ?? ""
            if result[id] == nil, let date = entry.session?.date {
                result[id] = date
            }
        }
        lastTrainedByMuscle = result
    }

    func selectMuscle(nodeNamed name: String) {
        selectedMuscleId = MuscleNodeMap.nodeToMuscleId[name]
    }

    var selectedMuscleGroup: MuscleGroup? {
        guard let id = selectedMuscleId else { return nil }
        return ExerciseDatabase.shared.muscleGroup(id: id)
    }

    func daysSinceLastTrained(_ muscleId: String) -> Int? {
        guard let date = lastTrainedByMuscle[muscleId] else { return nil }
        return Calendar.current.dateComponents([.day], from: date, to: .now).day
    }
}
