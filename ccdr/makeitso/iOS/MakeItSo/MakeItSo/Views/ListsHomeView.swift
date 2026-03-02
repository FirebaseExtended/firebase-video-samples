import SwiftUI

struct ListsHomeView: View {
  @State private var listRepository = TaskListRepository()
  @State private var isPresentingAddList = false
  @State private var newListTitle = ""

  var body: some View {
    NavigationStack {
      if listRepository.user == nil {
        ProgressView("Signing in...")
      } else {
        List {
          Section {
            NavigationLink(destination: TaskListView()) {
              Label("All Tasks", systemImage: "tray.full")
            }
          }

          Section("My Lists") {
            ForEach(listRepository.groups) { list in
              NavigationLink(value: list) {
                Label(list.title, systemImage: "list.bullet")
              }
            }
          }
        }
        .navigationTitle("Lists")
        .navigationDestination(for: TaskList.self) { list in
          TaskListView(taskList: list)
        }
        .toolbar {
          ToolbarItem(placement: .primaryAction) {
            Button {
              isPresentingAddList = true
            } label: {
              Image(systemName: "plus")
            }
          }
        }
        .sheet(isPresented: $isPresentingAddList) {
          NavigationStack {
            Form {
              TextField("List Name", text: $newListTitle)
            }
            .navigationTitle("New List")
            .toolbar {
              ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                  isPresentingAddList = false
                  newListTitle = ""
                }
              }
              ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                  addList()
                }
                .disabled(newListTitle.isEmpty)
              }
            }
          }
        }
      }
    }
  }

  private func addList() {
    let list = TaskList(title: newListTitle, userId: "")  // userId is filled by repository
    Task {
      do {
        try await listRepository.addList(list)
        isPresentingAddList = false
        newListTitle = ""
      } catch {
        print("Error adding list: \(error.localizedDescription)")
      }
    }
  }
}
