/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view for rendering each day's suggested events from a partially generated itinerary.
*/

import FoundationModels
import SwiftUI
import MapKit
import WeatherKit
import FirebaseAILogic

struct ItineraryView: View {
    let landmark: Landmark
    let itinerary: Itinerary.PartiallyGenerated
    let customSpotImages: [String: UIImage]
    let lookupHistory: [FindPointsOfInterestMapsTool.Lookup]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading) {
                if let title = itinerary.title {
                    Text(title)
                        .contentTransition(.opacity)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                
                if let description = itinerary.description {
                    Text(description)
                        .contentTransition(.opacity)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            if let rationale = itinerary.rationale {
                HStack(alignment: .top) {
                    Image(systemName: "sparkles")
                    Text(rationale)
                        .contentTransition(.opacity)
                }
                .rationaleStyle()
            }
            
            if let days = itinerary.days {
                ForEach(days.indices, id: \.self) { index in
                    DayView(
                        landmark: landmark,
                        plan: days[index],
                        customSpotImages: customSpotImages,
                        lookupHistory: lookupHistory
                    )
                    .transition(.blurReplace)
                }
            }
        }
        .animation(.easeOut, value: itinerary)
        .itineraryStyle()
    }
}

private struct DayView: View {
    let landmark: Landmark
    let plan: DayPlan.PartiallyGenerated
    let customSpotImages: [String: UIImage]
    let lookupHistory: [FindPointsOfInterestMapsTool.Lookup]

    @State private var map = LocationLookup()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack(alignment: .bottom) {
                LandmarkDetailMapView(
                    landmark: landmark,
                    landmarkMapItem: map.item
                )
                .onChange(of: plan.destination) { _, newValue in
                    if let destination = newValue, !destination.isEmpty {
                        map.performLookup(location: destination)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(weatherForecast)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if let title = plan.title {
                        Text(title)
                            .contentTransition(.opacity)
                            .font(.headline)
                    }
                    if let subtitle = plan.subtitle {
                        Text(subtitle)
                            .contentTransition(.opacity)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .blurredBackground()
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .padding([.horizontal, .top], 4)
            
            ActivityList(landmark: landmark, activities: plan.activities ?? [], customSpotImages: customSpotImages, lookupHistory: lookupHistory)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
        }
        .padding(.bottom)
        .geometryGroup()
        .card()
        .animation(.easeInOut, value: plan)
    }
    
    var weatherForecast: LocalizedStringKey {
        if let forecast = map.temperatureString {
            "\(Image(systemName: "cloud.fill")) \(forecast)"
        } else {
            " "
        }
    }
}

private struct ActivityList: View {
    let landmark: Landmark
    let activities: [Activity.PartiallyGenerated]
    let customSpotImages: [String: UIImage]
    let lookupHistory: [FindPointsOfInterestMapsTool.Lookup]
    
    var body: some View {
        ForEach(0..<activities.count, id: \.self) { index in
            let activity = activities[index]
            if let title = activity.title {
                let matchingLookup = lookupHistory.first { lookup in
                    if let metadata = lookup.groundingMetadata {
                        return metadata.groundingChunks.contains { chunk in
                            if let chunkTitle = chunk.maps?.title {
                                return title.localizedCaseInsensitiveContains(chunkTitle) || chunkTitle.localizedCaseInsensitiveContains(title)
                            }
                            return false
                        }
                    }
                    return false
                }
                
                let customImageKey = customSpotImages.keys.first { key in
                    title.localizedCaseInsensitiveContains(key) || key.localizedCaseInsensitiveContains(title)
                }
                let customImage = customImageKey.flatMap { customSpotImages[$0] }

                NavigationLink(destination: LandmarkDetailView(landmark: landmark, activityTitle: title, category: activity.type?.displayName ?? "Activity", shortDescription: activity.description ?? "", latitude: activity.latitude, longitude: activity.longitude, customImage: customImage)) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top, spacing: 12) {
                            ActivityIcon(symbolName: activity.type?.symbolName)
                            VStack(alignment: .leading) {
                                Text(title)
                                    .contentTransition(.opacity)
                                    .font(.headline)
                                if let description = activity.description {
                                    Text(description)
                                        .contentTransition(.opacity)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        
                        if let lookup = matchingLookup, let metadata = lookup.groundingMetadata {
                            VStack(alignment: .leading, spacing: 2) {
                                ForEach(0..<metadata.groundingChunks.count, id: \.self) { idx in
                                    let chunk = metadata.groundingChunks[idx]
                                    if let mapsChunk = chunk.maps, let chunkTitle = mapsChunk.title, title.localizedCaseInsensitiveContains(chunkTitle) || chunkTitle.localizedCaseInsensitiveContains(title) {
                                        if let url = mapsChunk.url {
                                            Link(destination: url) {
                                                HStack {
                                                    Image(systemName: "link")
                                                        .font(.caption2)
                                                    Text(chunkTitle)
                                                        .font(.caption2)
                                                }
                                            }
                                            .foregroundStyle(.blue)
                                        } else {
                                            HStack {
                                                Image(systemName: "link")
                                                    .font(.caption2)
                                                Text(chunkTitle)
                                                    .font(.caption2)
                                            }
                                            .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                            .padding(.leading, 32)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
