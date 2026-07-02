/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view for displaying the itinerary.
*/

import FoundationModels
import SwiftUI
import MapKit
import WeatherKit
import PhotosUI

struct LandmarkTripView: View {
    @Environment(ModelData.self) private var modelData
    
    let landmark: Landmark

    var planner: ItineraryPlanner? {
        modelData.itineraryPlanners[landmark.id]
    }
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var identifiedLandmark: LandmarkIdentification?
    @State private var isIdentifying = false
    @State private var showConfirmation = false
    @State private var identifier = VisualLandmarkIdentifier()
    @State private var selectedUIImage: UIImage?
    @State private var scrolledToLandmark: String?
    @State private var flashedLandmark: String?
    @State private var showLiveChat = false

    var body: some View {
        if let error = planner?.error {
            MessageView(error: error, landmark: landmark)
        } else {
            ScrollView {
                ScrollViewReader { proxy in
                    Group {
                        if let planner = planner, planner.isRequested {
                            if let itinerary = planner.itinerary, let days = itinerary.days, !days.isEmpty {
                                ItineraryView(landmark: landmark, itinerary: itinerary, customSpotImages: planner.customSpotImages, lookupHistory: planner.pointOfInterestTool.lookupHistory).padding()
                            } else {
                                ItineraryPlanningView(landmark: landmark, planner: planner)
                            }
                        } else {
                            VStack(alignment: .leading) {
                                LandmarkDescriptionView(landmark: landmark)
                                
                                if let selected = planner?.selectedLandmarks, !selected.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Custom Spots")
                                            .font(.headline)
                                            .padding(.top)
                                        
                                        ForEach(selected, id: \.self) { name in
                                            HStack {
                                                Image(systemName: "mappin.circle.fill")
                                                    .foregroundStyle(.red)
                                                Text(name)
                                                Spacer()
                                                Button(action: {
                                                    planner?.removeSelectedLandmark(name)
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                            .padding(.vertical, 4)
                                            .background(flashedLandmark == name ? Color.yellow.opacity(0.3) : Color.clear)
                                            .id(name)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .onChange(of: scrolledToLandmark) { oldValue, newValue in
                        if let landmark = newValue {
                            withAnimation {
                                proxy.scrollTo(landmark, anchor: .center)
                            }
                        }
                    }
                }
            }
            .scrollDisabled(!(planner?.isRequested ?? false))
            .safeAreaInset(edge: .bottom) {
                ItineraryButton {
                    try await requestItinerary()
                }
            }
            .task {
                if modelData.itineraryPlanners[landmark.id] == nil {
                    let newPlanner = ItineraryPlanner(landmark: landmark)
                    newPlanner.prewarm()
                    modelData.itineraryPlanners[landmark.id] = newPlanner
                }
            }
            .headerStyle(landmark: landmark)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if let itinerary = planner?.itinerary {
                        Button(action: { showLiveChat = true }) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                        }
                    }
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Image(systemName: "camera")
                    }
                }
            }
            .onChange(of: selectedItem) {
                Task {
                    await identifySelectedImage()
                }
            }
            .sheet(isPresented: $showConfirmation) {
                if let identified = identifiedLandmark {
                    LandmarkConfirmationView(
                         identified: identified,
                         image: selectedUIImage,
                         planner: planner,
                         scrolledToLandmark: $scrolledToLandmark,
                         flashedLandmark: $flashedLandmark
                    )
                    .onDisappear {
                        selectedUIImage = nil // Clean up
                    }
                }
            }
            .sheet(isPresented: $showLiveChat) {
                if let itinerary = planner?.itinerary {
                    LiveItineraryView(landmark: landmark, itinerary: itinerary) { dayNumber, action, activityIndex, categoryStr, title, description in
                        planner?.applyLiveModification(
                            dayNumber: dayNumber,
                            action: action,
                            activityIndex: activityIndex,
                            categoryStr: categoryStr,
                            title: title,
                            description: description
                        )
                    }
                }
            }
            .overlay {
                if isIdentifying {
                    ProgressView("Identifying landmark...")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    func identifySelectedImage() async {
        guard let selectedItem = selectedItem else { return }
        isIdentifying = true
        
        do {
            if let data = try await selectedItem.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                self.selectedUIImage = image
                identifiedLandmark = try await identifier.identifyLandmark(in: image)
                showConfirmation = true
            }
        } catch {
            Logging.general.error("Failed to identify landmark: \(error.localizedDescription)")
        }
        
        isIdentifying = false
        self.selectedItem = nil // Reset picker
    }
    
    func requestItinerary() async throws {
        do {
            try await planner?.suggestItinerary(dayCount: 3)
        } catch {
            planner?.error = error
        }
    }
}

struct ItineraryButton: View {
    @State private var showButton: Bool = false
    let closure: () async throws -> Void

    var body: some View {
        VStack {
            Button {
                showButton = false
                Task { @MainActor in
                    try await closure()
                }
            }
            label: {
                Label("Generate Itinerary", systemImage: "sparkles")
                    .fontWeight(.bold)
                    .padding()
            }
            .buttonStyle(.bordered)
            .padding()
            .opacity(showButton ? 1 : 0)
            .animation(
                .easeInOut(duration: 0.5),
                value: showButton
            )
            .onAppear {
                showButton = true
            }
            .transition(.opacity)
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
    }
}

struct ItineraryHeader: View {
    let destination: Landmark
    let customImage: UIImage?
    
    init(destination: Landmark, customImage: UIImage? = nil) {
        self.destination = destination
        self.customImage = customImage
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if let customImage = customImage {
                Image(uiImage: customImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                Image(uiImage: customImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .blur(radius: 16, opaque: true)
                    .saturation(1.3)
                    .brightness(0.15)
                    .mask {
                        Rectangle()
                            .fill(
                                Gradient(stops: [
                                    .init(color: .clear, location: 0.5),
                                    .init(color: .white, location: 0.6)
                                ])
                                .colorSpace(.perceptual)
                            )
                    }
            } else {
                Image(destination.backgroundImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                Image("\(destination.backgroundImageName)-thumb")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .blur(radius: 16, opaque: true)
                    .saturation(1.3)
                    .brightness(0.15)
                    .mask {
                        Rectangle()
                            .fill(
                                Gradient(stops: [
                                    .init(color: .clear, location: 0.5),
                                    .init(color: .white, location: 0.6)
                                ])
                                .colorSpace(.perceptual)
                            )
                    }
            }
        }
        .frame(height: 420)
        .compositingGroup()
        .mask {
            Rectangle()
                .fill(
                    Gradient(stops: [
                        .init(color: .white, location: 0.3),
                        .init(color: .clear, location: 1.0)
                    ])
                    .colorSpace(.perceptual)
                )
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        #if os(iOS)
        .background(Color(uiColor: .systemGray6))
        #endif
    }
}
