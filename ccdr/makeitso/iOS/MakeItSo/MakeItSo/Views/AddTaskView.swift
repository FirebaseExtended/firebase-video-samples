import SwiftUI

struct AddTaskView: View {
  @Environment(\.dismiss) var dismiss
  var onAdd: (TaskItem) -> Void

  @State private var title = ""
  @State private var description = ""
  @State private var priority: TaskPriority = .medium
  @State private var dueDate = Date()

  // AI Breakdown State
  @State private var suggestedTasks: [String] = []
  @State private var selectedSuggestions: Set<String> = []
  @State private var isAnalyzing = false
  private let aiService = AITaskService()

  var body: some View {
    NavigationStack {
      Form {
        Section {
          HStack {
            TextField("Task Title", text: $title)
            
            if !title.isEmpty {
              Button(action: runTaskBreakdown) {
                if isAnalyzing {
                  ProgressView()
                    .controlSize(.small)
                } else {
                  Image(systemName: "sparkles")
                    .foregroundStyle(.purple)
                }
              }
              .disabled(isAnalyzing)
            }
          }
          
          TextField("Description", text: $description, axis: .vertical)
            .lineLimit(3...10)
        }

        if !suggestedTasks.isEmpty {
          Section("AI Suggested Tasks") {
            ForEach(suggestedTasks, id: \.self) { suggestion in
              HStack {
                Image(systemName: selectedSuggestions.contains(suggestion) ? "checkmark.circle.fill" : "circle")
                  .foregroundStyle(selectedSuggestions.contains(suggestion) ? .blue : .gray)
                Text(suggestion)
                Spacer()
              }
              .contentShape(Rectangle())
              .onTapGesture {
                if selectedSuggestions.contains(suggestion) {
                  selectedSuggestions.remove(suggestion)
                } else {
                  selectedSuggestions.insert(suggestion)
                }
              }
            }
          }
        }

        Section("Details") {
          Picker("Priority", selection: $priority) {
            ForEach(TaskPriority.allCases, id: \.self) { priority in
              Text(priority.rawValue).tag(priority)
            }
          }

          DatePicker("Due Date", selection: $dueDate)
        }
      }
      .navigationTitle("New Task")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Add") {
            submit()
          }
          .disabled(title.isEmpty)
        }
      }
    }
  }

  private func runTaskBreakdown() {
    isAnalyzing = true
    Task {
      do {
        let suggestions = try await aiService.breakDownTask(title: title)
        self.suggestedTasks = suggestions
        self.selectedSuggestions = Set(suggestions)
      } catch {
        print("AI breakdown error: \(error)")
      }
      isAnalyzing = false
    }
  }

  private func submit() {
    if selectedSuggestions.isEmpty {
      let task = TaskItem(
        title: title, description: description.isEmpty ? nil : description, isCompleted: false,
        priority: priority, dueDate: dueDate)
      onAdd(task)
    } else {
      for taskTitle in selectedSuggestions {
        let task = TaskItem(
          title: taskTitle, description: nil, isCompleted: false,
          priority: priority, dueDate: dueDate)
        onAdd(task)
      }
    }
    dismiss()
  }
}

