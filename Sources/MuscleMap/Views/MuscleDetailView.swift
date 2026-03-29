import SwiftUI

struct MuscleDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    let muscleGroup: MuscleGroup

    @State private var selectedExercise: Exercise?
    @State private var sets: Int = 3
    @State private var reps: Int = 10
    @State private var weight: Double = 0
    @State private var showLogForm = false
    @State private var showSaved = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(muscleGroup.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("トレーニング種目") {
                    ForEach(muscleGroup.exercises) { exercise in
                        Button {
                            selectedExercise = exercise
                            showLogForm = true
                        } label: {
                            ExerciseRow(exercise: exercise)
                        }
                        .tint(.primary)
                    }
                }
            }
            .navigationTitle(muscleGroup.nameJa)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
            .sheet(isPresented: $showLogForm) {
                if let exercise = selectedExercise {
                    LogFormView(
                        muscleGroup: muscleGroup,
                        exercise: exercise,
                        sets: $sets,
                        reps: $reps,
                        weight: $weight
                    ) {
                        saveLog(exercise: exercise)
                    }
                }
            }
            .overlay {
                if showSaved {
                    savedToast
                }
            }
        }
    }

    private var savedToast: some View {
        Text("記録しました！")
            .font(.subheadline.bold())
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.green, in: Capsule())
            .foregroundStyle(.white)
            .transition(.move(edge: .top).combined(with: .opacity))
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 16)
    }

    private func saveLog(exercise: Exercise) {
        let vm = LogViewModel(context: context)
        vm.logTraining(
            muscleGroupId: muscleGroup.id,
            exerciseId: exercise.id,
            sets: Int16(sets),
            reps: Int16(reps),
            weight: weight
        )
        showLogForm = false
        withAnimation {
            showSaved = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showSaved = false }
        }
    }
}

struct ExerciseRow: View {
    let exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(exercise.nameJa)
                    .font(.headline)
                Spacer()
                difficultyBadge
            }
            Text(exercise.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            if !exercise.equipment.isEmpty {
                Text(exercise.equipment.joined(separator: ", "))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }

    private var difficultyBadge: some View {
        let (label, color): (String, Color) = switch exercise.difficulty {
        case .beginner:     ("初級", .green)
        case .intermediate: ("中級", .orange)
        case .advanced:     ("上級", .red)
        }
        return Text(label)
            .font(.caption2.bold())
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15), in: Capsule())
            .foregroundStyle(color)
    }
}

struct LogFormView: View {
    @Environment(\.dismiss) private var dismiss

    let muscleGroup: MuscleGroup
    let exercise: Exercise
    @Binding var sets: Int
    @Binding var reps: Int
    @Binding var weight: Double
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("種目") {
                    Text(exercise.nameJa).font(.headline)
                    Text(muscleGroup.nameJa).foregroundStyle(.secondary)
                }

                Section("記録") {
                    Stepper("セット数: \(sets)", value: $sets, in: 1...20)
                    Stepper("レップ数: \(reps)", value: $reps, in: 1...100)
                    HStack {
                        Text("重量 (kg)")
                        Spacer()
                        TextField("0", value: $weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
            }
            .navigationTitle("記録する")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") { onSave() }
                        .bold()
                }
            }
        }
    }
}
