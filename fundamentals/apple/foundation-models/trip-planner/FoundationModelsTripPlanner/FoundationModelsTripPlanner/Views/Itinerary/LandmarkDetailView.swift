/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that shows detailed information about a landmark activity.
*/

import SwiftUI
import FoundationModels
import MapKit
import FirebaseAILogic

struct LandmarkDetailView: View {
    let landmark: Landmark
    let activityTitle: String
    let category: String
    let shortDescription: String
    let latitude: Double?
    let longitude: Double?
    let customImage: UIImage?
    
    @State private var provider: LandmarkDetailProvider
    @State private var isShimmering = false
    @State private var headerHeight: CGFloat = 420
    
    init(landmark: Landmark, activityTitle: String, category: String, shortDescription: String, latitude: Double? = nil, longitude: Double? = nil, customImage: UIImage? = nil) {
        self.landmark = landmark
        self.activityTitle = activityTitle
        self.category = category
        self.shortDescription = shortDescription
        self.latitude = latitude
        self.longitude = longitude
        self.customImage = customImage
        self._provider = State(wrappedValue: LandmarkDetailProvider(activityTitle: activityTitle, landmarkName: landmark.name))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(activityTitle)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(category.capitalized)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                
                Text(shortDescription)
                    .font(.body)
                
                // The Card
                VStack(alignment: .leading, spacing: 16) {
                    // Map View at top, zoomed in
                    let center = CLLocationCoordinate2D(
                        latitude: latitude ?? landmark.locationCoordinate.latitude,
                        longitude: longitude ?? landmark.locationCoordinate.longitude
                    )
                    Map(initialPosition: .region(MKCoordinateRegion(center: center, span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01))), interactionModes: [])
                        .disabled(true)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding([.horizontal, .top], 4)
                    
                    if let details = provider.detailInfo {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("General Information")
                                .font(.headline)
                            if let generalInfo = details.generalInfo {
                                VStack(alignment: .leading, spacing: 4) {
                                    ForEach(generalInfo, id: \.self) { item in
                                        HStack(alignment: .top, spacing: 6) {
                                            Text("•")
                                            Text(LocalizedStringKey(item))
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            } else {
                                skeletonLines(count: 3)
                            }
                            
                            Text("Opening Times")
                                .font(.headline)
                                .padding(.top, 4)
                            if let openingTimes = details.openingTimes, !openingTimes.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    ForEach(openingTimes, id: \.self) { hour in
                                        HStack {
                                            Text(hour.days ?? "")
                                                .fontWeight(.semibold)
                                            Spacer()
                                            Text(hour.hours ?? "")
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            } else {
                                skeletonLines(count: 4)
                            }
                            
                            Text("Upcoming Events")
                                .font(.headline)
                                .padding(.top, 4)
                            if let upcomingEvents = details.upcomingEvents {
                                VStack(alignment: .leading, spacing: 4) {
                                    ForEach(upcomingEvents, id: \.self) { item in
                                        HStack(alignment: .top, spacing: 6) {
                                            Text("•")
                                            Text(LocalizedStringKey(item))
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            } else {
                                skeletonLines(count: 3)
                            }
                            
                            if let metadata = provider.groundingMetadata {
                                if !metadata.groundingChunks.isEmpty {
                                    Divider()
                                    Text("Sources")
                                        .font(.headline)
                                        .padding(.top, 4)
                                    ForEach(0..<metadata.groundingChunks.count, id: \.self) { index in
                                        let chunk = metadata.groundingChunks[index]
                                        if let webChunk = chunk.web {
                                            SourceLinkView(
                                                title: webChunk.title ?? "Untitled Source",
                                                uri: webChunk.uri
                                            )
                                        }
                                    }
                                }
                                
                                if let searchEntryPoint = metadata.searchEntryPoint {
                                    Divider()
                                    GoogleSearchSuggestionView(htmlString: searchEntryPoint.renderedContent)
                                        .frame(height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .padding(.vertical, 4)
                                }
                            }
                            
                        }
                        .padding()
                        .transition(.blurReplace)
                        
                        if let imageUrl = provider.unsplashImageUrl, let url = URL(string: imageUrl) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Photo")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 200)
                                    .overlay(
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        } placeholder: {
                                            ProgressView("Loading image...")
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                .background(Color.gray.opacity(0.1))
                                        }
                                    )
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .padding([.horizontal, .bottom], 4)
                            }
                        }
                        
                    } else if provider.error != nil {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                            Text("Failed to load details.")
                        }
                        .foregroundStyle(.red)
                        .padding()
                        .transition(.blurReplace)
                    } else {
                        // Skeleton View
                        VStack(alignment: .leading, spacing: 12) {
                            Text("General Information")
                                .font(.headline)
                            skeletonLines(count: 3)
                            
                            Text("Opening Times")
                                .font(.headline)
                                .padding(.top, 4)
                            skeletonLines(count: 4)
                            
                            Text("Upcoming Events")
                                .font(.headline)
                                .padding(.top, 4)
                            skeletonLines(count: 3)
                        }
                        .padding()
                        .transition(.blurReplace)
                    }
                }
                .card()
            }
            .padding(.horizontal)
            .padding(.top, 200)
        }
        .ignoresSafeArea(edges: .top)
        .background(alignment: .top) {
            ItineraryHeader(destination: landmark, customImage: customImage)
                .background(GeometryReader { geo in
                    Color.clear.onAppear {
                        headerHeight = geo.size.height
                    }
                })
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if provider.detailInfo == nil {
                do {
                    try await provider.fetchDetails()
                } catch {
                    // Error is handled by provider state
                }
            }
        }
    }
    
    @ViewBuilder
    func skeletonLines(count: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 12)
                    .frame(maxWidth: index == count - 1 ? 200 : .infinity)
            }
        }
        .shimmer()
    }
}

private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0),
                            .init(color: colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.15), location: 0.5),
                            .init(color: .clear, location: 1)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: phase * geo.size.width)
                    .onAppear {
                        withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                            phase = 1
                        }
                    }
                }
                .mask(content)
            )
    }
}

private struct SourceLinkView: View {
  let title: String
  let uri: String?

  var body: some View {
    if let uri, let url = URL(string: uri) {
      Link(destination: url) {
        HStack(spacing: 4) {
          Image(systemName: "link")
            .font(.caption)
            .foregroundColor(.secondary)
          Text(title)
            .font(.footnote)
            .underline()
            .lineLimit(1)
            .multilineTextAlignment(.leading)
        }
      }
      .buttonStyle(.plain)
    }
  }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
