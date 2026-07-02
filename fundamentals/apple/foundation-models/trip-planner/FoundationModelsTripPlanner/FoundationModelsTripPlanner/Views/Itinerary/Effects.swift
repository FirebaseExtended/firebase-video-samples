/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A structure for creating custom visual effects with SwiftUI.
*/

import SwiftUI

struct HeaderStyle: ViewModifier {
    let landmark: Landmark
    
    func body(content: Content) -> some View {
        content
            .background(alignment: .top) {
                ItineraryHeader(destination: landmark)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
    
struct CardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(colorScheme == .dark ? AnyShapeStyle(.thinMaterial) : AnyShapeStyle(.white))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.08), radius: 4, y: 2)
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.12 : 0.08), radius: 32, y: 12)
    }
}

struct TagStyleModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            .clipShape(Capsule())
            .background(colorScheme == .dark ? AnyShapeStyle(.thinMaterial) : AnyShapeStyle(.white.opacity(0.3)))
            .clipShape(Capsule())
    }
}

struct RationaleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .transition(.blurReplace)
            .padding(12)
            .card()
            .padding(.top)
    }
}

struct ItineraryModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 120)
            .padding(.bottom)
    }
}

struct BlurredBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .padding(.top, 16)
            .background {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .mask {
                        LinearGradient(colors: [.clear, .white, .white], startPoint: .top, endPoint: .bottom)
                    }
                    .overlay {
                        LinearGradient(colors: [
                            overlayColor.opacity(0),
                            overlayColor.opacity(0.6)
                        ], startPoint: .top, endPoint: .bottom)
                    }
            }
    }
    
    var overlayColor: Color {
        if colorScheme == .light {
            return .white
        } else {
            #if os(macOS)
            return Color(nsColor: .windowBackgroundColor)
            #else
            return Color(uiColor: .systemBackground)
            #endif
        }
    }
}

struct ActivityIcon: View {
    let symbolName: String?
    @ScaledMetric var iconSize: CGFloat = 32
    
    var body: some View {
        if let symbolName {
            Image(systemName: symbolName)
                .foregroundStyle(.white)
                .frame(minWidth: iconSize, minHeight: iconSize)
                .background {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [.indigo, .indigo.mix(with: .black, by: 0.2)]),
                                center: .init(x: 0.3, y: 0.3),
                                startRadius: 0,
                                endRadius: 32
                            )
                        )
                        .shadow(color: .indigo.opacity(0.3), radius: 8, x: 2, y: 4)
                }
                .transition(.scale)
        }
    }
}

extension View {
    
    func rationaleStyle() -> some View {
        modifier(RationaleModifier())
    }
    
    func itineraryStyle() -> some View {
        modifier(ItineraryModifier())
    }
    
    func card() -> some View {
        modifier(CardModifier())
    }
    
    func tagStyle() -> some View {
        modifier(TagStyleModifier())
    }
    
    func blurredBackground() -> some View {
        modifier(BlurredBackgroundModifier())
    }
    
    func headerStyle(landmark: Landmark) -> some View {
        modifier(HeaderStyle(landmark: landmark))
    }
}
