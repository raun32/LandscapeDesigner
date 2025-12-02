# Project Overview

This project is a landscape design application for iOS, iPadOS, and macOS, built with SwiftUI. It allows users to visualize landscape designs by placing digital plant images onto a background image of their property.

The application consists of a shared codebase for all platforms, with platform-specific implementations for features like image picking.

## Key Features

*   **Image Background:** Users can select an image from their photo library to use as a background for their design.
*   **Plant Library:** A library of plants is available to drag and drop onto the design canvas.
*   **Drag and Drop:** Plants can be dragged from the library and dropped onto the canvas.
*   **Moveable Plants:** Placed plants can be moved around the canvas.

# Building and Running

This is an Xcode project. To build and run the application, you will need to create an Xcode project and add the generated files to it.

## Instructions

1.  **Create a new Xcode project:**
    *   Open Xcode and select "Create a new Xcode project".
    *   Choose the "Multiplatform" tab and select the "App" template.
    *   Enter a product name (e.g., "LandscapeDesigner") and choose "SwiftUI" for the interface and "Swift" for the language.

2.  **Add the generated files to the project:**
    *   In the project navigator, right-click on the project folder and select "Add Files to '[Your Project Name]'...".
    *   Navigate to the `LandscapeDesigner` directory and select all the files and folders inside it.
    *   Make sure "Copy items if needed" is checked.

3.  **Run the app:**
    *   Select a simulator or a connected device from the scheme menu.
    *   Click the "Run" button or press `Cmd+R`.

# Development Conventions

## Architecture

The application follows a simple SwiftUI architecture:

*   **`LandscapeDesignerApp.swift`:** The main entry point of the application.
*   **`ContentView.swift`:** The main view of the application, which contains the `DesignCanvasView` and `PlantLibraryView`.
*   **Models:**
    *   `Plant.swift`: The data model for a plant.
    *   `PlacedPlant.swift`: Represents a plant that has been placed on the canvas.
*   **Views:**
    *   `DesignCanvasView.swift`: The view where the user creates their design.
    *   `PlantLibraryView.swift`: The view that displays the library of plants.
    *   `ImagePickerView.swift`: A cross-platform view for selecting an image.

## Code Style

The code follows the standard Swift and SwiftUI conventions.
