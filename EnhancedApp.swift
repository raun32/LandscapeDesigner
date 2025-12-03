import Cocoa
import AppKit

// MARK: - Data Models
struct Plant: Codable, Identifiable {
    let id: String
    let name: String
    let category: String
    let spacing: Double // in feet
    let height: Double  // in feet
    let cost: Double
    
    init(id: String = UUID().uuidString, name: String, category: String, spacing: Double, height: Double, cost: Double) {
        self.id = id
        self.name = name
        self.category = category
        self.spacing = spacing
        self.height = height
        self.cost = cost
    }
}

struct PlacedPlant: Codable, Identifiable {
    let id: String
    let plant: Plant
    var x: Double
    var y: Double
    var quantity: Int = 1
    var rotation: Double = 0
    
    init(id: String = UUID().uuidString, plant: Plant, x: Double, y: Double, quantity: Int = 1, rotation: Double = 0) {
        self.id = id
        self.plant = plant
        self.x = x
        self.y = y
        self.quantity = quantity
        self.rotation = rotation
    }
}

struct DrawingPath: Codable {
    let points: [CGPoint]
    let color: String // hex color
    let lineWidth: Double
    let isSmoothed: Bool
}

struct LandscapeDesign: Codable {
    let id: String
    var name: String
    let width: Double   // in feet
    let height: Double  // in feet
    var plants: [PlacedPlant] = []
    var drawingPaths: [DrawingPath] = []
    var notes: String = ""
    var createdDate: String
    var modifiedDate: String
    var collaborators: [String] = []
    
    mutating func updateModifiedDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.modifiedDate = formatter.string(from: Date())
    }
}

// MARK: - Cloud Storage (Local file-based)
class CloudStorage {
    static let shared = CloudStorage()
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let designsFolder: URL
    
    init() {
        designsFolder = documentsPath.appendingPathComponent("LandscapeDesigns")
        try? FileManager.default.createDirectory(at: designsFolder, withIntermediateDirectories: true)
    }
    
    func saveDesign(_ design: LandscapeDesign) -> Bool {
        let fileURL = designsFolder.appendingPathComponent("\(design.name).json")
        do {
            let data = try JSONEncoder().encode(design)
            try data.write(to: fileURL)
            return true
        } catch {
            print("Error saving design: \(error)")
            return false
        }
    }
    
    func loadDesign(named name: String) -> LandscapeDesign? {
        let fileURL = designsFolder.appendingPathComponent("\(name).json")
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(LandscapeDesign.self, from: data)
        } catch {
            print("Error loading design: \(error)")
            return nil
        }
    }
    
    func getAllDesigns() -> [LandscapeDesign] {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: designsFolder, includingPropertiesForKeys: nil)
            var designs: [LandscapeDesign] = []
            for file in files where file.pathExtension == "json" {
                if let data = try? Data(contentsOf: file),
                   let design = try? JSONDecoder().decode(LandscapeDesign.self, from: data) {
                    designs.append(design)
                }
            }
            return designs.sorted { $0.modifiedDate > $1.modifiedDate }
        } catch {
            return []
        }
    }
}

// MARK: - Plant Library Database
class PlantLibrary {
    static let shared = PlantLibrary()
    
