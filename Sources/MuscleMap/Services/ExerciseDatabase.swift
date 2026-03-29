import Foundation

final class ExerciseDatabase {
    static let shared = ExerciseDatabase()

    private(set) var muscleGroups: [MuscleGroup] = []
    private var index: [String: MuscleGroup] = [:]

    private init() {
        load()
    }

    func muscleGroup(id: String) -> MuscleGroup? {
        index[id]
    }

    private func load() {
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(ExerciseDatabaseFile.self, from: data)
        else {
            return
        }

        muscleGroups = file.muscleGroups
        index = Dictionary(uniqueKeysWithValues: muscleGroups.map { ($0.id, $0) })
    }
}
