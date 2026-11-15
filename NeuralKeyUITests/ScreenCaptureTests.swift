import XCTest

final class ScreenCaptureTests: XCTestCase {

    private enum Identifier {
        static let splashBrand = "splash.brand"
        static let languageTitle = "language.title"
        static let languageDone = "language.done"
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

        static func languageOption(_ language: String) -> String {
            "language.option.\(language)"
        }
    }

    private enum Timing {
        static let launchTimeout: TimeInterval = 15
        static let transitionTimeout: TimeInterval = 10
        static let settle: TimeInterval = 1.5
    }

    private static let designSplashProgress = "0.88"
    private static let onboardingPages = [
        (capture: "03-onboarding-welcome", indicator: "Page 1 of 3"),
        (capture: "04-onboarding-add-keyboard", indicator: "Page 2 of 3"),
        (capture: "05-onboarding-full-access", indicator: "Page 3 of 3")
    ]
    private static let languages = ["english", "spanish", "portuguese", "russian", "arabic", "chinese", "hindi"]
    private static let defaultLanguage = "english"
    private static let persistedLanguage = "arabic"
    private static let firstOnboardingPage = "Page 1 of 3"
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
    func test02LanguageSelection() {
        let app = XCUIApplication()
        app.launchArguments += ["-NKInitialRoute", "language", "-NKSelectedLanguage", Self.defaultLanguage]
        app.launch()

        XCTAssertTrue(
            element(Identifier.languageTitle, in: app).waitForExistence(timeout: Timing.launchTimeout),
            "Language selection did not appear"
        )
        assertExclusiveSelection(Self.defaultLanguage, among: Self.languages, identifier: Identifier.languageOption, in: app)
        settle()
        capture("02-language")

        for language in Self.languages.reversed() {
            element(Identifier.languageOption(language), in: app).tap()
            assertExclusiveSelection(language, among: Self.languages, identifier: Identifier.languageOption, in: app)
        }

        element(Identifier.languageOption(Self.persistedLanguage), in: app).tap()
        assertExclusiveSelection(Self.persistedLanguage, among: Self.languages, identifier: Identifier.languageOption, in: app)
        element(Identifier.languageDone, in: app).tap()
        XCTAssertTrue(
            element(Identifier.pageIndicator, label: Self.firstOnboardingPage, in: app)
                .waitForExistence(timeout: Timing.transitionTimeout),
            "Onboarding did not follow language selection"
        )
        app.terminate()

        let relaunched = XCUIApplication()
        relaunched.launchArguments += ["-NKInitialRoute", "language"]
        relaunched.launch()
        XCTAssertTrue(
            element(Identifier.languageTitle, in: relaunched).waitForExistence(timeout: Timing.launchTimeout),
            "Language selection did not appear after relaunch"
        )
        assertExclusiveSelection(
            Self.persistedLanguage,
            among: Self.languages,
            identifier: Identifier.languageOption,
            in: relaunched
        )
        element(Identifier.languageOption(Self.defaultLanguage), in: relaunched).tap()
        assertExclusiveSelection(Self.defaultLanguage, among: Self.languages, identifier: Identifier.languageOption, in: relaunched)
    }

    @MainActor
    func test03OnboardingToHomeFlow() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(
            element(Identifier.splashBrand, in: app).waitForExistence(timeout: Timing.launchTimeout),
            "Splash screen did not appear"
        )
        let languageDone = element(Identifier.languageDone, in: app)
        XCTAssertTrue(
            languageDone.waitForExistence(timeout: Timing.launchTimeout),
            "Language selection did not follow the splash screen"
        )
        languageDone.tap()

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
        capture("06-home")
    }

    @MainActor
    func test04PremiumScreen() {
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
        assertExclusiveSelection(Self.defaultPremiumPlan, among: Self.premiumPlans, identifier: Identifier.premiumPlan, in: app)
        settle()
        capture("07-premium")

        for plan in ["weekly", "yearly", "monthly"] {
            element(Identifier.premiumPlan(plan), in: app).tap()
            assertExclusiveSelection(plan, among: Self.premiumPlans, identifier: Identifier.premiumPlan, in: app)
            if plan == "yearly" {
                settle()
                capture("08-premium-yearly-selected")
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
        capture("09-home-after-premium")
    }

    @MainActor
    private func assertExclusiveSelection(
        _ selected: String,
        among options: [String],
        identifier: (String) -> String,
        in app: XCUIApplication
    ) {
        for option in options {
            let optionElement = element(identifier(option), in: app)
            XCTAssertTrue(optionElement.waitForExistence(timeout: Timing.transitionTimeout), "Option '\(option)' is missing")
            XCTAssertEqual(
                optionElement.isSelected,
                option == selected,
                "Option '\(option)' selection should be \(option == selected) after selecting '\(selected)'"
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
