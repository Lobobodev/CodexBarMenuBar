//
//  CodexBarMenuBarUITestsLaunchTests.swift
//  CodexBarMenuBarUITests
//
//  Created by LoboAI on 2026/5/7.
//

import XCTest

final class CodexBarMenuBarUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
