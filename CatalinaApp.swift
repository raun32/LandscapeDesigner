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

struct PlacedPlant: Identifiable {
    let id: String
    let plant: Plant
    var x: Double
    var y: Double
    var quantity: Int = 1
    
    init(id: String = UUID().uuidString, plant: Plant, x: Double, y: Double, quantity: Int = 1) {
        self.id = id
        self.plant = plant
        self.x = x
        self.y = y
        self.quantity = quantity
    }
}

struct LandscapeDesign: Codable {
    let id: String
    let name: String
    let width: Double   // in feet
    let height: Double  // in feet
    var plants: [String] = [] // plant IDs and positions stored as JSON
    var notes: String = ""
    var createdDate: String
    var modifiedDate: String
}

// MARK: - Plant Library Database
class PlantLibrary {
    static let shared = PlantLibrary()
    
    let plants: [Plant] = [
        // Trees
        Plant(name: "Oak Tree", category: "Trees", spacing: 30, height: 60, cost: 150),
        Plant(name: "Maple Tree", category: "Trees", spacing: 25, height: 50, cost: 120),
        Plant(name: "Pine Tree", category: "Trees", spacing: 20, height: 80, cost: 100),
        Plant(name: "Birch Tree", category: "Trees", spacing: 20, height: 40, cost: 90),
        Plant(name: "Willow Tree", category: "Trees", spacing: 35, height: 50, cost: 110),
        
        // Shrubs
        Plant(name: "Boxwood", category: "Shrubs", spacing: 3, height: 4, cost: 25),
        Plant(name: "Hydrangea", category: "Shrubs", spacing: 4, height: 6, cost: 35),
        Plant(name: "Lilac", category: "Shrubs", spacing: 5, height: 8, cost: 40),
        Plant(name: "Azalea", category: "Shrubs", spacing: 3, height: 4, cost: 30),
        Plant(name: "Juniper", category: "Shrubs", spacing: 4, height: 5, cost: 28),
        
        // Flowers
        Plant(name: "Rose", category: "Flowers", spacing: 2, height: 3, cost: 15),
        Plant(name: "Tulip", category: "Flowers", spacing: 1, height: 2, cost: 5),
        Plant(name: "Daisy", category: "Flowers", spacing: 1.5, height: 2.5, cost: 8),
        Plant(name: "Sunflower", category: "Flowers", spacing: 2, height: 6, cost: 10),
        Plant(name: "Lavender", category: "Flowers", spacing: 2, height: 3, cost: 12),
        Plant(name: "Peony", category: "Flowers", spacing: 3, height: 3, cost: 20),
        Plant(name: "Hibiscus", category: "Flowers", spacing: 4, height: 8, cost: 45),
        
        // Ground Cover
        Plant(name: "Ivy", category: "Ground Cover", spacing: 1, height: 0.5, cost: 6),
        Plant(name: "Moss Phlox", category: "Ground Cover", spacing: 1, height: 0.3, cost: 8),
        Plant(name: "Sedum", category: "Ground Cover", spacing: 1, height: 0.5, cost: 7),
    ]
    
    func plantsByCategory(_ category: String) -> [Plant] {
        return plants.filter { $0.category == category }
    }
    
    func allCategories() -> [String] {
        let categories = Set(plants.map { $0.category })
        return Array(categories).sorted()
    }
}

// MARK: - Canvas View
class DesignCanvasView: NSView {
    var placedPlants: [PlacedPlant] = []
    var designWidth: Double = 40  // feet
    var designHeight: Double = 30 // feet
    var selectedPlant: PlacedPlant?
    var delegate: AppDelegate?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Draw background
        NSColor.white.setFill()
        dirtyRect.fill()
        
        // Draw grid
        NSColor.lightGray.setStroke()
        let lineWidth: CGFloat = 0.5
        
        let cellWidth = bounds.width / 10
        let cellHeight = bounds.height / 10
        
