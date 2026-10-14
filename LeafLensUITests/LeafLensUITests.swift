import XCTest

/// End-to-end tests that drive the real app in the Simulator.
final class LeafLensUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Launches with an empty in-memory database. Skips onboarding unless told otherwise.
    private func launchApp(showOnboarding: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"] + (showOnboarding ? ["-resetOnboarding"] : ["-skipOnboarding"])
        app.launch()
        return app
    }

    /// Finds any element whose accessibility label contains the text (case-insensitive).
    private func element(containing text: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[c] %@", text))
            .firstMatch
    }

    /// Adds a plant through the Add Plant sheet.
    private func addPlant(named name: String, in app: XCUIApplication) {
        app.tabBars.buttons["My Garden"].tap()
        app.buttons["Add plant"].tap()

        let nameField = app.textFields.firstMatch
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
        nameField.tap()
        nameField.typeText(name)

        app.buttons["Save"].tap()
    }

    func testOnboardingCanBeCompleted() {
        let app = launchApp(showOnboarding: true)

        let button = app.buttons["onboardingButton"]
        XCTAssertTrue(button.waitForExistence(timeout: 5), "Onboarding should show on first launch")
        button.tap()  // Next
        button.tap()  // Next
        button.tap()  // Get started

        XCTAssertTrue(app.tabBars.buttons["Scan"].waitForExistence(timeout: 3))
    }

    func testAllTabsOpen() {
        let app = launchApp()

        app.tabBars.buttons["My Garden"].tap()
        XCTAssertTrue(app.navigationBars["My Garden"].waitForExistence(timeout: 3))

        app.tabBars.buttons["Nearby"].tap()
        XCTAssertTrue(app.navigationBars["Nearby"].waitForExistence(timeout: 3))

        app.tabBars.buttons["Scan"].tap()
        XCTAssertTrue(app.navigationBars["Scan"].waitForExistence(timeout: 3))
    }

    func testSettingsOpensFromScanTab() {
        let app = launchApp()

        app.buttons["Settings"].tap()

        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3))
    }

    func testAddPlantAppearsInGarden() {
        let app = launchApp()

        addPlant(named: "Tomato Seven", in: app)

        XCTAssertTrue(element(containing: "Tomato Seven", in: app).waitForExistence(timeout: 5))
    }

    func testSwipeToDeletePlant() {
        let app = launchApp()
        addPlant(named: "Delete Me", in: app)

        let row = element(containing: "Delete Me", in: app)
        XCTAssertTrue(row.waitForExistence(timeout: 3))
        row.swipeLeft()
        app.buttons["Delete"].tap()

        XCTAssertFalse(row.waitForExistence(timeout: 2), "Plant should be gone after deleting")
    }
}
