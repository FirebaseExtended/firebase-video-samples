import SwiftUI

struct NativeDatePicker: UIViewRepresentable {
  @Binding var selection: Date
  var minuteInterval: Int = 1

  func makeUIView(context: Context) -> UIDatePicker {
    let picker = UIDatePicker()
    picker.datePickerMode = .dateAndTime
    picker.preferredDatePickerStyle = .compact
    picker.minuteInterval = minuteInterval
    picker.addTarget(
      context.coordinator, action: #selector(Coordinator.changed(_:)), for: .valueChanged)
    return picker
  }

  func updateUIView(_ uiView: UIDatePicker, context: Context) {
    uiView.date = selection
    uiView.minuteInterval = minuteInterval
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject {
    var parent: NativeDatePicker

    init(_ parent: NativeDatePicker) {
      self.parent = parent
    }

    @objc func changed(_ sender: UIDatePicker) {
      parent.selection = sender.date
    }
  }
}