        for i in 1..<10 {
            let x = CGFloat(i) * cellWidth
            let y = CGFloat(i) * cellHeight
            
            // Vertical lines
            let vLine = NSBezierPath()
            vLine.move(to: NSPoint(x: x, y: 0))
            vLine.line(to: NSPoint(x: x, y: bounds.height))
            vLine.lineWidth = lineWidth
            vLine.stroke()
            
            // Horizontal lines
            let hLine = NSBezierPath()
            hLine.move(to: NSPoint(x: 0, y: y))
            hLine.line(to: NSPoint(x: bounds.width, y: y))
            hLine.lineWidth = lineWidth
            hLine.stroke()
        }
        
        // Draw border
        NSColor.black.setStroke()
        let border = NSBezierPath(rect: bounds)
        border.lineWidth = 2
        border.stroke()
        
        // Draw placed plants
        for plant in placedPlants {
            drawPlant(plant)
        }
        
        // Draw scale info
        let scaleText = NSAttributedString(
            string: "Canvas: \(Int(designWidth))ft × \(Int(designHeight))ft",
            attributes: [.font: NSFont.systemFont(ofSize: 10)]
        )
        scaleText.draw(at: NSPoint(x: 10, y: bounds.height - 20))
    }
    
    func drawPlant(_ plant: PlacedPlant) {
        let scaleX = bounds.width / designWidth
        let scaleY = bounds.height / designHeight
        
        let x = plant.x * scaleX
        let y = bounds.height - (plant.y * scaleY)
        let size: CGFloat = 20
        
        // Draw circle for plant
        NSColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 0.8).setFill()
        let circle = NSBezierPath(ovalIn: NSRect(x: x - size/2, y: y - size/2, width: size, height: size))
        circle.fill()
        
        // Draw border
        NSColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0).setStroke()
        circle.lineWidth = 2
        circle.stroke()
        
        // Draw quantity label
        let label = NSAttributedString(
            string: "×\(plant.quantity)",
            attributes: [.font: NSFont.systemFont(ofSize: 9), .foregroundColor: NSColor.white]
        )
        label.draw(at: NSPoint(x: x - 8, y: y - 5))
    }
    
    func addPlant(_ plant: Plant, at point: NSPoint) {
        let scaleX = bounds.width / designWidth
        let scaleY = bounds.height / designHeight
        
        let x = Double(point.x) / scaleX
        let y = Double(bounds.height - point.y) / scaleY
        
        let newPlant = PlacedPlant(plant: plant, x: x, y: y)
        placedPlants.append(newPlant)
        needsDisplay = true
        delegate?.updateInventory()
    }
}

