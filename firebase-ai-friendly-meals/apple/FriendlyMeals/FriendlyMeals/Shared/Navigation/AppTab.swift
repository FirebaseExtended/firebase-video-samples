import SwiftUI

enum AppTab: Int, Hashable, CaseIterable {
  case cookbook = 0
  case suggestRecipe = 1
  case mealPlanner = 2
  case nutrition = 3
}

private struct SelectedTabKey: EnvironmentKey {
  static let defaultValue: Binding<AppTab> = .constant(.cookbook)
}

extension EnvironmentValues {
  var selectedTab: Binding<AppTab> {
    get { self[SelectedTabKey.self] }
    set { self[SelectedTabKey.self] = newValue }
  }
}
