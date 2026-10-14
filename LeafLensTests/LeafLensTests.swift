import CoreML
import SwiftData
import UIKit
import XCTest
@testable import LeafLens

// MARK: - Test helpers

/// Fake classifier so ScanViewModel can be tested without the real model.
struct FakeClassifier: ClassifierServicing {
    var result: Result<[Prediction], Error>

    func classify(_ image: UIImage) async throws -> [Prediction] {
        try result.get()
    }
}

/// Creates a plain coloured image for tests.
func makeTestImage(width: CGFloat = 300, height: CGFloat = 300) -> UIImage {
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1
    return UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format).image { context in
        UIColor.systemGreen.setFill()
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
    }
}

// MARK: - ScanViewModel

final class ScanViewModelTests: XCTestCase {

    @MainActor
    func testStartsIdle() {
        let viewModel = ScanViewModel(classifier: FakeClassifier(result: .success([])), scanAnimationDelay: .zero)
        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertNil(viewModel.selectedImage)
    }

    @MainActor
    func testSuccessfulScanShowsResult() async {
        let predictions = [Prediction(label: "Tomato late blight", confidence: 0.9),
                           Prediction(label: "Tomato early blight", confidence: 0.05)]
        let viewModel = ScanViewModel(classifier: FakeClassifier(result: .success(predictions)), scanAnimationDelay: .zero)

        await viewModel.classify(makeTestImage())

        XCTAssertEqual(viewModel.state, .result(predictions))
        XCTAssertEqual(viewModel.topPrediction?.label, "Tomato late blight")
        XCTAssertNotNil(viewModel.selectedImage)
    }

    @MainActor
    func testFailedScanShowsError() async {
        let viewModel = ScanViewModel(classifier: FakeClassifier(result: .failure(ClassifierError.noResults)), scanAnimationDelay: .zero)

        await viewModel.classify(makeTestImage())

        XCTAssertEqual(viewModel.state, .error(ClassifierError.noResults.localizedDescription))
        XCTAssertNil(viewModel.topPrediction)
    }

    @MainActor
    func testConfidentWhenHighAndClearlyAhead() async {
        let viewModel = ScanViewModel(classifier: FakeClassifier(result: .success([
            Prediction(label: "Tomato healthy", confidence: 0.90),
            Prediction(label: "Tomato leaf mould", confidence: 0.05)
        ])), scanAnimationDelay: .zero)

        await viewModel.classify(makeTestImage())

        XCTAssertTrue(viewModel.isConfident)
    }

    @MainActor
    func testNotConfidentWhenBelowThreshold() async {
        let viewModel = ScanViewModel(classifier: FakeClassifier(result: .success([
            Prediction(label: "Tomato healthy", confidence: 0.55),
            Prediction(label: "Tomato leaf mould", confidence: 0.20)
        ])), scanAnimationDelay: .zero)

        await viewModel.classify(makeTestImage())

        XCTAssertFalse(viewModel.isConfident, "55% is below the 60% threshold")
    }

    @MainActor
    func testNotConfidentWhenTopTwoAreClose() async {
        let viewModel = ScanViewModel(classifier: FakeClassifier(result: .success([
            Prediction(label: "Tomato early blight", confidence: 0.65),
            Prediction(label: "Tomato septoria leaf spot", confidence: 0.50)
        ])), scanAnimationDelay: .zero)

        await viewModel.classify(makeTestImage())

        XCTAssertFalse(viewModel.isConfident, "A 15-point gap is below the 20-point margin")
    }

    @MainActor
    func testResetClearsEverything() async {
        let viewModel = ScanViewModel(classifier: FakeClassifier(result: .success([
            Prediction(label: "Tomato healthy", confidence: 0.9)
        ])), scanAnimationDelay: .zero)
        await viewModel.classify(makeTestImage())

        viewModel.reset()

        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertNil(viewModel.selectedImage)
        XCTAssertNil(viewModel.pickerItem)
    }
}

// MARK: - SwiftData models

final class PersistenceTests: XCTestCase {
    private var container: ModelContainer!

