import XCTest

final class ScreenCaptureTests: XCTestCase {

    private enum Identifier {
        static let splashBrand = "splash.brand"
        static let pageIndicator = "onboarding.pageIndicator"
        static let primaryAction = "onboarding.primaryAction"
        static let homeTitle = "home.title"
        static let premiumButton = "home.premiumButton"
        static let premiumTitle = "premium.title"
        static let premiumClose = "premium.close"
        static let premiumSubscribe = "premium.subscribe"

        static func premiumPlan(_ plan: String) -> String {
            "premium.plan.\(plan)"
        }
    }

    private enum Timing {
        static let launchTimeout: TimeInterval = 15
        static let transitionTimeout: TimeInterval = 10
        static let settle: TimeInterval = 1.5
    }

    private static let designSplashProgress = "0.88"
    private static let onboardingPages = [
        (capture: "02-onboarding-welcome", indicator: "Page 1 of 3"),
        (capture: "03-onboarding-add-keyboard", indicator: "Page 2 of 3"),
        (capture: "04-onboarding-full-access", indicator: "Page 3 of 3")
    ]
    private static let premiumPlans = ["weekly", "monthly", "yearly"]
    private static let defaultPremiumPlan = "monthly"
    private static let frameTolerance: CGFloat = 0.5

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

        var indicatorFrame: CGRect?
        var actionFrame: CGRect?

        for page in Self.onboardingPages {
            let indicator = element(Identifier.pageIndicator, label: page.indicator, in: app)
            XCTAssertTrue(
                indicator.waitForExistence(timeout: Timing.transitionTimeout),
                "Onboarding page '\(page.indicator)' did not appear"
            )
            settle()
            capture(page.capture)

            let primaryAction = element(Identifier.primaryAction, in: app)
            XCTAssertTrue(primaryAction.waitForExistence(timeout: Timing.transitionTimeout))

            if let indicatorFrame, let actionFrame {
                assertFrame(indicator.frame, equals: indicatorFrame, "Page indicator moved on '\(page.indicator)'")
                assertFrame(primaryAction.frame, equals: actionFrame, "Primary action moved on '\(page.indicator)'")
            }
            indicatorFrame = indicator.frame
            actionFrame = primaryAction.frame

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
    func test03PremiumScreen() {
        let app = XCUIApplication()
        app.launchArguments += ["-NKInitialRoute", "home"]
        app.launch()

        XCTAssertTrue(
            element(Identifier.homeTitle, in: app).waitForExistence(timeout: Timing.launchTimeout),
            "Home screen did not appear"
        )

        let premiumButton = element(Identifier.premiumButton, in: app)
        XCTAssertTrue(premiumButton.waitForExistence(timeout: Timing.transitionTimeout), "Premium button is missing")
        premiumButton.tap()

        XCTAssertTrue(
            element(Identifier.premiumTitle, in: app).waitForExistence(timeout: Timing.transitionTimeout),
            "Premium screen did not appear"
        )
        XCTAssertTrue(element(Identifier.premiumSubscribe, in: app).exists, "Subscribe button is missing")
        assertSelectedPlan(Self.defaultPremiumPlan, in: app)
        settle()
        capture("06-premium")

        for plan in ["weekly", "yearly", "monthly"] {
            element(Identifier.premiumPlan(plan), in: app).tap()
            assertSelectedPlan(plan, in: app)
            if plan == "yearly" {
                settle()
                capture("07-premium-yearly-selected")
            }
        }

        element(Identifier.premiumClose, in: app).tap()

        XCTAssertTrue(
            waitForDisappearance(of: element(Identifier.premiumTitle, in: app)),
            "Premium screen did not close"
        )
        XCTAssertTrue(
            element(Identifier.homeTitle, in: app).waitForExistence(timeout: Timing.transitionTimeout),
            "Home screen did not reappear after closing Premium"
        )
        settle()
        capture("08-home-after-premium")
    }

    @MainActor
    private func assertSelectedPlan(_ selectedPlan: String, in app: XCUIApplication) {
        for plan in Self.premiumPlans {
            let card = element(Identifier.premiumPlan(plan), in: app)
            XCTAssertTrue(card.waitForExistence(timeout: Timing.transitionTimeout), "Plan '\(plan)' is missing")
            XCTAssertEqual(
                card.isSelected,
                plan == selectedPlan,
                "Plan '\(plan)' selection should be \(plan == selectedPlan) after selecting '\(selectedPlan)'"
            )
        }
    }

    private func assertFrame(_ frame: CGRect, equals expected: CGRect, _ message: String) {
        XCTAssertEqual(frame.minX, expected.minX, accuracy: Self.frameTolerance, message)
        XCTAssertEqual(frame.minY, expected.minY, accuracy: Self.frameTolerance, message)
        XCTAssertEqual(frame.width, expected.width, accuracy: Self.frameTolerance, message)
        XCTAssertEqual(frame.height, expected.height, accuracy: Self.frameTolerance, message)
    }

    @MainActor
    private func element(_ identifier: String, label: String? = nil, in app: XCUIApplication) -> XCUIElement {
        let predicate = label.map { NSPredicate(format: "identifier == %@ AND label == %@", identifier, $0) }
            ?? NSPredicate(format: "identifier == %@", identifier)
        return app.descendants(matching: .any).matching(predicate).firstMatch
    }

    @MainActor
    private func waitForDisappearance(of element: XCUIElement) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: element)
        return XCTWaiter.wait(for: [expectation], timeout: Timing.transitionTimeout) == .completed
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