// MARK: - App Delegate & Window
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    var canvasView: DesignCanvasView?
    var currentPlacedPlants: [PlacedPlant] = []
    var totalCost: Double = 0
    var inventoryTextField: NSTextField?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        createMainWindow()
    }
    
    func createMainWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 1400, height: 900),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "🌿 Landscape Designer - iScape Professional"
        window.isReleasedWhenClosed = false
        
        // Main container with tab view
        let tabView = NSTabView()
        // tabView.tabViewType = .topTabsBezel
        
        // Tab 1: Design
        let designTab = NSTabViewItem(identifier: "Design")
        designTab.label = "🎨 Design Canvas"
        designTab.view = createDesignTab()
        tabView.addTabViewItem(designTab)
        
        // Tab 2: Plant Library
        let libraryTab = NSTabViewItem(identifier: "Library")
        libraryTab.label = "🌱 Plant Library"
        libraryTab.view = createLibraryTab()
        tabView.addTabViewItem(libraryTab)
        
        // Tab 3: Inventory
        let inventoryTab = NSTabViewItem(identifier: "Inventory")
        inventoryTab.label = "📋 Inventory & Cost"
        inventoryTab.view = createInventoryTab()
        tabView.addTabViewItem(inventoryTab)
        
        // Tab 4: Export
        let exportTab = NSTabViewItem(identifier: "Export")
        exportTab.label = "💾 Export & Share"
        exportTab.view = createExportTab()
        tabView.addTabViewItem(exportTab)
        
        window.contentView = tabView
        window.center()
        window.makeKeyAndOrderFront(nil)
        self.window = window
        
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    func createDesignTab() -> NSView {
        let container = NSView()
        
        // Top toolbar
        let toolbar = NSView()
        toolbar.frame = NSRect(x: 0, y: 850, width: 1400, height: 50)
        toolbar.wantsLayer = true
        toolbar.layer?.backgroundColor = NSColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1).cgColor
        
        let title = NSTextField()
        title.stringValue = "Design Canvas - Click 'Plant Library' to add plants"
        title.isEditable = false
        title.font = NSFont.boldSystemFont(ofSize: 14)
        title.frame = NSRect(x: 20, y: 15, width: 800, height: 25)
        toolbar.addSubview(title)
        
        let clearButton = NSButton()
        clearButton.title = "Clear Canvas"
        clearButton.frame = NSRect(x: 1250, y: 12, width: 120, height: 25)
        clearButton.target = self
        clearButton.action = #selector(clearCanvas)
        toolbar.addSubview(clearButton)
        
        container.addSubview(toolbar)
        
        // Canvas
        canvasView = DesignCanvasView()
        canvasView?.frame = NSRect(x: 0, y: 0, width: 1400, height: 850)
        canvasView?.wantsLayer = true
        canvasView?.layer?.backgroundColor = NSColor.white.cgColor
        canvasView?.delegate = self
        if let canvas = canvasView {
            container.addSubview(canvas)
        }
        
        return container
    }
    
    func createLibraryTab() -> NSView {
        let container = NSView()
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1).cgColor
        
        let scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 1400, height: 900))
        let clipView = NSClipView()
        scrollView.contentView = clipView
        
        let documentView = NSView()
        clipView.documentView = documentView
        
        let title = NSTextField()
        title.stringValue = "🌿 Complete Plant Library - Select and Add to Canvas"
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
                let info = String(format: "🌿 %@ - %.1fft h, %.1fft s - $%.0f", plant.name, plant.height, plant.spacing, plant.cost)
                plantButton.title = info
                plantButton.bezelStyle = .rounded
                plantButton.frame = NSRect(x: 40, y: yPos, width: 900, height: 28)
                plantButton.target = self
                plantButton.action = #selector(addPlantToDesign(_:))
                plantButton.tag = PlantLibrary.shared.plants.firstIndex(where: { $0.id == plant.id }) ?? 0
                documentView.addSubview(plantButton)
                yPos -= 35
            }
        }
        
        documentView.frame = NSRect(x: 0, y: 0, width: 1400, height: CGFloat(abs(yPos) + 100))
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
        title.frame = NSRect(x: 20, y: 850, width: 600, height: 25)
        container.addSubview(title)
        
        inventoryTextField = NSTextField()
        inventoryTextField?.isEditable = false
        inventoryTextField?.font = NSFont.systemFont(ofSize: 12)
        inventoryTextField?.frame = NSRect(x: 20, y: 50, width: 1360, height: 750)
        if let textField = inventoryTextField {
            container.addSubview(textField)
            updateInventory()
        }
        
        // Summary box
        let summaryBox = NSBox()
        summaryBox.title = "Project Summary"
        summaryBox.frame = NSRect(x: 20, y: 10, width: 1360, height: 30)
        container.addSubview(summaryBox)
        
        return container
    }
    
    func createExportTab() -> NSView {
        let container = NSView()
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor(red: 0.95, green: 0.98, blue: 1.0, alpha: 1).cgColor
        
        let title = NSTextField()
        title.stringValue = "💾 Export, Share & Generate Proposals"
        title.isEditable = false
        title.font = NSFont.boldSystemFont(ofSize: 16)
        title.frame = NSRect(x: 20, y: 850, width: 600, height: 25)
        container.addSubview(title)
        
        let options = [
            ("📄 Export as PDF Proposal", "Generate professional PDF with materials list and costs"),
            ("🖼️ Export Design as Image", "Save high-resolution PNG of your landscape design"),
            ("💾 Save Design Project", "Save project file for later editing and iteration"),
            ("🔗 Create Share Link", "Generate shareable link for client collaboration"),
            ("📊 Generate Cost Report", "Detailed inventory and pricing breakdown"),
            ("📱 Share via Social Media", "Post design to Facebook, Instagram, and Pinterest"),
        ]
        
        var yPos = 800
        for (title, desc) in options {
            let button = NSButton()
            button.title = title
            button.bezelStyle = .rounded
            button.frame = NSRect(x: 40, y: yPos, width: 350, height: 35)
            button.target = self
            button.action = #selector(exportDesign(_:))
            container.addSubview(button)
            
            let description = NSTextField()
            description.stringValue = desc
            description.isEditable = false
            description.font = NSFont.systemFont(ofSize: 11)
            description.textColor = NSColor.gray
            description.frame = NSRect(x: 410, y: yPos + 5, width: 600, height: 25)
            container.addSubview(description)
            
            yPos -= 60
        }
        
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
        
        // Update inventory
        totalCost += plant.cost
        currentPlacedPlants.append(PlacedPlant(plant: plant, x: Double(point.x), y: Double(point.y)))
        
        let alert = NSAlert()
        alert.messageText = "✅ Plant Added to Canvas"
        alert.informativeText = "\(plant.name)\n\nCost: $\(Int(plant.cost))\nHeight: \(plant.height)ft\nSpacing: \(plant.spacing)ft"
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc func clearCanvas() {
        let alert = NSAlert()
        alert.messageText = "Clear Canvas?"
        alert.informativeText = "This will remove all plants from your design. This action cannot be undone."
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
    
    @objc func exportDesign(_ sender: NSButton) {
        let alert = NSAlert()
        alert.messageText = "📊 Export Feature"
        alert.informativeText = """
        Project Summary:
        
        Plants in Design: \(currentPlacedPlants.count)
        Total Project Cost: $\(Int(totalCost))
        Canvas Size: \(Int(canvasView?.designWidth ?? 40))ft × \(Int(canvasView?.designHeight ?? 30))ft
        
        Export features coming soon:
        • PDF Proposal Generation
        • Image Export (PNG)
        • Project File Save
        • Social Media Sharing
        • Client Collaboration Links
        """
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    func updateInventory() {
        var inventoryText = "PLANT INVENTORY & COST ANALYSIS\n"
        inventoryText += "=" + String(repeating: "=", count: 79) + "\n\n"
        
        if currentPlacedPlants.isEmpty {
            inventoryText += "No plants added yet. Visit 'Plant Library' tab to add plants to your design.\n"
        } else {
            // Group plants by type
            let grouped = Dictionary(grouping: currentPlacedPlants) { $0.plant.id }
            
            inventoryText += String(format: "%-30s %-10s %-12s %-15s\n", "Plant Name", "Quantity", "Unit Cost", "Total Cost")
            inventoryText += String(repeating: "-", count: 70) + "\n"
            
            var subtotal: Double = 0
            for (_, plants) in grouped.sorted(by: { $0.key < $1.key }) {
                if let firstPlant = plants.first {
                    let plant = firstPlant.plant
                    let quantity = plants.count
                    let total = plant.cost * Double(quantity)
                    subtotal += total
                    
                    inventoryText += String(format: "%-30s %-10d $%-10.2f $%-14.2f\n",
                                          plant.name,
                                          quantity,
                                          plant.cost,
                                          total)
                }
            }
            
            inventoryText += String(repeating: "-", count: 70) + "\n"
            inventoryText += String(format: "%-30s %-10s %-12s $%-14.2f\n",
                                  "TOTAL", "", "", subtotal)
            inventoryText += "\n" + String(repeating: "=", count: 79) + "\n\n"
            inventoryText += "Notes:\n"
            inventoryText += "• Total Cost includes material cost only\n"
            inventoryText += "• Installation labor costs not included\n"
            inventoryText += "• Prices are estimates and may vary\n"
        }
        
        inventoryTextField?.stringValue = inventoryText
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
