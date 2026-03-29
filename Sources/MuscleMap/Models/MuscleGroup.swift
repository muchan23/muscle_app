import Foundation

struct MuscleGroup: Codable, Identifiable {
    let id: String
    let nameJa: String
    let nameEn: String
    let description: String
    let exercises: [Exercise]
}

struct Exercise: Codable, Identifiable {
    let id: String
    let nameJa: String
    let nameEn: String
    let difficulty: Difficulty
    let equipment: [String]
    let description: String

    enum Difficulty: String, Codable {
        case beginner
        case intermediate
        case advanced
    }
}

struct ExerciseDatabaseFile: Codable {
    let muscleGroups: [MuscleGroup]
}

// SceneKitのノード名 → 筋肉グループIDのマッピング
enum MuscleNodeMap {
    static let nodeToMuscleId: [String: String] = [
        "chest":         "chest",
        "abs":           "abs",
        "traps":         "traps",
        "back":          "back",
        "lats_l":        "lats",
        "lats_r":        "lats",
        "shoulders_l":   "shoulders",
        "shoulders_r":   "shoulders",
        "biceps_l":      "biceps",
        "biceps_r":      "biceps",
        "triceps_l":     "triceps",
        "triceps_r":     "triceps",
        "quads_l":       "quads",
        "quads_r":       "quads",
        "hamstrings_l":  "hamstrings",
        "hamstrings_r":  "hamstrings",
        "glutes_l":      "glutes",
        "glutes_r":      "glutes",
        "calves_l":      "calves",
        "calves_r":      "calves",
    ]

    // 筋肉グループIDに属するすべてのノード名を返す
    static func nodeNames(for muscleId: String) -> [String] {
        nodeToMuscleId.compactMap { $0.value == muscleId ? $0.key : nil }
    }
}
