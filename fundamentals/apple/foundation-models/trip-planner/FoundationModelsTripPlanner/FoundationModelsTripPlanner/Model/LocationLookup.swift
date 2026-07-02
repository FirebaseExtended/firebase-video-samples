/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A class used to fetch the weather for a location using MapKit and WeatherKit.
*/
import MapKit
import WeatherKit

@Observable @MainActor
final class LocationLookup {
    private(set) var item: MKMapItem?
    private(set) var temperatureString: String?

    func performLookup(location: String) {
        Task {
            let item = await self.mapItem(atLocation: location)
            if let location = item?.location {
                self.temperatureString = await self.weather(atLocation: location)
            }
        }
    }
    
    private func mapItem(atLocation location: String) async -> MKMapItem? {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = location
        
        let search = MKLocalSearch(request: request)
        do {
            return try await search.start().mapItems.first
        } catch {
            Logging.general.error("Failed to look up location: \(location). Error: \(error)")
        }
        return nil
    }
    
    private func weather(atLocation location: CLLocation) async -> String {
        do {
            let weather = try await WeatherService.shared.weather(
                for: location,
                including: .current
            )
            let temperature = weather.temperature
            let formatter = MeasurementFormatter()
            formatter.unitOptions = .providedUnit
            formatter.numberFormatter.maximumFractionDigits = 1
            return formatter.string(from: temperature)
        } catch {
            Logging.general.error("Couldn't fetch weather: \(error.localizedDescription)")
            return "unavailable"
        }
    }
}
