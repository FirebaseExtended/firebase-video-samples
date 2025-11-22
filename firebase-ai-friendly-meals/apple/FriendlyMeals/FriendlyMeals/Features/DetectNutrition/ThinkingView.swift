import SwiftUI

struct ThinkingView: View {
  var thoughtStep: ThoughtStep?

  @State
  private var isExpanded = true

  var body: some View {
    HStack {
      Image(systemName: "arrow.clockwise")
        .symbolEffect(.rotate)
      DisclosureGroup(isExpanded: $isExpanded) {
        Text(thoughtStep?.description ?? "")
      }
      label: {
        Text(thoughtStep?.headline ?? "Thinking...")
          .font(.headline)
      }
    }
  }
}

#Preview {
  ThinkingView(thoughtStep: .init(from: "**Estimating Ingredient Ratios**\nNow, I'm diving deeper into the ingredient ratios within the Eggplant Parmesan. I'll need to figure out approximate proportions of eggplant, sauce, and cheeses to accurately determine nutritional content. I've noted the likely use of olive oil, and now I'm thinking about whether to account for flour/egg wash. I'm researching typical recipe breakdowns to get closer to realistic values."))
}
