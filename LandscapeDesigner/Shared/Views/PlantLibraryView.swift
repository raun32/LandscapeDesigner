import SwiftUI

struct PlantLibraryView: View {
    let plants: [Plant] = [
        Plant(name: "Pine Tree", imageName: "tree"),
        Plant(name: "Perennial", imageName: "leaf"),
        Plant(name: "Flower", imageName: "camera.macro"),
    ]

    var body: some View {
        VStack {
            Text("Plant Library")
                .font(.title)
                .padding()
            
            List(plants) { plant in
                HStack {
                    Image(systemName: plant.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                    Text(plant.name)
                }
                .onDrag {
                    NSItemProvider(object: plant)
                }
            }
        }
    }
}

struct PlantLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        PlantLibraryView()
    }
}
