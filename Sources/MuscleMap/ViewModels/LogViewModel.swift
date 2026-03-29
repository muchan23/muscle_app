import SwiftUI
import CoreData

final class LogViewModel: ObservableObject {
    @Published var sessions: [TrainingSession] = []

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchSessions()
    }

    func fetchSessions() {
        let request = TrainingSession.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrainingSession.date, ascending: false)]

        sessions = (try? context.fetch(request)) ?? []
    }

    func logTraining(muscleGroupId: String, exerciseId: String, sets: Int16, reps: Int16, weight: Double) {
        let session = findOrCreateTodaySession()
        let entry = TrainingEntry(context: context)
        entry.muscleGroupId = muscleGroupId
        entry.exerciseId = exerciseId
        entry.sets = sets
        entry.reps = reps
        entry.weight = weight
        entry.session = session

        save()
        fetchSessions()
    }

    private func findOrCreateTodaySession() -> TrainingSession {
        let today = Calendar.current.startOfDay(for: .now)
        let request = TrainingSession.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@", today as NSDate)
        request.fetchLimit = 1

        if let existing = try? context.fetch(request).first {
            return existing
        }

        let session = TrainingSession(context: context)
        session.date = .now
        return session
    }

    private func save() {
        guard context.hasChanges else { return }
        try? context.save()
    }
}