    @MainActor
    override func setUp() async throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Plant.self, ScanRecord.self, configurations: configuration)
    }

    override func tearDown() {
        container = nil
    }

    @MainActor
    func testInsertAndFetchPlant() throws {
        let context = container.mainContext
        context.insert(Plant(name: "Tomato 1", species: "Tomato"))
        try context.save()

        let plants = try context.fetch(FetchDescriptor<Plant>())
        XCTAssertEqual(plants.count, 1)
        XCTAssertEqual(plants.first?.name, "Tomato 1")
    }

    @MainActor
    func testScansAreLinkedToPlant() throws {
        let context = container.mainContext
        let plant = Plant(name: "Chilli", species: "Chilli")
        context.insert(plant)
        plant.scans.append(ScanRecord(diseaseLabel: "Pepper healthy", confidence: 0.9))
        plant.scans.append(ScanRecord(diseaseLabel: "Pepper bacterial spot", confidence: 0.8))
        try context.save()

        XCTAssertEqual(plant.scans.count, 2)
        XCTAssertTrue(plant.scans.allSatisfy { $0.plant === plant })
    }

    @MainActor
    func testDeletingPlantDeletesItsScans() throws {
        let context = container.mainContext
        let plant = Plant(name: "Tomato 2", species: "Tomato")
        context.insert(plant)
        plant.scans.append(ScanRecord(diseaseLabel: "Tomato healthy", confidence: 0.9))
        plant.scans.append(ScanRecord(diseaseLabel: "Tomato late blight", confidence: 0.7))
        try context.save()
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<ScanRecord>()), 2)

        context.delete(plant)
        try context.save()

        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Plant>()), 0)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<ScanRecord>()), 0, "Cascade rule should delete scans")
    }

    @MainActor
    func testLatestScanIsMostRecent() throws {
        let context = container.mainContext
        let plant = Plant(name: "Beans", species: "Long Beans")
        context.insert(plant)
        let older = ScanRecord(date: .now.addingTimeInterval(-86_400), diseaseLabel: "Tomato healthy", confidence: 0.9)
        let newer = ScanRecord(date: .now, diseaseLabel: "Tomato early blight", confidence: 0.8)
        plant.scans.append(older)
        plant.scans.append(newer)

        XCTAssertEqual(plant.latestScan?.diseaseLabel, "Tomato early blight")
    }

    func testIsHealthyFlag() {
        XCTAssertTrue(ScanRecord(diseaseLabel: "Tomato healthy", confidence: 0.9).isHealthy)
        XCTAssertFalse(ScanRecord(diseaseLabel: "Tomato late blight", confidence: 0.9).isHealthy)
    }
}

// MARK: - Disease info and model labels

final class DiseaseInfoTests: XCTestCase {

    func testEveryModelLabelHasDiseaseInfo() throws {
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .cpuOnly
        let model = try LeafClassifier(configuration: configuration).model
        let labels = model.modelDescription.classLabels as? [String] ?? []

        XCTAssertEqual(labels.count, 7)
        for label in labels {
            let info = DiseaseInfo.forLabel(label)
            XCTAssertNotEqual(info.summary, "No extra information is available for this result yet.",
                              "Missing DiseaseInfo for \(label)")
            XCTAssertFalse(info.actions.isEmpty, "No actions for \(label)")
        }
    }

    func testUnknownLabelGetsSafeFallback() {
        let info = DiseaseInfo.forLabel("Mango anthracnose")
        XCTAssertEqual(info.label, "Mango anthracnose")
        XCTAssertFalse(info.actions.isEmpty)
    }

    func testHealthyDetection() {
        XCTAssertTrue(DiseaseInfo.forLabel("Pepper healthy").isHealthy)
        XCTAssertFalse(DiseaseInfo.forLabel("Pepper bacterial spot").isHealthy)
    }
}

// MARK: - Real Core ML classifier

final class ClassifierServiceTests: XCTestCase {

    func testRealModelReturnsValidSortedPredictions() async throws {
        let predictions = try await ClassifierService.shared.classify(makeTestImage())

        XCTAssertFalse(predictions.isEmpty)
        XCTAssertLessThanOrEqual(predictions.count, 3)
        for prediction in predictions {
            XCTAssertTrue((0...1).contains(prediction.confidence))
        }
        let confidences = predictions.map(\.confidence)
        XCTAssertEqual(confidences, confidences.sorted(by: >), "Predictions should be sorted, most likely first")
    }

    func testClassificationIsFastEnough() async throws {
        _ = try await ClassifierService.shared.classify(makeTestImage()) // warm up: loads the model
        let start = Date()
        _ = try await ClassifierService.shared.classify(makeTestImage())
        XCTAssertLessThan(Date().timeIntervalSince(start), 2.0, "A scan should take under 2 seconds")
    }
}

// MARK: - Image storage

final class ImageStorageTests: XCTestCase {

    func testLargeImageIsDownscaledBeforeSaving() throws {
        let large = makeTestImage(width: 3000, height: 2000)
        let data = try XCTUnwrap(large.jpegDataForStorage())
        let saved = try XCTUnwrap(UIImage(data: data))

        XCTAssertLessThanOrEqual(max(saved.size.width, saved.size.height), 1024)
    }

    func testSmallImageKeepsItsSize() throws {
        let small = makeTestImage(width: 500, height: 400)
        let data = try XCTUnwrap(small.jpegDataForStorage())
        let saved = try XCTUnwrap(UIImage(data: data))

        XCTAssertEqual(saved.size.width, 500)
        XCTAssertEqual(saved.size.height, 400)
    }
}

// MARK: - Nearby search categories

final class NearbyCategoryTests: XCTestCase {

    func testEveryCategoryHasQueryAndIcon() {
        for category in NearbyViewModel.Category.allCases {
            XCTAssertFalse(category.query.isEmpty)
            XCTAssertFalse(category.icon.isEmpty)
        }
    }
}
