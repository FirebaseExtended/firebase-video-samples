/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A Generable structure that defines a landmark identified from an image.
*/

import Foundation
import FoundationModels

@Generable
struct LandmarkIdentification: Codable {
    let name: String
    let description: String
}
