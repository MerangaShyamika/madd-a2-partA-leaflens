import Observation
import PhotosUI
import SwiftUI

/// Drives the scan flow: photo selection, classification and result state.
@MainActor
@Observable
final class ScanViewModel {
    enum State: Equatable {
        case idle
        case loading
        case scanning
        case result([Prediction])
        case error(String)
    }

    /// Below this confidence the result screen asks for a clearer photo.
    static let confidenceThreshold = 0.6

    /// Minimum gap between the top two predictions before we trust the answer.
    static let marginThreshold = 0.2

    var state: State = .idle
    var selectedImage: UIImage?
    var pickerItem: PhotosPickerItem?

    private let classifier: ClassifierServicing
    private let scanAnimationDelay: Duration

    /// Inject a fake classifier and zero delay in unit tests.
    init(classifier: ClassifierServicing = ClassifierService.shared,
         scanAnimationDelay: Duration = .seconds(1.2)) {
        self.classifier = classifier
        self.scanAnimationDelay = scanAnimationDelay
    }

    /// The most likely prediction once a scan has finished.
    var topPrediction: Prediction? {
        if case .result(let predictions) = state { return predictions.first }
        return nil
    }

    /// True only when the top prediction is confident AND clearly ahead of the runner-up.
    var isConfident: Bool {
        guard case .result(let predictions) = state, let top = predictions.first else { return false }
        let runnerUp = predictions.dropFirst().first?.confidence ?? 0
        return top.confidence >= Self.confidenceThreshold
            && (top.confidence - runnerUp) >= Self.marginThreshold
    }

    /// Loads the photo chosen in the PhotosPicker, then classifies it.
    func loadSelectedPhoto() async {
        guard let item = pickerItem else { return }
        state = .loading
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                state = .error(ClassifierError.invalidImage.localizedDescription)
                return
            }
            await classify(image)
        } catch {
            state = .error(ClassifierError.invalidImage.localizedDescription)
        }
    }

    /// Runs the classifier and keeps the scan animation visible briefly.
    func classify(_ image: UIImage) async {
        selectedImage = image
        state = .scanning
        do {
            let predictions = try await classifier.classify(image)
            try? await Task.sleep(for: scanAnimationDelay)
            state = .result(predictions)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    /// Clears everything so the user can scan again.
    func reset() {
        state = .idle
        selectedImage = nil
        pickerItem = nil
    }
}
