import XCTest

final class ScreenshotUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        // アプリが完全に起動するまで待機
        Thread.sleep(forTimeInterval: 3)
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Screenshot Tests
    
    func testMainScreenScreenshot() throws {
        // メイン画面のスクリーンショット
        // アプリが起動して安定するまで待機
        let mainScreen = app.windows.firstMatch
        XCTAssertTrue(mainScreen.waitForExistence(timeout: 10), "Main screen should be visible")
        
        // スクリーンショットを撮影
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "01-main-screen"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        print("✅ Main screen screenshot captured successfully")
    }
}