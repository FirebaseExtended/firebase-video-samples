/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view for rendering tags and a description for a landmark.
*/

import FoundationModels
import SwiftUI

@Generable
struct TaggingResponse: Equatable {
    @Guide(.count(5))
    @Guide(description: "Most important topics in the input text")
    let tags: [String]
}

struct LandmarkDescriptionView: View {
    let landmark: Landmark
    @State private var generatedTags: TaggingResponse.PartiallyGenerated?
    
    let contentTaggingModel = SystemLanguageModel(useCase: .contentTagging)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(landmark.name)")
                .padding(.top, 150)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            FlowLayout(alignment: .leading) {
                if let tags = generatedTags?.tags {
                    ForEach(tags, id: \.self) { tag in
                        Text("#" + tag)
                            .tagStyle()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("\(landmark.shortDescription)")
        }
        .animation(.default, value: generatedTags)
        .transition(.opacity)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .task {
            if !contentTaggingModel.isAvailable { return }
            do {
                let session = LanguageModelSession(model: contentTaggingModel)
                let stream = session.streamResponse(
                    to: landmark.description,
                    generating: TaggingResponse.self,
                    options: GenerationOptions(sampling: .greedy)
                )
                for try await newTags in stream {
                    generatedTags = newTags.content
                }
            } catch {
                Logging.general.error("\(error.localizedDescription)")
            }
        }
    }
}
