import SwiftUI
import UniformTypeIdentifiers

struct Plant: Identifiable, Codable {
    let id: UUID
    let name: String
    let imageName: String

    init(id: UUID = UUID(), name: String, imageName: String) {
        self.id = id
        self.name = name
        self.imageName = imageName
    }
}

extension Plant: NSItemProviderWriting {
    static var writableTypeIdentifiersForItemProvider: [String] {
        [UTType.data.identifier]
    }

    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        let progress = Progress(totalUnitCount: 1)
        do {
            let data = try JSONEncoder().encode(self)
            completionHandler(data, nil)
        } catch {
            completionHandler(nil, error)
        }
        progress.completedUnitCount = 1
        return progress
    }
}

extension Plant: NSItemProviderReading {
    static var readableTypeIdentifiersForItemProvider: [String] {
        [UTType.data.identifier]
    }

    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Plant {
        try JSONDecoder().decode(Plant.self, from: data)
    }
}