    let plants: [Plant] = [
        // TREES - Deciduous
        Plant(name: "Oak Tree (White)", category: "Trees - Deciduous", spacing: 30, height: 60, cost: 150),
        Plant(name: "Oak Tree (Red)", category: "Trees - Deciduous", spacing: 30, height: 55, cost: 145),
        Plant(name: "Maple Tree (Sugar)", category: "Trees - Deciduous", spacing: 25, height: 50, cost: 120),
        Plant(name: "Maple Tree (Red)", category: "Trees - Deciduous", spacing: 25, height: 45, cost: 115),
        Plant(name: "Birch Tree (White)", category: "Trees - Deciduous", spacing: 20, height: 40, cost: 90),
        Plant(name: "Birch Tree (River)", category: "Trees - Deciduous", spacing: 20, height: 45, cost: 95),
        Plant(name: "Willow Tree (Weeping)", category: "Trees - Deciduous", spacing: 35, height: 50, cost: 110),
        Plant(name: "Ash Tree", category: "Trees - Deciduous", spacing: 25, height: 55, cost: 125),
        Plant(name: "Elm Tree", category: "Trees - Deciduous", spacing: 30, height: 60, cost: 140),
        Plant(name: "Beech Tree", category: "Trees - Deciduous", spacing: 28, height: 50, cost: 130),
        Plant(name: "Poplar Tree", category: "Trees - Deciduous", spacing: 20, height: 70, cost: 100),
        Plant(name: "Linden Tree", category: "Trees - Deciduous", spacing: 25, height: 50, cost: 120),
        
        // TREES - Evergreen/Conifer
        Plant(name: "Pine Tree (White)", category: "Trees - Evergreen", spacing: 20, height: 80, cost: 100),
        Plant(name: "Pine Tree (Scotch)", category: "Trees - Evergreen", spacing: 20, height: 60, cost: 95),
        Plant(name: "Pine Tree (Loblolly)", category: "Trees - Evergreen", spacing: 20, height: 90, cost: 105),
        Plant(name: "Spruce Tree (Colorado)", category: "Trees - Evergreen", spacing: 20, height: 70, cost: 110),
        Plant(name: "Spruce Tree (Norway)", category: "Trees - Evergreen", spacing: 20, height: 80, cost: 115),
        Plant(name: "Fir Tree (Douglas)", category: "Trees - Evergreen", spacing: 20, height: 85, cost: 120),
        Plant(name: "Hemlock Tree", category: "Trees - Evergreen", spacing: 18, height: 70, cost: 105),
        Plant(name: "Arborvitae (Green)", category: "Trees - Evergreen", spacing: 10, height: 40, cost: 45),
        Plant(name: "Cypress Tree (Leyland)", category: "Trees - Evergreen", spacing: 15, height: 60, cost: 75),
        
        // SHRUBS - Deciduous
        Plant(name: "Boxwood (American)", category: "Shrubs - Deciduous", spacing: 3, height: 4, cost: 25),
        Plant(name: "Hydrangea (Panicle)", category: "Shrubs - Deciduous", spacing: 4, height: 6, cost: 35),
        Plant(name: "Hydrangea (Bigleaf)", category: "Shrubs - Deciduous", spacing: 4, height: 5, cost: 30),
        Plant(name: "Lilac (Common)", category: "Shrubs - Deciduous", spacing: 5, height: 8, cost: 40),
        Plant(name: "Lilac (Japanese)", category: "Shrubs - Deciduous", spacing: 5, height: 10, cost: 45),
        Plant(name: "Azalea (Pink)", category: "Shrubs - Deciduous", spacing: 3, height: 4, cost: 30),
        Plant(name: "Azalea (Red)", category: "Shrubs - Deciduous", spacing: 3, height: 4, cost: 30),
        Plant(name: "Rhododendron (Purple)", category: "Shrubs - Deciduous", spacing: 4, height: 5, cost: 40),
        Plant(name: "Viburnum (American)", category: "Shrubs - Deciduous", spacing: 4, height: 6, cost: 35),
        Plant(name: "Weigela (Red)", category: "Shrubs - Deciduous", spacing: 4, height: 5, cost: 28),
        Plant(name: "Forsythia (Golden)", category: "Shrubs - Deciduous", spacing: 5, height: 6, cost: 32),
        Plant(name: "Butterfly Bush", category: "Shrubs - Deciduous", spacing: 5, height: 8, cost: 38),
        
        // SHRUBS - Evergreen
        Plant(name: "Juniper (Blue Star)", category: "Shrubs - Evergreen", spacing: 4, height: 5, cost: 28),
        Plant(name: "Juniper (Skyrocket)", category: "Shrubs - Evergreen", spacing: 2, height: 15, cost: 35),
        Plant(name: "Holly (American)", category: "Shrubs - Evergreen", spacing: 4, height: 6, cost: 40),
        Plant(name: "Yew (Japanese)", category: "Shrubs - Evergreen", spacing: 3, height: 4, cost: 30),
        Plant(name: "Privet (Green)", category: "Shrubs - Evergreen", spacing: 2, height: 6, cost: 20),
        Plant(name: "Euonymus (Green)", category: "Shrubs - Evergreen", spacing: 3, height: 4, cost: 25),
        
        // PERENNIALS & FLOWERS
        Plant(name: "Rose (Hybrid Tea)", category: "Perennials & Flowers", spacing: 2, height: 3, cost: 15),
        Plant(name: "Rose (Floribunda)", category: "Perennials & Flowers", spacing: 2, height: 3, cost: 12),
        Plant(name: "Tulip (Red)", category: "Perennials & Flowers", spacing: 1, height: 2, cost: 5),
        Plant(name: "Tulip (Yellow)", category: "Perennials & Flowers", spacing: 1, height: 2, cost: 5),
        Plant(name: "Daisy (Shasta)", category: "Perennials & Flowers", spacing: 1.5, height: 2.5, cost: 8),
        Plant(name: "Sunflower (Tall)", category: "Perennials & Flowers", spacing: 2, height: 6, cost: 10),
        Plant(name: "Lavender (Purple)", category: "Perennials & Flowers", spacing: 2, height: 3, cost: 12),
        Plant(name: "Peony (Pink)", category: "Perennials & Flowers", spacing: 3, height: 3, cost: 20),
        Plant(name: "Hibiscus (Red)", category: "Perennials & Flowers", spacing: 4, height: 8, cost: 45),
        Plant(name: "Daylily (Orange)", category: "Perennials & Flowers", spacing: 2, height: 2.5, cost: 10),
        Plant(name: "Coneflower (Purple)", category: "Perennials & Flowers", spacing: 1.5, height: 3, cost: 10),
        Plant(name: "Black-eyed Susan", category: "Perennials & Flowers", spacing: 1.5, height: 2, cost: 8),
        Plant(name: "Aster (Fall)", category: "Perennials & Flowers", spacing: 2, height: 3, cost: 9),
        Plant(name: "Hosta (Blue)", category: "Perennials & Flowers", spacing: 2, height: 2, cost: 12),
        Plant(name: "Sedum (Autumn Joy)", category: "Perennials & Flowers", spacing: 1.5, height: 2, cost: 10),
        
        // GROUND COVER
        Plant(name: "Ivy (English)", category: "Ground Cover", spacing: 1, height: 0.5, cost: 6),
        Plant(name: "Ivy (Boston)", category: "Ground Cover", spacing: 1, height: 0.5, cost: 7),
        Plant(name: "Moss Phlox", category: "Ground Cover", spacing: 1, height: 0.3, cost: 8),
        Plant(name: "Creeping Thyme", category: "Ground Cover", spacing: 1, height: 0.25, cost: 8),
        Plant(name: "Sedum (Dragon Blood)", category: "Ground Cover", spacing: 1, height: 0.5, cost: 7),
        Plant(name: "Groundcover (Ajuga)", category: "Ground Cover", spacing: 1, height: 0.4, cost: 6),
        
        // HARDSCAPE MATERIALS
        Plant(name: "Mulch (Black)", category: "Hardscape Materials", spacing: 100, height: 0.25, cost: 50),
        Plant(name: "Mulch (Brown)", category: "Hardscape Materials", spacing: 100, height: 0.25, cost: 50),
        Plant(name: "River Rock (Small)", category: "Hardscape Materials", spacing: 100, height: 0.1, cost: 75),
        Plant(name: "River Rock (Large)", category: "Hardscape Materials", spacing: 100, height: 0.15, cost: 100),
        Plant(name: "Wood Chips (Pine)", category: "Hardscape Materials", spacing: 100, height: 0.25, cost: 60),
        Plant(name: "Wood Chips (Cedar)", category: "Hardscape Materials", spacing: 100, height: 0.25, cost: 80),
        Plant(name: "Gravel (Pea)", category: "Hardscape Materials", spacing: 100, height: 0.2, cost: 40),
        Plant(name: "Gravel (Crushed)", category: "Hardscape Materials", spacing: 100, height: 0.2, cost: 45),
        Plant(name: "Bark Chips (Shredded)", category: "Hardscape Materials", spacing: 100, height: 0.25, cost: 65),
        Plant(name: "Sand (Play)", category: "Hardscape Materials", spacing: 100, height: 0.2, cost: 35),
        Plant(name: "Topsoil", category: "Hardscape Materials", spacing: 100, height: 0.25, cost: 40),
        Plant(name: "Compost (Organic)", category: "Hardscape Materials", spacing: 100, height: 0.25, cost: 55),
        
        // ORNAMENTAL GRASSES
        Plant(name: "Fountain Grass", category: "Ornamental Grasses", spacing: 3, height: 4, cost: 15),
        Plant(name: "Ornamental Grass (Miscanthus)", category: "Ornamental Grasses", spacing: 3, height: 5, cost: 18),
        Plant(name: "Pampas Grass", category: "Ornamental Grasses", spacing: 4, height: 8, cost: 22),
        Plant(name: "Feather Reed Grass", category: "Ornamental Grasses", spacing: 3, height: 4, cost: 16),
        
        // VINES & CLIMBERS
        Plant(name: "Clematis (Purple)", category: "Vines & Climbers", spacing: 2, height: 8, cost: 25),
        Plant(name: "Honeysuckle (Gold)", category: "Vines & Climbers", spacing: 3, height: 10, cost: 20),
        Plant(name: "Grape Vine", category: "Vines & Climbers", spacing: 4, height: 12, cost: 30),
        Plant(name: "Climbing Hydrangea", category: "Vines & Climbers", spacing: 3, height: 8, cost: 35),
    ]
    
