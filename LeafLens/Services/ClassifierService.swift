import CoreML
import ImageIO
import UIKit
import Vision

/// One prediction from the model: a label and its confidence (0...1).
struct Prediction: Identifiable, Hashable {
    let label: String
    let confidence: Double
    var id: String { label }
}

/// Abstraction so unit tests can inject a fake classifier.
protocol ClassifierServicing {
    func classify(_ image: UIImage) async throws -> [Prediction]
}

/// Errors the classifier can report to the user.
enum ClassifierError: LocalizedError {
    case invalidImage
    case modelUnavailable
    case noResults

    var errorDescription: String? {
        switch self {
        case .invalidImage: "That photo could not be read. Please try another one."
        case .modelUnavailable: "The leaf model could not be loaded."
        case .noResults: "The model could not recognise this photo."
        }
    }
}

/// Runs the Create ML LeafClassifier model on-device with Vision.
/// Works offline, keeps photos private and costs nothing per scan.
final class ClassifierService: ClassifierServicing {
    static let shared = ClassifierService()

    /// Loaded once, on the first scan, so app launch stays fast.
    private lazy var visionModel: VNCoreMLModel? = {
        let configuration = MLModelConfiguration()
        #if targetEnvironment(simulator)
        // Simulator fix: the simulator has no GPU/Neural Engine access for Core ML.
        configuration.computeUnits = .cpuOnly
        #endif
        guard let model = try? LeafClassifier(configuration: configuration).model else {
            return nil
        }
        return try? VNCoreMLModel(for: model)
    }()

    /// Returns the top 3 predictions. Runs off the main thread so the UI never freezes.
    func classify(_ image: UIImage) async throws -> [Prediction] {
        guard let cgImage = image.cgImage else { throw ClassifierError.invalidImage }
        guard let model = visionModel else { throw ClassifierError.modelUnavailable }
        let orientation = CGImagePropertyOrientation(image.imageOrientation)

        return try await Task.detached(priority: .userInitiated) {
            let request = VNCoreMLRequest(model: model)
            request.imageCropAndScaleOption = .centerCrop

            #if targetEnvironment(simulator)
            // Simulator fix: force Vision to run this request on the CPU.
            request.usesCPUOnly = true
            #endif

            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation)
            try handler.perform([request])

            let observations = (request.results as? [VNClassificationObservation]) ?? []
            let top = observations.prefix(3).map {
                Prediction(label: $0.identifier, confidence: Double($0.confidence))
            }
            guard !top.isEmpty else { throw ClassifierError.noResults }
            return top
        }.value
    }
}

extension CGImagePropertyOrientation {
    /// Converts UIKit's image orientation to the one Vision expects.
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
