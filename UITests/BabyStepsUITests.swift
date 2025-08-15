import XCTest

final class BabyStepsUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        // アプリの起動完了を待つ（タイムアウトを短縮）
        let titleText = app.staticTexts["BabySteps"]
        XCTAssertTrue(titleText.waitForExistence(timeout: 5), "アプリの起動が完了しませんでした")
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testAppLaunchAndScreenshot() throws {
        // 基本的な要素の存在確認（スクリーンショット撮影の前提条件）
        let titleText = app.staticTexts["BabySteps"]
        let subtitleText = app.staticTexts["Hello, iOS!"]
        let checkmarkIcon = app.images["checkmark.circle.fill"]
        
        // 主要要素が表示されていることを確認
        XCTAssertTrue(titleText.exists, "アプリタイトル「BabySteps」が表示されていません")
        XCTAssertTrue(subtitleText.exists, "サブタイトル「Hello, iOS!」が表示されていません")
        XCTAssertTrue(checkmarkIcon.exists, "チェックマークアイコンが表示されていません")
        
        // メインスクリーンショットを撮影
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Main App Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testPortraitOrientationScreenshot() throws {
        // 縦向きでのスクリーンショットを撮影
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Portrait Orientation"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testAppElementsVisibility() throws {
        // アプリの主要要素が表示されていることを確認
        let titleText = app.staticTexts["BabySteps"]
        let subtitleText = app.staticTexts["Hello, iOS!"]
        let checkmarkIcon = app.images["checkmark.circle.fill"]
        
        // 要素の存在確認
        XCTAssertTrue(titleText.exists, "タイトルが表示されていません")
        XCTAssertTrue(subtitleText.exists, "サブタイトルが表示されていません")
        XCTAssertTrue(checkmarkIcon.exists, "アイコンが表示されていません")
        
        // 要素の可視性確認
        XCTAssertTrue(titleText.isHittable, "タイトルがタップ可能ではありません")
        XCTAssertTrue(subtitleText.isHittable, "サブタイトルがタップ可能ではありません")
        
        // 最終スクリーンショットを撮影
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Elements Visibility Check"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}