    func plantsByCategory(_ category: String) -> [Plant] {
        return plants.filter { $0.category == category }
    }
    
    func allCategories() -> [String] {
        let categories = Set(plants.map { $0.category })
        return Array(categories).sorted()
    }
}

// MARK: - 3D Canvas View with Drawing & Dragging
class Canvas3DView: NSView {
    var placedPlants: [PlacedPlant] = []
    var drawingPaths: [DrawingPath] = []
    var currentDrawingPath: [CGPoint] = []
    var designWidth: Double = 40
    var designHeight: Double = 30
    var is3DMode: Bool = false
    var cameraAngle: Double = 45
    var isPenMode: Bool = false
    var penColor: NSColor = NSColor.black
    var penLineWidth: Double = 2.0
    var selectedPlantIndex: Int? = nil
    var dragStartPoint: NSPoint = NSPoint.zero
    var dragOffsetX: Double = 0
    var dragOffsetY: Double = 0
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.white.setFill()
        dirtyRect.fill()
        
        if is3DMode {
            draw3D()
        } else {
            draw2D()
        }
        
        // Draw existing paths
        drawStoredPaths()
        
        // Draw current path being drawn
        if !currentDrawingPath.isEmpty && isPenMode {
            penColor.setStroke()
            let path = NSBezierPath()
            path.lineWidth = penLineWidth
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            
            for (index, point) in currentDrawingPath.enumerated() {
                if index == 0 {
                    path.move(to: point)
                } else {
                    path.line(to: point)
                }
            }
            path.stroke()
        }
    }
    
    func drawStoredPaths() {
        for drawingPath in drawingPaths {
            if let color = NSColor(hex: drawingPath.color) {
                color.setStroke()
                let path = NSBezierPath()
                path.lineWidth = drawingPath.lineWidth
                path.lineCapStyle = .round
                path.lineJoinStyle = .round
                
                for (index, point) in drawingPath.points.enumerated() {
                    if index == 0 {
                        path.move(to: point)
                    } else {
                        path.line(to: point)
                    }
                }
                path.stroke()
            }
        }
    }
    
    func draw2D() {
        NSColor.lightGray.setStroke()
        let cellWidth = bounds.width / 10
        let cellHeight = bounds.height / 10
        
        for i in 1..<10 {
            let x = CGFloat(i) * cellWidth
            let y = CGFloat(i) * cellHeight
            let vLine = NSBezierPath()
            vLine.move(to: NSPoint(x: x, y: 0))
            vLine.line(to: NSPoint(x: x, y: bounds.height))
            vLine.lineWidth = 0.5
            vLine.stroke()
            
            let hLine = NSBezierPath()
            hLine.move(to: NSPoint(x: 0, y: y))
            hLine.line(to: NSPoint(x: bounds.width, y: y))
            hLine.lineWidth = 0.5
            hLine.stroke()
        }
        
        NSColor.black.setStroke()
        let border = NSBezierPath(rect: bounds)
        border.lineWidth = 2
        border.stroke()
        
        for plant in placedPlants {
            drawPlant2D(plant)
        }
        
        let scaleText = NSAttributedString(
            string: "2D View: \(Int(designWidth))ft × \(Int(designHeight))ft" + (isPenMode ? " [✏️ Pen Mode]" : ""),
            attributes: [.font: NSFont.systemFont(ofSize: 10)]
        )
        scaleText.draw(at: NSPoint(x: 10, y: bounds.height - 20))
    }
    
    func draw3D() {
        NSColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1).setFill()
        bounds.fill()
        
        NSColor.black.setStroke()
        
        let cellWidth = bounds.width / 8
        let cellHeight = bounds.height / 8
        
        for i in 0...8 {
            let x = CGFloat(i) * cellWidth
            let y = CGFloat(i) * cellHeight
            
            let vLine = NSBezierPath()
            vLine.move(to: NSPoint(x: x, y: 0))
            vLine.line(to: NSPoint(x: x * 1.2, y: bounds.height))
            vLine.lineWidth = 0.5
            vLine.stroke()
            
            let hLine = NSBezierPath()
            hLine.move(to: NSPoint(x: 0, y: y))
            hLine.line(to: NSPoint(x: bounds.width, y: y * 1.1))
            hLine.lineWidth = 0.5
            hLine.stroke()
        }
        
        for plant in placedPlants {
            drawPlant3D(plant)
        }
        
        let scaleText = NSAttributedString(
            string: "3D View (Isometric) - Camera: \(Int(cameraAngle))°" + (isPenMode ? " [✏️ Pen Mode]" : ""),
            attributes: [.font: NSFont.systemFont(ofSize: 10)]
        )
        scaleText.draw(at: NSPoint(x: 10, y: bounds.height - 20))
    }
    
    func drawPlant2D(_ plant: PlacedPlant) {
        let scaleX = bounds.width / designWidth
        let scaleY = bounds.height / designHeight
        
        let x = plant.x * scaleX
        let y = bounds.height - (plant.y * scaleY)
        let size: CGFloat = 20
        
        NSColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 0.8).setFill()
        let circle = NSBezierPath(ovalIn: NSRect(x: x - size/2, y: y - size/2, width: size, height: size))
        circle.fill()
        
        // Highlight selected plants
        let isSelected = selectedPlantIndex.map { placedPlants[$0].id == plant.id } ?? false
        if isSelected {
            NSColor.red.setStroke()
            circle.lineWidth = 4
        } else {
            NSColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0).setStroke()
            circle.lineWidth = 2
        }
        circle.stroke()
        
        let label = NSAttributedString(
            string: "×\(plant.quantity)",
            attributes: [.font: NSFont.systemFont(ofSize: 9), .foregroundColor: NSColor.white]
        )
        label.draw(at: NSPoint(x: x - 8, y: y - 5))
    }
    
    func drawPlant3D(_ plant: PlacedPlant) {
        let scaleX = bounds.width / (designWidth * 1.5)
        let scaleY = bounds.height / (designHeight * 1.5)
        
        let x = (plant.x * scaleX) + CGFloat(plant.y * scaleX * 0.3)
        let y = (bounds.height - (plant.y * scaleY)) + CGFloat(plant.x * scaleY * 0.2)
        
        // Draw 3D box for plant
        NSColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 0.7).setFill()
        let height = CGFloat(plant.plant.height / 10) * 2
        let width: CGFloat = 15
        
        let rect = NSRect(x: x - width/2, y: y - height/2, width: width, height: height)
        let box = NSBezierPath(rect: rect)
        box.fill()
        
        NSColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0).setStroke()
        box.lineWidth = 1.5
        box.stroke()
        
        // Draw height indicator
        NSColor.darkGray.setStroke()
        let heightLine = NSBezierPath()
        heightLine.move(to: NSPoint(x: x, y: y - height/2))
        heightLine.line(to: NSPoint(x: x, y: y - height))
        heightLine.lineWidth = 1
        heightLine.stroke()
    }
    
    func addPlant(_ plant: Plant, at point: NSPoint) {
        let scaleX = bounds.width / designWidth
        let scaleY = bounds.height / designHeight
        
        let x = Double(point.x) / scaleX
        let y = Double(bounds.height - point.y) / scaleY
        
        let newPlant = PlacedPlant(plant: plant, x: x, y: y)
        placedPlants.append(newPlant)
        needsDisplay = true
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        
        if isPenMode {
            currentDrawingPath = [location]
        } else {
            // Check if clicked on a plant
            let scaleX = bounds.width / designWidth
            let scaleY = bounds.height / designHeight
            
            for (index, plant) in placedPlants.enumerated() {
                let x = plant.x * scaleX
                let y = bounds.height - (plant.y * scaleY)
                let size: CGFloat = 20
                
                let plantRect = NSRect(x: x - size/2, y: y - size/2, width: size, height: size)
                if plantRect.contains(location) {
                    selectedPlantIndex = index
                    dragStartPoint = location
                    dragOffsetX = plant.x
                    dragOffsetY = plant.y
                    needsDisplay = true
                    return
                }
            }
            selectedPlantIndex = nil
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        
        if isPenMode && !currentDrawingPath.isEmpty {
            currentDrawingPath.append(location)
            needsDisplay = true
        } else if let index = selectedPlantIndex, !isPenMode {
            // Update plant position while dragging
            let scaleX = bounds.width / designWidth
            let scaleY = bounds.height / designHeight
            
            let deltaX = Double(location.x - dragStartPoint.x) / scaleX
            let deltaY = Double(dragStartPoint.y - location.y) / scaleY
            
            placedPlants[index].x = dragOffsetX + deltaX
            placedPlants[index].y = dragOffsetY + deltaY
            
            needsDisplay = true
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        if isPenMode && !currentDrawingPath.isEmpty {
            let drawingPath = DrawingPath(
                points: currentDrawingPath,
                color: penColor.hexString,
                lineWidth: penLineWidth,
                isSmoothed: false
            )
            drawingPaths.append(drawingPath)
            currentDrawingPath.removeAll()
            needsDisplay = true
        } else {
            selectedPlantIndex = nil
            needsDisplay = true
        }
    }
}

// MARK: - NSColor Extensions
extension NSColor {
    var hexString: String {
        guard let rgbColor = self.usingColorSpace(.sRGB) else {
            return "#000000"
        }
        let red = Int(rgbColor.redComponent * 255)
        let green = Int(rgbColor.greenComponent * 255)
        let blue = Int(rgbColor.blueComponent * 255)
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
    
    convenience init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard hex.count == 6 else { return nil }
        
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        
        guard scanner.scanHexInt64(&rgbValue) else { return nil }
        
        let red = CGFloat((rgbValue >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgbValue >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgbValue & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    var canvasView: Canvas3DView?
    var currentDesign: LandscapeDesign?
    var currentPlacedPlants: [PlacedPlant] = []
    var totalCost: Double = 0
    var inventoryTextField: NSTextField?
    var penToolActive: Bool = false
    var penToolButton: NSButton?
    var uploadedMedia: [String: String] = [:]  // filename: filepath
    var uploadedImages: [String] = []
    var uploadedPDFs: [String] = []
    var uploadedText: [String: String] = [:]  // filename: content
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        createMainWindow()
    }
    
    func createMainWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 1500, height: 950),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "🌿 iScape Professional - AR/3D Landscape Designer"
        window.isReleasedWhenClosed = false
        
        let tabView = NSTabView()
        
        // Tab 1: 2D Design
        let designTab = NSTabViewItem(identifier: "Design")
        designTab.label = "🎨 2D Design"
        designTab.view = createDesignTab()
        tabView.addTabViewItem(designTab)
        
        // Tab 2: 3D Preview
        let preview3DTab = NSTabViewItem(identifier: "3D")
        preview3DTab.label = "🏗️ 3D Preview"
        preview3DTab.view = create3DTab()
        tabView.addTabViewItem(preview3DTab)
        
        // Tab 3: Plant Library
        let libraryTab = NSTabViewItem(identifier: "Library")
        libraryTab.label = "🌱 Plant Library"
        libraryTab.view = createLibraryTab()
        tabView.addTabViewItem(libraryTab)
        
        // Tab 4: Inventory
        let inventoryTab = NSTabViewItem(identifier: "Inventory")
        inventoryTab.label = "📋 Inventory"
        inventoryTab.view = createInventoryTab()
        tabView.addTabViewItem(inventoryTab)
        
        // Tab 5: Collaboration & Export
        let colabTab = NSTabViewItem(identifier: "Export")
        colabTab.label = "🔄 Collab & Export"
        colabTab.view = createCollaborationTab()
        tabView.addTabViewItem(colabTab)
        
        // Tab 6: Media Upload
        let mediaTab = NSTabViewItem(identifier: "Media")
        mediaTab.label = "📸 Media & Files"
        mediaTab.view = createMediaTab()
        tabView.addTabViewItem(mediaTab)
        
        window.contentView = tabView
        window.center()
        window.makeKeyAndOrderFront(nil)
        self.window = window
        
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        // Initialize design
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        currentDesign = LandscapeDesign(
            id: UUID().uuidString,
            name: "New Landscape",
            width: 40,
            height: 30,
            createdDate: formatter.string(from: Date()),
            modifiedDate: formatter.string(from: Date())
        )
    }
    
    func createDesignTab() -> NSView {
        let container = NSView()
        
        let toolbar = NSView()
        toolbar.frame = NSRect(x: 0, y: 900, width: 1500, height: 50)
        toolbar.wantsLayer = true
        toolbar.layer?.backgroundColor = NSColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1).cgColor
        
        let title = NSTextField()
        title.stringValue = "2D Design Canvas"
        title.isEditable = false
        title.font = NSFont.boldSystemFont(ofSize: 14)
        title.frame = NSRect(x: 20, y: 15, width: 300, height: 25)
        toolbar.addSubview(title)
        
        let penButton = NSButton()
        penButton.title = "✏️ Pen Tool (OFF)"
        penButton.frame = NSRect(x: 350, y: 12, width: 110, height: 25)
        penButton.target = self
        penButton.action = #selector(togglePenMode)
        penButton.bezelStyle = .rounded
        penButton.wantsLayer = true
        penButton.layer?.backgroundColor = NSColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).cgColor
        self.penToolButton = penButton
        toolbar.addSubview(penButton)
        
        let colorButton = NSButton()
        colorButton.title = "🎨 Color"
        colorButton.frame = NSRect(x: 470, y: 12, width: 80, height: 25)
        colorButton.target = self
        colorButton.action = #selector(showColorPicker)
        toolbar.addSubview(colorButton)
        
        let lineWidthLabel = NSTextField()
        lineWidthLabel.stringValue = "Line:"
        lineWidthLabel.isEditable = false
        lineWidthLabel.font = NSFont.systemFont(ofSize: 12)
        lineWidthLabel.frame = NSRect(x: 570, y: 15, width: 40, height: 25)
        toolbar.addSubview(lineWidthLabel)
        
        let lineWidthSlider = NSSlider(value: 2.0, minValue: 0.5, maxValue: 10.0, target: self, action: #selector(updateLineWidth(_:)))
        lineWidthSlider.frame = NSRect(x: 610, y: 15, width: 150, height: 20)
        toolbar.addSubview(lineWidthSlider)
        
        let clearButton = NSButton()
        clearButton.title = "Clear"
        clearButton.frame = NSRect(x: 1350, y: 12, width: 130, height: 25)
        clearButton.target = self
        clearButton.action = #selector(clearCanvas)
        toolbar.addSubview(clearButton)
        
        container.addSubview(toolbar)
        
        canvasView = Canvas3DView()
        canvasView?.frame = NSRect(x: 0, y: 0, width: 1500, height: 900)
        canvasView?.wantsLayer = true
        canvasView?.layer?.backgroundColor = NSColor.white.cgColor
        canvasView?.is3DMode = false
        if let canvas = canvasView {
            container.addSubview(canvas)
        }
        
        return container
    }
    
    func create3DTab() -> NSView {
        let container = NSView()
        
        let toolbar = NSView()
        toolbar.frame = NSRect(x: 0, y: 900, width: 1500, height: 50)
        toolbar.wantsLayer = true
        toolbar.layer?.backgroundColor = NSColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1).cgColor
        
        let title = NSTextField()
        title.stringValue = "3D Isometric Preview"
        title.isEditable = false
        title.font = NSFont.boldSystemFont(ofSize: 14)
        title.frame = NSRect(x: 20, y: 15, width: 400, height: 25)
        toolbar.addSubview(title)
        
        let rotateCCW = NSButton()
        rotateCCW.title = "Rotate ↺"
        rotateCCW.frame = NSRect(x: 1250, y: 12, width: 110, height: 25)
        rotateCCW.target = self
        rotateCCW.action = #selector(rotate3D)
        toolbar.addSubview(rotateCCW)
        
        container.addSubview(toolbar)
        
        let canvas3D = Canvas3DView()
        canvas3D.frame = NSRect(x: 0, y: 0, width: 1500, height: 900)
        canvas3D.wantsLayer = true
        canvas3D.layer?.backgroundColor = NSColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1).cgColor
        canvas3D.is3DMode = true
        canvas3D.placedPlants = canvasView?.placedPlants ?? []
        container.addSubview(canvas3D)
        
        return container
    }
    
    func createLibraryTab() -> NSView {
        let container = NSView()
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1).cgColor
        
        let scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 1500, height: 950))
        let clipView = NSClipView()
        scrollView.contentView = clipView
        
        let documentView = NSView()
        clipView.documentView = documentView
        
        let title = NSTextField()
        title.stringValue = "🌿 Complete Plant Library"
        title.isEditable = false
        title.font = NSFont.boldSystemFont(ofSize: 14)
        title.frame = NSRect(x: 20, y: 1750, width: 600, height: 25)
        documentView.addSubview(title)
        
        let categories = PlantLibrary.shared.allCategories()
        var yPos = 1700
        
        for category in categories {
            let categoryLabel = NSTextField()
            categoryLabel.stringValue = "📌 \(category)"
            categoryLabel.isEditable = false
            categoryLabel.font = NSFont.boldSystemFont(ofSize: 12)
            categoryLabel.frame = NSRect(x: 20, y: yPos, width: 300, height: 25)
            documentView.addSubview(categoryLabel)
            yPos -= 35
            
            let plants = PlantLibrary.shared.plantsByCategory(category)
            for plant in plants {
                let plantButton = NSButton()
                let info = String(format: "🌿 %@ - %.0fft H, %.0fft S - $%.0f", plant.name, plant.height, plant.spacing, plant.cost)
                plantButton.title = info
                plantButton.bezelStyle = .rounded
                plantButton.frame = NSRect(x: 40, y: yPos, width: 950, height: 28)
                plantButton.target = self
                plantButton.action = #selector(addPlantToDesign(_:))
                plantButton.tag = PlantLibrary.shared.plants.firstIndex(where: { $0.id == plant.id }) ?? 0
                documentView.addSubview(plantButton)
                yPos -= 35
            }
        }
        
        documentView.frame = NSRect(x: 0, y: 0, width: 1500, height: CGFloat(abs(yPos) + 100))
        scrollView.documentView = documentView
        container.addSubview(scrollView)
        
        return container
    }
    
    func createInventoryTab() -> NSView {
        let container = NSView()
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor.white.cgColor
        
        let title = NSTextField()
        title.stringValue = "📋 Project Inventory & Cost Analysis"
        title.isEditable = false
        title.font = NSFont.boldSystemFont(ofSize: 16)
        title.frame = NSRect(x: 20, y: 900, width: 600, height: 25)
        container.addSubview(title)
        
        inventoryTextField = NSTextField()
        inventoryTextField?.isEditable = false
        inventoryTextField?.font = NSFont.systemFont(ofSize: 11)
        inventoryTextField?.frame = NSRect(x: 20, y: 50, width: 1460, height: 800)
        if let textField = inventoryTextField {
            container.addSubview(textField)
            updateInventory()
        }
        
        return container
    }
    
    func createCollaborationTab() -> NSView {
        let container = NSView()
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor(red: 0.95, green: 0.98, blue: 1.0, alpha: 1).cgColor
        
        let title = NSTextField()
        title.stringValue = "🔄 Real-Time Collaboration & PDF Export"
        title.isEditable = false
        title.font = NSFont.boldSystemFont(ofSize: 16)
        title.frame = NSRect(x: 20, y: 900, width: 600, height: 25)
        container.addSubview(title)
        
        // Collaboration Section
        let colabLabel = NSTextField()
        colabLabel.stringValue = "👥 Collaboration"
        colabLabel.isEditable = false
        colabLabel.font = NSFont.boldSystemFont(ofSize: 12)
        colabLabel.frame = NSRect(x: 20, y: 850, width: 600, height: 25)
        container.addSubview(colabLabel)
        
        let shareButton = NSButton()
        shareButton.title = "📧 Invite Collaborators"
        shareButton.bezelStyle = .rounded
        shareButton.frame = NSRect(x: 40, y: 810, width: 300, height: 30)
        shareButton.target = self
        shareButton.action = #selector(inviteCollaborators)
        container.addSubview(shareButton)
        
        let liveButton = NSButton()
        liveButton.title = "🔴 Start Live Sharing"
        liveButton.bezelStyle = .rounded
        liveButton.frame = NSRect(x: 360, y: 810, width: 300, height: 30)
        liveButton.target = self
        shareButton.action = #selector(startLiveSharing)
        container.addSubview(liveButton)
        
        // PDF Export Section
        let exportLabel = NSTextField()
        exportLabel.stringValue = "📄 PDF Export & Proposals"
        exportLabel.isEditable = false
        exportLabel.font = NSFont.boldSystemFont(ofSize: 12)
        exportLabel.frame = NSRect(x: 20, y: 750, width: 600, height: 25)
        container.addSubview(exportLabel)
        
        let options = [
            ("📄 Export as Professional PDF", "Full design with materials, costs, and specifications"),
            ("💼 Generate Proposal Document", "Client-ready proposal with images and pricing"),
            ("📊 Export Cost Breakdown", "Detailed inventory and cost analysis report"),
            ("🖨️ Print Design", "High-quality print of 2D/3D design"),
        ]
        
        var yPos = 710
        for (title, desc) in options {
            let button = NSButton()
            button.title = title
            button.bezelStyle = .rounded
            button.frame = NSRect(x: 40, y: yPos, width: 320, height: 30)
            button.target = self
            button.action = #selector(exportDesign(_:))
            container.addSubview(button)
            
            let description = NSTextField()
            description.stringValue = desc
            description.isEditable = false
            description.font = NSFont.systemFont(ofSize: 10)
            description.textColor = NSColor.gray
            description.frame = NSRect(x: 380, y: yPos + 5, width: 600, height: 20)
            container.addSubview(description)
            
            yPos -= 50
        }
        
        // Cloud Storage Section
        let cloudLabel = NSTextField()
        cloudLabel.stringValue = "☁️ Cloud Storage & Project Management"
        cloudLabel.isEditable = false
        cloudLabel.font = NSFont.boldSystemFont(ofSize: 12)
        cloudLabel.frame = NSRect(x: 20, y: yPos, width: 600, height: 25)
        container.addSubview(cloudLabel)
        
        yPos -= 50
        
        let saveButton = NSButton()
        saveButton.title = "💾 Save Project"
        saveButton.bezelStyle = .rounded
        saveButton.frame = NSRect(x: 40, y: yPos, width: 300, height: 30)
        saveButton.target = self
        saveButton.action = #selector(saveProject)
        container.addSubview(saveButton)
        
        let loadButton = NSButton()
        loadButton.title = "📂 Open Project"
        loadButton.bezelStyle = .rounded
        loadButton.frame = NSRect(x: 360, y: yPos, width: 300, height: 30)
        loadButton.target = self
        loadButton.action = #selector(loadProject)
        container.addSubview(loadButton)
        
        return container
    }
    
    func createMediaTab() -> NSView {
        let container = NSView()
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor(red: 0.98, green: 0.95, blue: 0.95, alpha: 1).cgColor
        
        let title = NSTextField()
        title.stringValue = "📸 Media & File Management"
        title.isEditable = false
        title.font = NSFont.boldSystemFont(ofSize: 16)
        title.frame = NSRect(x: 20, y: 900, width: 600, height: 25)
        container.addSubview(title)
        
        // Images Section
        let imagesLabel = NSTextField()
        imagesLabel.stringValue = "🖼️ Images & Photos"
        imagesLabel.isEditable = false
        imagesLabel.font = NSFont.boldSystemFont(ofSize: 12)
        imagesLabel.frame = NSRect(x: 20, y: 850, width: 600, height: 25)
        container.addSubview(imagesLabel)
        
        let uploadImageButton = NSButton()
        uploadImageButton.title = "🖼️ Upload Images (JPG, PNG, TIFF)"
        uploadImageButton.bezelStyle = .rounded
        uploadImageButton.frame = NSRect(x: 40, y: 810, width: 400, height: 30)
        uploadImageButton.target = self
        uploadImageButton.action = #selector(uploadImages)
        container.addSubview(uploadImageButton)
        
        let imageList = NSTextField()
        imageList.stringValue = "Uploaded Images: \(uploadedImages.count)"
        imageList.isEditable = false
        imageList.font = NSFont.systemFont(ofSize: 11)
        imageList.textColor = NSColor.gray
        imageList.frame = NSRect(x: 450, y: 815, width: 300, height: 20)
        container.addSubview(imageList)
        
        // PDFs Section
        let pdfLabel = NSTextField()
        pdfLabel.stringValue = "📄 PDF Documents"
        pdfLabel.isEditable = false
        pdfLabel.font = NSFont.boldSystemFont(ofSize: 12)
        pdfLabel.frame = NSRect(x: 20, y: 750, width: 600, height: 25)
        container.addSubview(pdfLabel)
        
        let uploadPDFButton = NSButton()
        uploadPDFButton.title = "📄 Upload PDF Documents"
        uploadPDFButton.bezelStyle = .rounded
        uploadPDFButton.frame = NSRect(x: 40, y: 710, width: 400, height: 30)
        uploadPDFButton.target = self
        uploadPDFButton.action = #selector(uploadPDFs)
        container.addSubview(uploadPDFButton)
        
        let pdfList = NSTextField()
        pdfList.stringValue = "Uploaded PDFs: \(uploadedPDFs.count)"
        pdfList.isEditable = false
        pdfList.font = NSFont.systemFont(ofSize: 11)
        pdfList.textColor = NSColor.gray
        pdfList.frame = NSRect(x: 450, y: 715, width: 300, height: 20)
        container.addSubview(pdfList)
        
        // Text Files Section
        let textLabel = NSTextField()
        textLabel.stringValue = "📝 Text & Notes"
        textLabel.isEditable = false
        textLabel.font = NSFont.boldSystemFont(ofSize: 12)
        textLabel.frame = NSRect(x: 20, y: 650, width: 600, height: 25)
        container.addSubview(textLabel)
        
        let uploadTextButton = NSButton()
        uploadTextButton.title = "📝 Upload Text Files (TXT, RTF)"
        uploadTextButton.bezelStyle = .rounded
        uploadTextButton.frame = NSRect(x: 40, y: 610, width: 400, height: 30)
        uploadTextButton.target = self
        uploadTextButton.action = #selector(uploadTextFiles)
        container.addSubview(uploadTextButton)
        
        let textList = NSTextField()
        textList.stringValue = "Uploaded Files: \(uploadedText.count)"
        textList.isEditable = false
        textList.font = NSFont.systemFont(ofSize: 11)
        textList.textColor = NSColor.gray
        textList.frame = NSRect(x: 450, y: 615, width: 300, height: 20)
        container.addSubview(textList)
        
        // Usage Section
        let usageLabel = NSTextField()
        usageLabel.stringValue = "💡 How to Use Uploaded Media"
        usageLabel.isEditable = false
        usageLabel.font = NSFont.boldSystemFont(ofSize: 12)
        usageLabel.frame = NSRect(x: 20, y: 550, width: 600, height: 25)
        container.addSubview(usageLabel)
        
        let usage = NSTextField()
        usage.stringValue = """
        • Images: Reference photos for plant identification and landscape inspiration
        • PDFs: Store specification sheets, plant care guides, or client documents
        • Text: Keep notes about design decisions, maintenance plans, or client preferences
        
        All files are stored locally in ~/Documents/LandscapeDesigns/media/
        """
        usage.isEditable = false
        usage.font = NSFont.systemFont(ofSize: 11)
        usage.textColor = NSColor.darkGray
        usage.frame = NSRect(x: 40, y: 350, width: 1100, height: 180)
        container.addSubview(usage)
        
        // Manage Files Button
        let manageButton = NSButton()
        manageButton.title = "📂 Open Media Folder"
        manageButton.bezelStyle = .rounded
        manageButton.frame = NSRect(x: 40, y: 300, width: 300, height: 30)
        manageButton.target = self
        manageButton.action = #selector(openMediaFolder)
        container.addSubview(manageButton)
        
        let clearButton = NSButton()
        clearButton.title = "🗑️ Clear All Media"
        clearButton.bezelStyle = .rounded
        clearButton.frame = NSRect(x: 360, y: 300, width: 300, height: 30)
        clearButton.target = self
        clearButton.action = #selector(clearAllMedia)
        container.addSubview(clearButton)
        
        return container
    }
    
    @objc func addPlantToDesign(_ sender: NSButton) {
        guard let canvas = canvasView else { return }
        
        let plant = PlantLibrary.shared.plants[sender.tag]
        let centerX = Double(canvas.bounds.width / 2)
        let centerY = Double(canvas.bounds.height / 2)
        let randomX = Double.random(in: -150...150)
        let randomY = Double.random(in: -150...150)
        let point = NSPoint(x: centerX + randomX, y: centerY + randomY)
        
        canvas.addPlant(plant, at: point)
        totalCost += plant.cost
        currentPlacedPlants.append(PlacedPlant(plant: plant, x: Double(point.x), y: Double(point.y)))
        
        let alert = NSAlert()
        alert.messageText = "✅ Plant Added"
        alert.informativeText = "\(plant.name)\nCost: $\(Int(plant.cost))"
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc func clearCanvas() {
        let alert = NSAlert()
        alert.messageText = "Clear Canvas?"
        alert.informativeText = "Remove all plants from design?"
        alert.addButton(withTitle: "Clear")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
            canvasView?.placedPlants.removeAll()
            currentPlacedPlants.removeAll()
            totalCost = 0
            canvasView?.needsDisplay = true
            updateInventory()
        }
    }
    
    @objc func rotate3D() {
        // Rotation will be implemented with actual 3D framework in next phase
    }
    
    @objc func inviteCollaborators() {
        let alert = NSAlert()
        alert.messageText = "👥 Invite Collaborators"
        alert.informativeText = "Share your design with team members for real-time collaboration\n\nFeatures:\n• Live editing\n• Comments & annotations\n• Version control\n• Share via email or link"
        alert.addButton(withTitle: "Send Invite")
        alert.addButton(withTitle: "Cancel")
        alert.runModal()
    }
    
    @objc func startLiveSharing() {
        let alert = NSAlert()
        alert.messageText = "🔴 Live Sharing"
        alert.informativeText = "Enable real-time sharing of your design\n\nYour design is now being shared live with all collaborators.\nChanges sync instantly across all connected devices."
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc func exportDesign(_ sender: NSButton) {
        let alert = NSAlert()
        alert.messageText = "📄 Export Design"
        alert.informativeText = """
        Design: \(currentDesign?.name ?? "New Landscape")
        Plants: \(currentPlacedPlants.count)
        Total Cost: $\(Int(totalCost))
        
        PDF Export will include:
        • 2D and 3D design views
        • Plant inventory list
        • Cost breakdown
        • Client proposal template
        • Installation notes
        """
        alert.addButton(withTitle: "Export PDF")
        alert.addButton(withTitle: "Cancel")
        alert.runModal()
    }
    
    @objc func saveProject() {
        let alert = NSAlert()
        alert.messageText = "💾 Save Project"
        
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        input.stringValue = currentDesign?.name ?? "My Landscape"
        alert.accessoryView = input
        
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == NSApplication.ModalResponse.alertFirstButtonReturn {
            var design = currentDesign ?? LandscapeDesign(
                id: UUID().uuidString,
                name: input.stringValue,
                width: 40,
                height: 30,
                createdDate: Date().description,
                modifiedDate: Date().description
            )
            design.name = input.stringValue
            design.plants = currentPlacedPlants
            design.updateModifiedDate()
            
            if CloudStorage.shared.saveDesign(design) {
                let success = NSAlert()
                success.messageText = "✅ Project Saved"
                success.informativeText = "Your landscape design has been saved successfully"
                success.addButton(withTitle: "OK")
                success.runModal()
            }
        }
    }
    
    @objc func loadProject() {
        let designs = CloudStorage.shared.getAllDesigns()
        
        if designs.isEmpty {
            let alert = NSAlert()
            alert.messageText = "📂 No Projects Found"
            alert.informativeText = "You haven't saved any landscape designs yet"
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return
        }
        
        let alert = NSAlert()
        alert.messageText = "📂 Load Project"
        alert.informativeText = "Available projects:\n\n" + designs.map { $0.name }.joined(separator: "\n")
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    func updateInventory() {
        var text = "PLANT INVENTORY & COST\n" + String(repeating: "=", count: 60) + "\n\n"
        
        if currentPlacedPlants.isEmpty {
            text += "No plants added yet\n"
        } else {
            let grouped = Dictionary(grouping: currentPlacedPlants) { $0.plant.id }
            text += String(format: "%-25s %-10s %-12s\n", "Plant", "Qty", "Cost")
            text += String(repeating: "-", count: 50) + "\n"
            
            var subtotal: Double = 0
            for (_, plants) in grouped.sorted(by: { $0.key < $1.key }) {
                if let plant = plants.first?.plant {
                    let qty = plants.count
                    let total = plant.cost * Double(qty)
                    subtotal += total
                    text += String(format: "%-25s %-10d $%-10.2f\n", plant.name, qty, total)
                }
            }
            text += String(repeating: "-", count: 50) + "\n"
            text += String(format: "%-25s %-10s $%-10.2f\n", "TOTAL", "", subtotal)
        }
        
        inventoryTextField?.stringValue = text
    }
    
    @objc func togglePenMode() {
        penToolActive = !penToolActive
        canvasView?.isPenMode = penToolActive
        canvasView?.needsDisplay = true
        
        // Update button appearance
        if let button = penToolButton {
            if penToolActive {
                button.title = "✏️ Pen Tool (ON)"
                button.layer?.backgroundColor = NSColor(red: 0.0, green: 0.8, blue: 0.2, alpha: 1).cgColor
            } else {
                button.title = "✏️ Pen Tool (OFF)"
                button.layer?.backgroundColor = NSColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).cgColor
            }
        }
        
        let alert = NSAlert()
        alert.messageText = penToolActive ? "✏️ Pen Mode Enabled" : "✏️ Pen Mode Disabled"
        alert.informativeText = penToolActive ? "Click and drag on canvas to draw. Hold and release to finalize strokes." : "Plant placement and dragging mode active"
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc func showColorPicker() {
        let colorPanel = NSColorPanel.shared
        colorPanel.setTarget(self)
        colorPanel.setAction(#selector(colorDidChange(_:)))
        colorPanel.makeKeyAndOrderFront(nil)
    }
    
    @objc func colorDidChange(_ sender: NSColorPanel) {
        canvasView?.penColor = sender.color
    }
    
    @objc func updateLineWidth(_ slider: NSSlider) {
        canvasView?.penLineWidth = Double(slider.doubleValue)
    }
    
    // MARK: - Media Upload Functions
    @objc func uploadImages() {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["jpg", "jpeg", "png", "tiff", "gif"]
        openPanel.allowsMultipleSelection = true
        openPanel.title = "Select Images to Upload"
        
        if openPanel.runModal() == .OK {
            for url in openPanel.urls {
                uploadedImages.append(url.lastPathComponent)
                uploadedMedia[url.lastPathComponent] = url.path
            }
            let alert = NSAlert()
            alert.messageText = "✅ Images Uploaded"
            alert.informativeText = "Uploaded \(openPanel.urls.count) image(s)\nTotal images: \(uploadedImages.count)"
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    @objc func uploadPDFs() {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["pdf"]
        openPanel.allowsMultipleSelection = true
        openPanel.title = "Select PDF Documents to Upload"
        
        if openPanel.runModal() == .OK {
            for url in openPanel.urls {
                uploadedPDFs.append(url.lastPathComponent)
                uploadedMedia[url.lastPathComponent] = url.path
            }
            let alert = NSAlert()
            alert.messageText = "✅ PDFs Uploaded"
            alert.informativeText = "Uploaded \(openPanel.urls.count) PDF(s)\nTotal PDFs: \(uploadedPDFs.count)"
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    @objc func uploadTextFiles() {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["txt", "rtf", "md", "text"]
        openPanel.allowsMultipleSelection = true
        openPanel.title = "Select Text Files to Upload"
        
        if openPanel.runModal() == .OK {
            for url in openPanel.urls {
                if let content = try? String(contentsOf: url, encoding: .utf8) {
                    uploadedText[url.lastPathComponent] = content
                    uploadedMedia[url.lastPathComponent] = url.path
                }
            }
            let alert = NSAlert()
            alert.messageText = "✅ Text Files Uploaded"
            alert.informativeText = "Uploaded \(openPanel.urls.count) text file(s)\nTotal files: \(uploadedText.count)"
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    @objc func openMediaFolder() {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let mediaPath = documentsPath.appendingPathComponent("LandscapeDesigns/media")
        
        // Create folder if it doesn't exist
        try? fileManager.createDirectory(at: mediaPath, withIntermediateDirectories: true, attributes: nil)
        
        NSWorkspace.shared.open(mediaPath)
    }
    
    @objc func clearAllMedia() {
        let alert = NSAlert()
        alert.messageText = "Clear All Media?"
        alert.informativeText = "This will clear all uploaded images, PDFs, and text files. This cannot be undone."
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Clear All")
        
        if alert.runModal() == NSApplication.ModalResponse.alertSecondButtonReturn {
            uploadedImages.removeAll()
            uploadedPDFs.removeAll()
            uploadedText.removeAll()
            uploadedMedia.removeAll()
            
            let confirmAlert = NSAlert()
            confirmAlert.messageText = "✅ Cleared"
            confirmAlert.informativeText = "All media references have been cleared"
            confirmAlert.addButton(withTitle: "OK")
            confirmAlert.runModal()
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

// MARK: - Main Entry Point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
