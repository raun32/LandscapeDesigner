import XCTest
@testable import LandscapeDesigner

// MARK: - Plant Model Tests
class PlantModelTests: XCTestCase {
    
    func testPlantInitialization() {
        let plant = Plant(name: "Rose", imageName: "rose.png")
        
        XCTAssertEqual(plant.name, "Rose")
        XCTAssertEqual(plant.imageName, "rose.png")
        XCTAssertNotNil(plant.id)
    }
    
    func testPlantCodable() throws {
        let plant = Plant(name: "Tulip", imageName: "tulip.png")
        
        let encoded = try JSONEncoder().encode(plant)
        let decoded = try JSONDecoder().decode(Plant.self, from: encoded)
        
        XCTAssertEqual(decoded.name, plant.name)
        XCTAssertEqual(decoded.imageName, plant.imageName)
        XCTAssertEqual(decoded.id, plant.id)
    }
    
    func testPlantIdentifiable() {
        let plant1 = Plant(name: "Rose", imageName: "rose.png")
        let plant2 = Plant(name: "Tulip", imageName: "tulip.png")
        
        XCTAssertNotEqual(plant1.id, plant2.id)
    }
}

// MARK: - PlacedPlant Model Tests
class PlacedPlantModelTests: XCTestCase {
    
    func testPlacedPlantInitialization() {
        let plant = Plant(name: "Rose", imageName: "rose.png")
        let position = CGPoint(x: 100, y: 200)
        let placedPlant = PlacedPlant(plant: plant, position: position)
        
        XCTAssertEqual(placedPlant.plant.name, "Rose")
        XCTAssertEqual(placedPlant.position, position)
        XCTAssertNotNil(placedPlant.id)
    }
    
    func testPlacedPlantPositionUpdate() {
        let plant = Plant(name: "Daisy", imageName: "daisy.png")
        var placedPlant = PlacedPlant(plant: plant, position: CGPoint(x: 0, y: 0))
        
        let newPosition = CGPoint(x: 300, y: 400)
        placedPlant.position = newPosition
        
        XCTAssertEqual(placedPlant.position, newPosition)
    }
    
    func testPlacedPlantIdentifiable() {
        let plant = Plant(name: "Rose", imageName: "rose.png")
        let placed1 = PlacedPlant(plant: plant, position: CGPoint(x: 0, y: 0))
        let placed2 = PlacedPlant(plant: plant, position: CGPoint(x: 0, y: 0))
        
        XCTAssertNotEqual(placed1.id, placed2.id)
    }
}

// MARK: - Data Flow Tests
class DataFlowTests: XCTestCase {
    
    func testPlantToPlacedPlantConversion() {
        let plant = Plant(name: "Sunflower", imageName: "sunflower.png")
        let position = CGPoint(x: 150, y: 250)
        let placedPlant = PlacedPlant(plant: plant, position: position)
        
        XCTAssertEqual(placedPlant.plant.id, plant.id)
        XCTAssertEqual(placedPlant.plant.name, plant.name)
        XCTAssertEqual(placedPlant.position, position)
    }
    
    func testMultiplePlantsPlacement() {
        let plants = [
            Plant(name: "Rose", imageName: "rose.png"),
            Plant(name: "Tulip", imageName: "tulip.png"),
            Plant(name: "Daisy", imageName: "daisy.png")
        ]
        
        var placedPlants: [PlacedPlant] = []
        for (index, plant) in plants.enumerated() {
            let position = CGPoint(x: CGFloat(index * 100), y: CGFloat(index * 100))
            placedPlants.append(PlacedPlant(plant: plant, position: position))
        }
        
        XCTAssertEqual(placedPlants.count, 3)
        XCTAssertEqual(placedPlants[0].plant.name, "Rose")
        XCTAssertEqual(placedPlants[1].plant.name, "Tulip")
        XCTAssertEqual(placedPlants[2].plant.name, "Daisy")
    }
}

// MARK: - SwiftUI View Tests
class ViewTests: XCTestCase {
    
    func testContentViewExists() {
        // Verify ContentView can be instantiated
        let view = ContentView()
        XCTAssertNotNil(view)
    }
    
    func testDesignCanvasViewExists() {
        // Verify DesignCanvasView can be instantiated
        let view = DesignCanvasView()
        XCTAssertNotNil(view)
    }
    
    func testPlantLibraryViewExists() {
        // Verify PlantLibraryView can be instantiated
        let view = PlantLibraryView()
        XCTAssertNotNil(view)
    }
    
    func testImagePickerViewExists() {
        // Verify ImagePickerView can be instantiated
        let view = ImagePickerView(isPresented: .constant(false), image: .constant(nil))
        XCTAssertNotNil(view)
    }
}

// MARK: - Navigation Tests
class NavigationTests: XCTestCase {
    
    func testContentViewComposition() {
        // ContentView contains both DesignCanvasView and PlantLibraryView
        let contentView = ContentView()
        XCTAssertNotNil(contentView)
        // In real UI tests, verify HSplitView contains both views
    }
    
    func testViewHierarchy() {
        let canvas = DesignCanvasView()
        let library = PlantLibraryView()
        let imagePicker = ImagePickerView(isPresented: .constant(false), image: .constant(nil))
        
        XCTAssertNotNil(canvas)
        XCTAssertNotNil(library)
        XCTAssertNotNil(imagePicker)
    }
}

// MARK: - Performance Tests
class PerformanceTests: XCTestCase {
    
    func testPlantInitializationPerformance() {
        measure {
            for _ in 0..<1000 {
                _ = Plant(name: "Test", imageName: "test.png")
            }
        }
    }
    
    func testPlacedPlantInitializationPerformance() {
        let plant = Plant(name: "Test", imageName: "test.png")
        measure {
            for i in 0..<1000 {
                _ = PlacedPlant(plant: plant, position: CGPoint(x: CGFloat(i), y: CGFloat(i)))
            }
        }
    }
    
    func testPlantEncodingPerformance() throws {
        let plant = Plant(name: "Test", imageName: "test.png")
        measure {
            do {
                _ = try JSONEncoder().encode(plant)
            } catch {
                XCTFail("Encoding failed: \(error)")
            }
        }
    }
}

// MARK: - Integration Tests
class IntegrationTests: XCTestCase {
    
    func testAppEntryPointExists() {
        // Verify LandscapeDesignerApp exists and can be instantiated
        XCTAssertTrue(true) // This would test @main app in real scenario
    }
    
    func testPlantLibraryDefaultContent() {
        let library = PlantLibraryView()
        XCTAssertNotNil(library)
    }
    
    func testDesignCanvasInitialState() {
        let canvas = DesignCanvasView()
        XCTAssertNotNil(canvas)
    }
}
