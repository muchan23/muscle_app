import SwiftUI
import CoreData

struct LogView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TrainingSession.date, ascending: false)],
        animation: .default
    )
    private var sessions: FetchedResults<TrainingSession>

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    ContentUnavailableView(
                        "記録がありません",
                        systemImage: "dumbbell",
                        description: Text("Bodyタブで部位を選んでトレーニングを記録しましょう")
                    )
                } else {
                    List {
                        ForEach(sessions) { session in
                            SessionRow(session: session)
                        }
                        .onDelete(perform: deleteSessions)
                    }
                }
            }
            .navigationTitle("トレーニングログ")
        }
    }

    private func deleteSessions(at offsets: IndexSet) {
        for index in offsets {
            context.delete(sessions[index])
        }
        try? context.save()
    }
}

struct SessionRow: View {
    let session: TrainingSession

    var entries: [TrainingEntry] {
        (session.entries?.allObjects as? [TrainingEntry] ?? [])
            .sorted { ($0.muscleGroupId ?? "") < ($1.muscleGroupId ?? "") }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(session.date ?? .now, style: .date)
                .font(.headline)

            ForEach(entries) { entry in
                EntryRow(entry: entry)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EntryRow: View {
    let entry: TrainingEntry

    var muscleName: String {
        ExerciseDatabase.shared.muscleGroup(id: entry.muscleGroupId ?? "")?.nameJa ?? entry.muscleGroupId ?? ""
    }

    var exerciseName: String {
        let db = ExerciseDatabase.shared
        guard let group = db.muscleGroup(id: entry.muscleGroupId ?? "") else { return entry.exerciseId ?? "" }
        return group.exercises.first(where: { $0.id == entry.exerciseId })?.nameJa ?? entry.exerciseId ?? ""
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(muscleName)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Text(exerciseName)
                    .font(.subheadline)
            }
            Spacer()
            Text("\(entry.sets)セット × \(entry.reps)回")
                .font(.caption)
                .foregroundStyle(.secondary)
            if entry.weight > 0 {
                Text("\(entry.weight, specifier: "%.1f")kg")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
