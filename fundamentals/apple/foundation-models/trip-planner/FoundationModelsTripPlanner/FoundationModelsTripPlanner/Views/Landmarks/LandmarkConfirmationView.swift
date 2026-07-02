/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view presented as a sheet when a landmark has been identified from an image.
*/

import SwiftUI
import FoundationModels

struct LandmarkConfirmationView: View {
    let identified: LandmarkIdentification
    let image: UIImage?
    let planner: ItineraryPlanner?
    
    @Binding var scrolledToLandmark: String?
    @Binding var flashedLandmark: String?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal)
                }
                
                Text("We identified this as:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(identified.name)
                    .font(.title3)
                    .bold()
                
                ScrollView {
                    Text(identified.description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Landmark Identified")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") {
                        addToTrip()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private func addToTrip() {
        if let planner = planner {
            if planner.isRequested {
                Task {
                    try? await planner.updateItinerary(with: identified.name, image: image)
                }
            } else {
                planner.addSelectedLandmark(identified.name, image: image)
            }
        }
        dismiss()
    }
}
