import SwiftUI

struct ContentView: View {
    var body: some View {
        HSplitView {
            DesignCanvasView()
            PlantLibraryView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
