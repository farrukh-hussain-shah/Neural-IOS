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

        static let menuButton = "home.menuButton"
        static let testField = "home.testField"
        static let settingsTitle = "settings.title"
        static let settingsToneAdjustment = "settings.toneAdjustment"
        static let settingsHaptics = "settings.haptics"
        static let tonesTitle = "tones.title"
        static let tonesBack = "tones.back"
        static let tonesUpdate = "tones.update"
        static let appearancePrefix = "settings.appearance."
        static let tonePrefix = "tones.option."
        static let premiumPlanPrefix = "premium.plan."
        static let languageOptionPrefix = "language.option."

        static func premiumPlan(_ plan: String) -> String {
            premiumPlanPrefix + plan
        }

        static func languageOption(_ language: String) -> String {
            languageOptionPrefix + language
        }
    }

    private enum Timing {
        static let launchTimeout: TimeInterval = 15
        static let transitionTimeout: TimeInterval = 10
        static let settle: TimeInterval = 1.5
        static let keyHold: TimeInterval = 0.2
        static let popupHold: TimeInterval = 8
        static let hostTimeout: TimeInterval = 20
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
    private static let appearances = ["system", "dark", "light"]
    private static let defaultToneCount = 10
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
        assertExclusiveSelection(Self.defaultLanguage, among: Self.languages, prefix: Identifier.languageOptionPrefix, in: app)
        settle()
        capture("02-language")

        for language in Self.languages.reversed() {
            element(Identifier.languageOption(language), in: app).tap()
            assertExclusiveSelection(language, among: Self.languages, prefix: Identifier.languageOptionPrefix, in: app)
        }

        element(Identifier.languageOption(Self.persistedLanguage), in: app).tap()
        assertExclusiveSelection(Self.persistedLanguage, among: Self.languages, prefix: Identifier.languageOptionPrefix, in: app)
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
        assertExclusiveSelection(Self.persistedLanguage, among: Self.languages, prefix: Identifier.languageOptionPrefix, in: relaunched)
        element(Identifier.languageOption(Self.defaultLanguage), in: relaunched).tap()
        assertExclusiveSelection(Self.defaultLanguage, among: Self.languages, prefix: Identifier.languageOptionPrefix, in: relaunched)
    }

    @MainActor
    func test03OnboardingToHomeFlow() {
        let app = XCUIApplication()
        app.launchArguments += ["-NKSkipKeyboardSetup", "YES"]
        app.launch()

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
        assertExclusiveSelection(Self.defaultPremiumPlan, among: Self.premiumPlans, prefix: Identifier.premiumPlanPrefix, in: app)
        settle()
        capture("07-premium")

        for plan in ["weekly", "yearly", "monthly"] {
            element(Identifier.premiumPlan(plan), in: app).tap()
            assertExclusiveSelection(plan, among: Self.premiumPlans, prefix: Identifier.premiumPlanPrefix, in: app)
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
    func test05SettingsAndAITones() {
        let app = XCUIApplication()
        app.launchArguments += ["-NKInitialRoute", "home", "-NKResetPreferences", "YES"]
        app.launch()

        XCTAssertTrue(
            element(Identifier.homeTitle, in: app).waitForExistence(timeout: Timing.launchTimeout),
            "Home screen did not appear"
        )
        element(Identifier.menuButton, in: app).tap()

        let settingsTitle = element(Identifier.settingsTitle, in: app)
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: Timing.transitionTimeout), "Settings did not open from the menu")
        assertExclusiveSelection("system", among: Self.appearances, prefix: Identifier.appearancePrefix, in: app)
        settle()
        capture("10-settings")

        for appearance in ["dark", "light", "system"] {
            app.buttons[Identifier.appearancePrefix + appearance].tap()
            assertExclusiveSelection(appearance, among: Self.appearances, prefix: Identifier.appearancePrefix, in: app)
        }

        let haptics = element(Identifier.settingsHaptics, in: app)
        XCTAssertTrue(haptics.waitForExistence(timeout: Timing.transitionTimeout), "Haptic Feedback toggle is missing")
        XCTAssertEqual(haptics.value as? String, "0", "Haptic Feedback should start off")
        haptics.tap()
        XCTAssertEqual(haptics.value as? String, "1", "Haptic Feedback did not turn on")

        element(Identifier.settingsToneAdjustment, in: app).tap()
        XCTAssertTrue(
            element(Identifier.tonesTitle, in: app).waitForExistence(timeout: Timing.transitionTimeout),
            "AI Tones did not open from Settings"
        )
        let update = app.buttons[Identifier.tonesUpdate]
        XCTAssertTrue(update.waitForExistence(timeout: Timing.transitionTimeout), "Update button is missing")
        XCTAssertEqual(selectedCount(prefix: Identifier.tonePrefix, in: app), Self.defaultToneCount)
        XCTAssertFalse(update.isEnabled, "Update should be disabled before any change")
        settle()
        capture("11-ai-tones")

        let translate = app.buttons[Identifier.tonePrefix + "translate"]
        translate.tap()
        XCTAssertTrue(translate.isSelected, "Translate did not become selected")
        XCTAssertTrue(update.isEnabled, "Update should be enabled after a change")
        translate.tap()
        XCTAssertFalse(translate.isSelected, "Translate did not deselect")
        XCTAssertFalse(update.isEnabled, "Update should be disabled when the selection is unchanged")

        let email = app.buttons[Identifier.tonePrefix + "email"]
        email.tap()
        XCTAssertTrue(email.isSelected, "Email did not become selected")
        update.tap()
        XCTAssertTrue(
            waitForDisappearance(of: element(Identifier.tonesTitle, in: app)),
            "Update did not return to Settings"
        )
        XCTAssertTrue(settingsTitle.exists, "Settings is not visible after Update")

        element(Identifier.settingsToneAdjustment, in: app).tap()
        XCTAssertTrue(email.waitForExistence(timeout: Timing.transitionTimeout))
        XCTAssertTrue(email.isSelected, "Saved tone selection was not kept")
        XCTAssertEqual(selectedCount(prefix: Identifier.tonePrefix, in: app), Self.defaultToneCount + 1)
        element(Identifier.tonesBack, in: app).tap()
        XCTAssertTrue(
            waitForDisappearance(of: element(Identifier.tonesTitle, in: app)),
            "Back did not return to Settings"
        )

        app.swipeRight()
        XCTAssertTrue(waitForDisappearance(of: settingsTitle), "Swiping right did not close Settings")
        XCTAssertTrue(element(Identifier.homeTitle, in: app).exists, "Home is not visible after closing Settings")
        settle()
        capture("12-home-after-settings")
    }

    @MainActor
    func test06InAppKeyboard() {
        let app = XCUIApplication()
        app.launchArguments += ["-NKInitialRoute", "home"]
        app.launch()

        let field = app.textFields[Identifier.testField]
        XCTAssertTrue(field.waitForExistence(timeout: Timing.launchTimeout), "Test field is missing")
        field.tap()
        XCTAssertTrue(key("q", in: app).waitForExistence(timeout: Timing.transitionTimeout), "In-app keyboard did not appear")
        XCTAssertEqual(key("q", in: app).label, "Q", "An empty field should start capitalized")

        type("hello", in: app)
        assertFieldText(field, equals: "Hello")
        let verbatim = app.buttons["keyboard.suggestion.0"]
        XCTAssertEqual(verbatim.label, "“Hello”", "The typed word should be offered as the first suggestion")
        verbatim.tap()
        assertFieldText(field, equals: "Hello ")

        type("worl", in: app)
        keyElement("key.delete", in: app).tap()
        assertFieldText(field, equals: "Hello wor")

        keyElement("key.shift", in: app).tap()
        XCTAssertEqual(key("l", in: app).label, "L", "Shift should capitalize the next letter")
        type("l", in: app)
        XCTAssertEqual(key("d", in: app).label, "d", "Shift should release after one letter")
        type("d", in: app)
        assertFieldText(field, equals: "Hello worLd")

        keyElement("key.shift", in: app).doubleTap()
        type("ab", in: app)
        assertFieldText(field, equals: "Hello worLdAB")
        keyElement("key.shift", in: app).tap()
        XCTAssertEqual(key("c", in: app).label, "c", "Caps lock should turn off")

        keyElement("key.layer.123", in: app).tap()
        XCTAssertTrue(key("1", in: app).waitForExistence(timeout: Timing.transitionTimeout), "Numbers layer did not open")
        type("7", in: app)
        keyElement("key.layer.#+=", in: app).tap()
        XCTAssertTrue(key("[", in: app).waitForExistence(timeout: Timing.transitionTimeout), "Symbols layer did not open")
        settle()
        capture("18-keyboard-symbols")
        type("#", in: app)
        keyElement("key.space", in: app).tap()
        XCTAssertTrue(key("q", in: app).waitForExistence(timeout: Timing.transitionTimeout), "Space should return to letters")
        assertFieldText(field, equals: "Hello worLdAB7# ")

        type("ok", in: app)
        keyElement("key.space", in: app).doubleTap()
        assertFieldText(field, equals: "Hello worLdAB7# ok. ")
        XCTAssertEqual(key("q", in: app).label, "Q", "A new sentence should start capitalized")

        key("e", in: app).press(forDuration: 1.2)
        XCTAssertTrue(fieldText(field).hasSuffix("È"), "Long-press should insert the first accented alternate")

        keyElement("key.return", in: app).tap()
        XCTAssertTrue(waitForDisappearance(of: key("q", in: app)), "Return should dismiss the keyboard")
    }

    @MainActor
    func test07KeyboardDesignStates() {
        let states: [(capture: String, arguments: [String], layer: String?)] = [
            ("13-keyboard-letters", ["-NKKeyboardAutoCapitalize", "NO"], nil),
            ("14-keyboard-numbers", ["-NKKeyboardSuggestions", "NO"], "key.layer.123"),
            ("15-keyboard-go", [
                "-NKKeyboardSuggestions", "NO", "-NKKeyboardSystemRow", "NO",
                "-NKKeyboardReturnKey", "go", "-NKKeyboardAutoCapitalize", "NO"
            ], nil),
            ("16-keyboard-phone", ["-NKKeyboardType", "phonePad"], nil),
            ("17-keyboard-popup", ["-NKKeyboardAutoCapitalize", "NO", "-NKKeyboardPreviewKey", "g"], nil)
        ]

        for state in states {
            let app = XCUIApplication()
            app.launchArguments += ["-NKInitialRoute", "home"] + state.arguments
            app.launch()
            let field = app.textFields[Identifier.testField]
            XCTAssertTrue(field.waitForExistence(timeout: Timing.launchTimeout), "Test field is missing")
            field.tap()
            XCTAssertTrue(
                keyElement("key.delete", in: app).waitForExistence(timeout: Timing.transitionTimeout),
                "Keyboard did not appear for \(state.capture)"
            )
            if let layer = state.layer {
                keyElement(layer, in: app).tap()
            }
            if state.capture == "16-keyboard-phone" {
                type("5", in: app)
                assertFieldText(field, equals: "5")
                keyElement("key.delete", in: app).tap()
            }
            settle()
            capture(state.capture)
            app.terminate()
        }
    }

    @MainActor
    func test08KeyboardSetupThroughSettings() {
        let app = XCUIApplication()
        app.launchArguments += ["-NKInitialRoute", "onboarding"]
        app.launch()

        let primaryAction = element(Identifier.primaryAction, in: app)
        XCTAssertTrue(primaryAction.waitForExistence(timeout: Timing.launchTimeout), "Onboarding did not appear")
        primaryAction.tap()
        XCTAssertTrue(
            element(Identifier.pageIndicator, label: "Page 2 of 3", in: app).waitForExistence(timeout: Timing.transitionTimeout),
            "Add Keyboard step did not appear"
        )
        settle()
        capture("20-setup-add-keyboard")

        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        XCTAssertTrue(openSettings(from: app, settings: settings), "Open Settings did not open the Settings app")
        openKeyboardSettings(in: settings)

        let keyboardSwitch = settings.switches["NeuralKey"]
        XCTAssertTrue(keyboardSwitch.waitForExistence(timeout: Timing.transitionTimeout), "NeuralKey keyboard switch is missing in Settings")
        turnOn(keyboardSwitch)
        XCTAssertTrue(waitUntilOn(keyboardSwitch), "NeuralKey keyboard did not turn on")
        settle()
        capture("21-settings-keyboard-added")

        app.activate()
        XCTAssertTrue(
            element(Identifier.pageIndicator, label: "Page 3 of 3", in: app).waitForExistence(timeout: Timing.transitionTimeout),
            "Returning after adding the keyboard should show the Full Access step"
        )
        settle()
        capture("22-setup-full-access")

        XCTAssertTrue(openSettings(from: app, settings: settings), "Open Settings did not reopen Settings")
        openKeyboardSettings(in: settings)
        let fullAccessSwitch = settings.switches["Allow Full Access"]
        XCTAssertTrue(fullAccessSwitch.waitForExistence(timeout: Timing.transitionTimeout), "Allow Full Access switch is missing")
        if switchIsOn(fullAccessSwitch) == false {
            turnOn(fullAccessSwitch)
            let allow = settings.alerts.buttons["Allow"]
            if allow.waitForExistence(timeout: Timing.transitionTimeout) {
                allow.tap()
            }
        }
        XCTAssertTrue(waitUntilOn(fullAccessSwitch), "Full Access did not turn on")
        settle()
        capture("23-settings-full-access")

        // iOS terminates the app when Full Access changes, so this relaunches it;
        // the saved setup progress must bring the user straight to Home.
        app.activate()
        XCTAssertTrue(
            element(Identifier.homeTitle, in: app).waitForExistence(timeout: Timing.launchTimeout),
            "Returning after allowing Full Access should continue to Home"
        )
        settle()
        capture("24-home-after-setup")
    }

    @MainActor
    func test09NeuralKeyKeyboardExtension() {
        let app = XCUIApplication()
        app.launchArguments += ["-NKInitialRoute", "home", "-NKUseSystemKeyboard", "YES"]
        app.launch()

        let field = app.textFields[Identifier.testField]
        XCTAssertTrue(field.waitForExistence(timeout: Timing.launchTimeout), "Test field is missing")
        field.tap()
        if !selectNeuralKeyKeyboard(in: app) {
            // Not enabled yet (test08 normally does it): turn it on in Settings and come back.
            enableNeuralKeyKeyboard()
            app.activate()
            field.tap()
            XCTAssertTrue(selectNeuralKeyKeyboard(in: app), "Could not switch to the NeuralKey keyboard")
        }
        XCTAssertEqual(key("q", in: app).label, "Q", "An empty field should start capitalized")
        settle()
        capture("25-extension-letters")

        type("hello", in: app)
        keyElement("key.space", in: app).tap()
        type("world", in: app)
        assertFieldText(field, equals: "Hello world")
        settle()
        capture("26-extension-typing")

        keyElement("key.layer.123", in: app).tap()
        XCTAssertTrue(key("1", in: app).waitForExistence(timeout: Timing.transitionTimeout), "Numbers layer did not open")
        type("7", in: app)
        assertFieldText(field, equals: "Hello world7")
        settle()
        capture("27-extension-numbers")

        keyElement("key.delete", in: app).tap()
        assertFieldText(field, equals: "Hello world")
        app.terminate()

        // A light keyboard field: NeuralKey should switch to its light look.
        let lightApp = XCUIApplication()
        lightApp.launchArguments += [
            "-NKInitialRoute", "home", "-NKUseSystemKeyboard", "YES", "-NKSystemKeyboardAppearance", "light"
        ]
        lightApp.launch()
        let lightField = lightApp.textFields[Identifier.testField]
        XCTAssertTrue(lightField.waitForExistence(timeout: Timing.launchTimeout), "Test field is missing")
        lightField.tap()
        XCTAssertTrue(selectNeuralKeyKeyboard(in: lightApp), "NeuralKey keyboard is not active in the light field")
        type("hi", in: lightApp)
        assertFieldText(lightField, equals: "Hi")
        settle()
        capture("28-extension-light")
    }

    /// Taps Open Settings, retrying once when a slow simulator drops the tap mid-transition.
    @MainActor
    private func openSettings(from app: XCUIApplication, settings: XCUIApplication) -> Bool {
        for _ in 0..<2 {
            let action = element(Identifier.primaryAction, in: app)
            guard action.waitForExistence(timeout: Timing.transitionTimeout) else { return false }
            action.tap()
            if settings.wait(for: .runningForeground, timeout: Timing.launchTimeout) {
                return true
            }
            app.activate()
        }
        return false
    }

    /// Taps the empty space between and around keys on the NeuralKey keyboard: as on iOS, every
    /// gap belongs to the nearest key, so there is no dead space between the white key faces.
    @MainActor
    func test12KeyTouchAreasCoverGaps() {
        let app = XCUIApplication()
        app.launchArguments += [
            "-NKInitialRoute", "home", "-NKUseSystemKeyboard", "YES",
            "-NKSystemKeyboardAppearance", "light", "-NKSystemKeyboardAutocapitalization", "none"
        ]
        app.launch()
        let field = app.textFields[Identifier.testField]
        XCTAssertTrue(field.waitForExistence(timeout: Timing.launchTimeout), "Test field is missing")
        field.tap()
        if !selectNeuralKeyKeyboard(in: app) {
            enableNeuralKeyKeyboard()
            app.activate()
            field.tap()
            XCTAssertTrue(selectNeuralKeyKeyboard(in: app), "Could not switch to the NeuralKey keyboard")
        }
        settle()

        let q = key("q", in: app).frame
        let w = key("w", in: app).frame
        let p = key("p", in: app).frame
        let a = key("a", in: app).frame
        let l = key("l", in: app).frame
        let z = key("z", in: app).frame
        let shift = keyElement("key.shift", in: app).frame
        let space = keyElement("key.space", in: app).frame
        let screen = app.windows.firstMatch.frame
        print("Key touch areas: q \(q), w \(w), p \(p), a \(a), l \(l), shift \(shift), z \(z), space \(space), screen \(screen)")

        // Touch areas meet edge to edge: no dead space between keys, rows or at the screen edges.
        let tolerance: CGFloat = 0.5
        XCTAssertEqual(q.maxX, w.minX, accuracy: tolerance, "Gap between q and w is not fully covered")
        XCTAssertEqual(shift.maxX, z.minX, accuracy: tolerance, "Gap between shift and z is not fully covered")
        XCTAssertEqual(q.maxY, a.minY, accuracy: tolerance, "Gap between the first and second rows is not fully covered")
        XCTAssertEqual(a.minX, screen.minX, accuracy: tolerance, "Margin left of a is not covered")
        XCTAssertEqual(p.maxX, screen.maxX, accuracy: tolerance, "Margin right of p is not covered")
        // The band below the bottom row is ~7 pt (11.5 design pt minus half a row gap).
        XCTAssertGreaterThan(space.height, q.height + 5, "The bottom row should take touches down to the bottom edge")

        // Taps that land in the empty space still type the nearest key.
        let taps: [(String, CGPoint)] = [
            ("q, right of its face", CGPoint(x: q.maxX - 1, y: q.midY)),
            ("w, left of its face", CGPoint(x: w.minX + 1, y: w.midY)),
            ("a, in the left margin", CGPoint(x: a.minX + 2, y: a.midY)),
            ("l, in the right margin", CGPoint(x: l.maxX - 2, y: l.midY)),
            ("q, below its face", CGPoint(x: q.midX, y: q.maxY - 1)),
            ("a, above its face", CGPoint(x: a.midX, y: a.minY + 1)),
            ("space, below the bottom row", CGPoint(x: space.midX, y: space.maxY - 2)),
            ("z, between shift and z", CGPoint(x: z.minX + 1, y: z.midY))
        ]
        let origin = app.coordinate(withNormalizedOffset: .zero)
        for (description, point) in taps {
            origin.withOffset(CGVector(dx: point.x, dy: point.y)).tap()
            print("Tapped \(description) at \(point): field is now \(fieldText(field))")
        }
        assertFieldText(field, equals: "qwalqa z")
        settle()
        capture("45-touch-areas")
    }

    /// Captures the NeuralKey keyboard in the design's state (lowercase, default suggestions)
    /// in light mode, compared with Keyboard Designs/Defaulta.svg and Defaultb.svg, and dark mode.
    @MainActor
    func test11ExtensionMatchesDesign() {
        for appearance in ["light", "dark"] {
            let app = XCUIApplication()
            app.launchArguments += [
                "-NKInitialRoute", "home", "-NKUseSystemKeyboard", "YES",
                "-NKSystemKeyboardAppearance", appearance, "-NKSystemKeyboardAutocapitalization", "none"
            ]
            app.launch()
            let field = app.textFields[Identifier.testField]
            XCTAssertTrue(field.waitForExistence(timeout: Timing.launchTimeout), "Test field is missing")
            field.tap()
            if !selectNeuralKeyKeyboard(in: app) {
                enableNeuralKeyKeyboard()
                app.activate()
                field.tap()
                XCTAssertTrue(selectNeuralKeyKeyboard(in: app), "Could not switch to the NeuralKey keyboard")
            }
            XCTAssertEqual(key("q", in: app).label, "q", "A field without autocapitalization should start lowercase")
            settle()
            capture("42-extension-letters-\(appearance)")

            keyElement("key.layer.123", in: app).tap()
            XCTAssertTrue(key("1", in: app).waitForExistence(timeout: Timing.transitionTimeout), "Numbers layer did not open")
            settle()
            capture("44-extension-numbers-\(appearance)")
            app.terminate()
        }
    }

    /// A filmed walk through the whole NeuralKey keyboard: it pops up, types with key
    /// bubbles, and covers shift, caps lock, accents, numbers, symbols, delete and return.
    @MainActor
    func test10KeyboardTour() {
        let launchArguments = [
            "-NKInitialRoute", "home", "-NKUseSystemKeyboard", "YES", "-NKSystemKeyboardAppearance", "light"
        ]

        // Make NeuralKey the active keyboard first, so the filmed tap brings it straight up.
        let setup = XCUIApplication()
        setup.launchArguments += launchArguments
        setup.launch()
        let setupField = setup.textFields[Identifier.testField]
        XCTAssertTrue(setupField.waitForExistence(timeout: Timing.launchTimeout), "Test field is missing")
        setupField.tap()
        if !selectNeuralKeyKeyboard(in: setup) {
            enableNeuralKeyKeyboard()
            setup.activate()
            setupField.tap()
            XCTAssertTrue(selectNeuralKeyKeyboard(in: setup), "Could not switch to the NeuralKey keyboard")
        }
        setup.terminate()

        let app = XCUIApplication()
        app.launchArguments += launchArguments
        app.launch()
        let field = app.textFields[Identifier.testField]
        XCTAssertTrue(field.waitForExistence(timeout: Timing.launchTimeout), "Test field is missing")
        settle()

        let isFilming = hostCapture("keyboard-tour", command: "video-start")
        addTeardownBlock { @MainActor in
            if isFilming {
                _ = self.hostCapture("keyboard-tour", command: "video-stop")
            }
        }

        field.tap()
        XCTAssertTrue(key("q", in: app).waitForExistence(timeout: Timing.transitionTimeout), "NeuralKey keyboard did not pop up")
        settle()
        capture("30-tour-keyboard-up")

        holdKey("h", capture: "31-tour-popup-h", in: app)
        tourType("ello", in: app)
        assertFieldText(field, equals: "Hello")
        settle()
        capture("32-tour-hello")

        tourTap("key.space", in: app)
        tourType("world", in: app)
        keyElement("key.space", in: app).doubleTap()
        assertFieldText(field, equals: "Hello world. ")
        settle()
        capture("33-tour-sentence")

        holdKey("e", capture: "34-tour-accents", in: app)
        XCTAssertTrue(fieldText(field).hasSuffix("È"), "Holding e should offer accents and insert the first one")
        tourTap("key.delete", in: app)
        assertFieldText(field, equals: "Hello world. ")

        tourType("i", in: app)
        keyElement("key.shift", in: app).doubleTap()
        tourType("os", in: app)
        assertFieldText(field, equals: "Hello world. IOS")
        settle()
        capture("35-tour-caps-lock")
        tourTap("key.shift", in: app)
        tourTap("key.space", in: app)

        tourTap("key.layer.123", in: app)
        XCTAssertTrue(key("1", in: app).waitForExistence(timeout: Timing.transitionTimeout), "Numbers layer did not open")
        settle()
        capture("36-tour-numbers")
        holdKey("2", capture: "37-tour-popup-2", in: app)
        tourType("026", in: app)

        tourTap("key.layer.#+=", in: app)
        XCTAssertTrue(key("[", in: app).waitForExistence(timeout: Timing.transitionTimeout), "Symbols layer did not open")
        settle()
        capture("38-tour-symbols")
        holdKey("#", capture: "39-tour-popup-hash", in: app)
        tourTap("key.space", in: app)
        XCTAssertTrue(key("q", in: app).waitForExistence(timeout: Timing.transitionTimeout), "Space should return to letters")

        tourType("oj", in: app)
        tourTap("key.delete", in: app)
        tourType("k", in: app)
        assertFieldText(field, equals: "Hello world. IOS 2026# ok")
        settle()
        capture("40-tour-final")

        tourTap("key.return", in: app)
        XCTAssertTrue(waitForDisappearance(of: key("q", in: app)), "Return should close the keyboard")
        settle()
        capture("41-tour-keyboard-closed")
    }

    /// Types with a short hold on each key so its bubble shows in the video, like a finger would.
    @MainActor
    private func tourType(_ characters: String, in app: XCUIApplication) {
        for character in characters {
            key(String(character).lowercased(), in: app).press(forDuration: Timing.keyHold)
        }
    }

    @MainActor
    private func tourTap(_ id: String, in app: XCUIApplication) {
        keyElement(id, in: app).press(forDuration: Timing.keyHold)
    }

    /// Holds a key while the CI host takes a screenshot, so the key bubble (or accent menu) is captured.
    @MainActor
    private func holdKey(_ character: String, capture name: String, in app: XCUIApplication) {
        let element = key(character, in: app)
        XCTAssertTrue(element.waitForExistence(timeout: Timing.transitionTimeout), "Key \(character) is missing")
        let requested = hostCapture(name, command: "screenshot", waitsForHost: false)
        element.press(forDuration: Timing.popupHold)
        if requested {
            XCTAssertTrue(waitForHost(name), "The host did not capture \(name)")
        }
    }

    /// Asks the CI script (scripts/ci/run_simulator_capture.sh) to screenshot or film the simulator.
    /// Returns false when no host is listening, for example when run from Xcode.
    @MainActor
    @discardableResult
    private func hostCapture(_ name: String, command: String, waitsForHost: Bool = true) -> Bool {
        guard let directory = ProcessInfo.processInfo.environment["NK_CAPTURE_DIR"], !directory.isEmpty else { return false }
        let requests = URL(fileURLWithPath: directory, isDirectory: true).appendingPathComponent(".requests", isDirectory: true)
        guard FileManager.default.fileExists(atPath: requests.path) else { return false }
        do {
            try Data(command.utf8).write(to: requests.appendingPathComponent(name + ".request"), options: .atomic)
        } catch {
            return false
        }
        return waitsForHost ? waitForHost(name) : true
    }

    @MainActor
    private func waitForHost(_ name: String) -> Bool {
        guard let directory = ProcessInfo.processInfo.environment["NK_CAPTURE_DIR"] else { return false }
        let request = URL(fileURLWithPath: directory).appendingPathComponent(".requests/\(name).request").path
        let deadline = Date().addingTimeInterval(Timing.hostTimeout)
        while FileManager.default.fileExists(atPath: request), Date() < deadline {
            Thread.sleep(forTimeInterval: 0.1)
        }
        return !FileManager.default.fileExists(atPath: request)
    }

    /// Turns the NeuralKey keyboard on in Settings unless an earlier test already did.
    @MainActor
    private func enableNeuralKeyKeyboard() {
        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        if settings.state == .notRunning {
            settings.launch()
        } else {
            settings.activate()
        }
        openKeyboardSettings(in: settings)
        let keyboardSwitch = settings.switches["NeuralKey"]
        XCTAssertTrue(keyboardSwitch.waitForExistence(timeout: Timing.transitionTimeout), "NeuralKey keyboard switch is missing in Settings")
        turnOn(keyboardSwitch)
        XCTAssertTrue(waitUntilOn(keyboardSwitch), "NeuralKey keyboard did not turn on")
    }

    /// Taps the system globe key until the NeuralKey keyboard is the active one.
    @MainActor
    private func selectNeuralKeyKeyboard(in app: XCUIApplication) -> Bool {
        let nextKeyboard = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label ==[c] %@", "Next keyboard"))
            .firstMatch
        for _ in 0..<5 {
            if key("q", in: app).waitForExistence(timeout: 2) {
                return true
            }
            guard nextKeyboard.waitForExistence(timeout: Timing.transitionTimeout) else {
                print("Next keyboard key not found:\n\(app.debugDescription)")
                return false
            }
            nextKeyboard.tap()
        }
        let found = key("q", in: app).waitForExistence(timeout: Timing.transitionTimeout)
        if !found {
            print("NeuralKey keyboard keys not found:\n\(app.debugDescription)")
        }
        return found
    }

    @MainActor
    private func openKeyboardSettings(in settings: XCUIApplication) {
        if settings.switches["NeuralKey"].waitForExistence(timeout: 3) {
            return
        }
        let keyboards = labelled("Keyboards", in: settings)
        if !keyboards.waitForExistence(timeout: Timing.transitionTimeout) {
            // Settings opened on its root page: go to Apps › NeuralKey instead.
            print("Settings did not open the NeuralKey page:\n\(settings.debugDescription)")
            openAppPage(in: settings)
        }
        guard keyboards.waitForExistence(timeout: Timing.launchTimeout) else {
            print("Keyboards row not found:\n\(settings.debugDescription)")
            XCTFail("Keyboards row is missing in NeuralKey settings")
            return
        }
        keyboards.tap()
    }

    @MainActor
    private func openAppPage(in settings: XCUIApplication) {
        let apps = labelled("Apps", in: settings)
        for _ in 0..<6 where !(apps.exists && apps.isHittable) {
            settings.swipeUp()
        }
        guard apps.exists else { return }
        apps.tap()
        let appRow = labelled("NeuralKey", in: settings)
        for _ in 0..<8 where !(appRow.exists && appRow.isHittable) {
            settings.swipeUp()
        }
        if appRow.exists {
            appRow.tap()
        }
    }

    @MainActor
    private func labelled(_ label: String, in settings: XCUIApplication) -> XCUIElement {
        settings.descendants(matching: .any)
            .matching(NSPredicate(format: "label == %@ AND elementType != %@", label, NSNumber(value: XCUIElement.ElementType.switch.rawValue)))
            .firstMatch
    }

    @MainActor
    private func turnOn(_ toggle: XCUIElement) {
        guard switchIsOn(toggle) != true else { return }
        toggle.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
    }

    @MainActor
    private func waitUntilOn(_ toggle: XCUIElement) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == '1'"), object: toggle)
        return XCTWaiter.wait(for: [expectation], timeout: Timing.transitionTimeout) == .completed
    }

    @MainActor
    private func switchIsOn(_ element: XCUIElement) -> Bool? {
        guard let value = element.value as? String else { return nil }
        return value == "1"
    }

    @MainActor
    private func key(_ character: String, in app: XCUIApplication) -> XCUIElement {
        keyElement("key." + character, in: app)
    }

    @MainActor
    private func keyElement(_ id: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)["keyboard." + id]
    }

    @MainActor
    private func type(_ characters: String, in app: XCUIApplication) {
        for character in characters {
            key(String(character).lowercased(), in: app).tap()
        }
    }

    @MainActor
    private func fieldText(_ field: XCUIElement) -> String {
        field.value as? String ?? ""
    }

    @MainActor
    private func assertFieldText(_ field: XCUIElement, equals expected: String, line: UInt = #line) {
        XCTAssertEqual(fieldText(field), expected, "Field text mismatch", line: line)
    }

    @MainActor
    private func selectedCount(prefix: String, in app: XCUIApplication) -> Int {
        app.buttons
            .matching(NSPredicate(format: "identifier BEGINSWITH %@ AND selected == true", prefix))
            .count
    }

    @MainActor
    private func assertExclusiveSelection(
        _ selected: String,
        among options: [String],
        prefix: String,
        in app: XCUIApplication
    ) {
        let target = app.buttons[prefix + selected]
        XCTAssertTrue(target.waitForExistence(timeout: Timing.transitionTimeout), "Option '\(selected)' is missing")
        XCTAssertTrue(target.isSelected, "Option '\(selected)' is not selected")

        let optionButtons = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", prefix))
        XCTAssertEqual(optionButtons.count, options.count, "Expected \(options.count) options with prefix '\(prefix)'")
        let selectedButtons = optionButtons.matching(NSPredicate(format: "selected == true"))
        XCTAssertEqual(selectedButtons.count, 1, "Exactly one option should be selected after selecting '\(selected)'")
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
