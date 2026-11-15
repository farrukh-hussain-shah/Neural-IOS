import XCTest

final class ScreenCaptureTests: XCTestCase {

    private enum Identifier {
        static let splashBrand = "splash.brand"
        static let pageIndicator = "onboarding.pageIndicator"
        static let primaryAction = "onboarding.primaryAction"
        static let homeTitle = "home.title"
    }

    private enum Timing {
        static let launchTimeout: TimeInterval = 15
        static let transitionTimeout: TimeInterval = 10
        static let settle: TimeInterval = 1.5
    }

    private static let designSplashProgress = "0.88"
    private static let onboardingPages = [
        (capture: "02-onboarding-welcome", indicator: "Page 1 of 4"),
        (capture: "03-onboarding-add-keyboard", indicator: "Page 2 of 4"),
        (capture: "04-onboarding-full-access", indicator: "Page 3 of 4")
    ]

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func test01SplashScreen() {
        let app = XCUIApplication()
        app.launchArguments += ["-NKSplashFrozenProgress", Self.designSplashProgress]
        app.launch()

        XCTAssertTrue(
            element(Identifier.splashBrand, in: app).waitForExistence(timeout: Timing.launchTimeout),
            "Splash screen did not appear"
        )
        settle()
        capture("01-splash")
    }

    @MainActor
    func test02OnboardingToHomeFlow() {
        let app = XCUIApplication()
        app.launch()

        for page in Self.onboardingPages {
            XCTAssertTrue(
                element(Identifier.pageIndicator, label: page.indicator, in: app)
                    .waitForExistence(timeout: Timing.transitionTimeout),
                "Onboarding page '\(page.indicator)' did not appear"
            )
            settle()
            capture(page.capture)

            let primaryAction = element(Identifier.primaryAction, in: app)
            XCTAssertTrue(primaryAction.waitForExistence(timeout: Timing.transitionTimeout))
            primaryAction.tap()
        }

        XCTAssertTrue(
            element(Identifier.homeTitle, in: app).waitForExistence(timeout: Timing.transitionTimeout),
            "Home screen did not appear"
        )
        settle()
        capture("05-home")
    }

    @MainActor
    private func element(_ identifier: String, label: String? = nil, in app: XCUIApplication) -> XCUIElement {
        let predicate = label.map { NSPredicate(format: "identifier == %@ AND label == %@", identifier, $0) }
            ?? NSPredicate(format: "identifier == %@", identifier)
        return app.descendants(matching: .any).matching(predicate).firstMatch
    }

    private func settle() {
        Thread.sleep(forTimeInterval: Timing.settle)
    }

    @MainActor
    private func capture(_ name: String) {
        let screenshot = XCUIScreen.main.screenshot()

        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        guard let directory = ProcessInfo.processInfo.environment["NK_CAPTURE_DIR"], !directory.isEmpty else { return }
        let directoryURL = URL(fileURLWithPath: directory, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            try screenshot.pngRepresentation.write(to: directoryURL.appendingPathComponent("\(name).png"))
        } catch {
            XCTFail("Could not save screenshot \(name): \(error)")
        }
    }
}
