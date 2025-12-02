import SwiftUI
#if os(iOS)
import PhotosUI
#endif

struct ImagePickerView: View {
    @Binding var image: Image?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        #if os(iOS)
        ImagePickerViewController(image: $image, presentationMode: _presentationMode)
        #else
        Button("Select Image") {
            let panel = NSOpenPanel()
            panel.allowedContentTypes = [.image]
            panel.begin { response in
                if response == .OK, let url = panel.url, let nsImage = NSImage(contentsOf: url) {
                    self.image = Image(nsImage: nsImage)
                }
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        #endif
    }
}

#if os(iOS)
struct ImagePickerViewController: UIViewControllerRepresentable {
    @Binding var image: Image?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePickerViewController

        init(_ parent: ImagePickerViewController) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    if let uiImage = image as? UIImage {
                        self.parent.image = Image(uiImage: uiImage)
                    }
                }
            }
        }
    }
}
#endif
