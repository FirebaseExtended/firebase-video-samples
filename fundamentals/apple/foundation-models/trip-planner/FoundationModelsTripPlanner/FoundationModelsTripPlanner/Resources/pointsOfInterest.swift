// xcode: set sdk=iOS

/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A function to fetch points of interest for a category
*/

extension FindPointsOfInterestTool {
    func suggestions(category: Category) -> [String] {
        switch category {
        case .restaurant : ["Restaurant 1", "Restaurant 2", "Restaurant 3"]
        case .campground : ["Campground 1", "Campground 2", "Campground 3"]
        case .hotel : ["Hotel 1", "Hotel 2", "Hotel 3"]
        case .cafe : ["Cafe 1", "Cafe 2", "Cafe 3"]
        case .museum : ["Museum 1", "Museum 2", "Museum 3"]
        case .marina : ["Marina 1", "Marina 2", "Marina 3"]
        case .nationalMonument : ["The National Rock 1", "The National Rock 2", "The National Rock 3"]
        }
    }
}
