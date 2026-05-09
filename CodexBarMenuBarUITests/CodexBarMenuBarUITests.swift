//
//  CodexBarMenuBarUITests.swift
//  CodexBarMenuBarUITests
//
//  Created by LoboAI on 2026/5/7.
//

import XCTest

final class CodexBarMenuBarUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
