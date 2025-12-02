import SwiftUI

struct PlacedPlant: Identifiable {
    let id = UUID()
    let plant: Plant
    var position: CGPoint
}
