import SwiftUI
import UniformTypeIdentifiers

struct DesignCanvasView: View {
    @State private var backgroundImage: Image?
    @State private var showingImagePicker = false
    @State private var placedPlants: [PlacedPlant] = []

    var body: some View {
        ZStack {
            if let backgroundImage = backgroundImage {
                backgroundImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.gray.opacity(0.2)
            }

            if backgroundImage == nil {
                VStack {
                    Text("Design Canvas")
                        .font(.title)
                    Button("Select Background Image") {
                        self.showingImagePicker = true
                    }
                }
            }

            ForEach(placedPlants) { placedPlant in
                Image(systemName: placedPlant.plant.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .position(placedPlant.position)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if let index = placedPlants.firstIndex(where: { $0.id == placedPlant.id }) {
                                    placedPlants[index].position = value.location
                                }
                            }
                    )
            }
        }
        .onDrop(of: [UTType.data], isTargeted: nil) { providers, location in
            guard let provider = providers.first else { return false }
            provider.loadObject(ofClass: Plant.self) { plant, _ in
                if let plant = plant {
                    DispatchQueue.main.async {
                        let newPlant = PlacedPlant(plant: plant, position: location)
                        placedPlants.append(newPlant)
                    }
                }
            }
            return true
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(image: self.$backgroundImage)
        }
    }
}

struct DesignCanvasView_Previews: PreviewProvider {
    static var previews: some View {
        DesignCanvasView()
    }
}
