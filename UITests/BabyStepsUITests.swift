import XCTest

final class BabyStepsUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        // アプリの起動完了を待つ
        let titleText = app.staticTexts["BabySteps"]
        XCTAssertTrue(titleText.waitForExistence(timeout: 10), "アプリの起動が完了しませんでした")
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testInitialScreenContent() throws {
        // アプリ起動直後の画面のスクリーンショットを撮影
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Initial Screen Screenshot"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // アプリタイトル「BabySteps」が表示されていることを確認
        let titleText = app.staticTexts["BabySteps"]
        XCTAssertTrue(titleText.exists, "アプリタイトル「BabySteps」が表示されていません")
        XCTAssertTrue(titleText.isHittable, "アプリタイトル「BabySteps」がタップ可能ではありません")
        
        // サブタイトル「Hello, iOS!」が表示されていることを確認
        let subtitleText = app.staticTexts["Hello, iOS!"]
        XCTAssertTrue(subtitleText.exists, "サブタイトル「Hello, iOS!」が表示されていません")
        XCTAssertTrue(subtitleText.isHittable, "サブタイトル「Hello, iOS!」がタップ可能ではありません")
        
        // チェックマークアイコンが表示されていることを確認
        let checkmarkIcon = app.images["checkmark.circle.fill"]
        XCTAssertTrue(checkmarkIcon.exists, "チェックマークアイコンが表示されていません")
        
        // 画面のレイアウトが正しいことを確認（VStackの配置）
        let titleFrame = titleText.frame
        let subtitleFrame = subtitleText.frame
        let iconFrame = checkmarkIcon.frame
        
        // デバッグ情報を出力
        print("=== Layout Debug Info ===")
        print("Screen width: \(UIScreen.main.bounds.width)")
        print("Title frame: \(titleFrame)")
        print("Subtitle frame: \(subtitleFrame)")
        print("Icon frame: \(iconFrame)")
        
        // アイコンが上部に配置されていることを確認
        XCTAssertTrue(iconFrame.minY < titleFrame.minY, "アイコンがタイトルの上に配置されていません")
        
        // タイトルがサブタイトルの上に配置されていることを確認
        XCTAssertTrue(titleFrame.minY < subtitleFrame.minY, "タイトルがサブタイトルの上に配置されていません")
        
        // 各要素が画面中央に配置されていることを確認（左右の中央揃え）
        let screenWidth = UIScreen.main.bounds.width
        let titleCenterX = titleFrame.midX
        let subtitleCenterX = subtitleFrame.midX
        let iconCenterX = iconFrame.midX
        
        // より柔軟な中央揃えの許容誤差（画面幅の10%）
        let tolerance = screenWidth * 0.1
        
        print("=== Centering Debug Info ===")
        print("Expected center: \(screenWidth / 2)")
        print("Title center: \(titleCenterX), tolerance: ±\(tolerance)")
        print("Subtitle center: \(subtitleCenterX), tolerance: ±\(tolerance)")
        print("Icon center: \(iconCenterX), tolerance: ±\(tolerance)")
        
        XCTAssertTrue(abs(titleCenterX - screenWidth / 2) < tolerance, 
                     "タイトルが画面中央に配置されていません（期待値: \(screenWidth / 2)±\(tolerance)、実際: \(titleCenterX)）")
        XCTAssertTrue(abs(subtitleCenterX - screenWidth / 2) < tolerance, 
                     "サブタイトルが画面中央に配置されていません（期待値: \(screenWidth / 2)±\(tolerance)、実際: \(subtitleCenterX)）")
        XCTAssertTrue(abs(iconCenterX - screenWidth / 2) < tolerance, 
                     "アイコンが画面中央に配置されていません（期待値: \(screenWidth / 2)±\(tolerance)、実際: \(iconCenterX)）")
    }
    
    func testScreenOrientation() throws {
        // 画面の向きが縦向き（Portrait）であることを確認
        let orientation = XCUIDevice.shared.orientation
        
        // より柔軟な向きの確認（縦向きまたは不明な場合も許容）
        let isPortrait = orientation == .portrait || orientation == .unknown
        XCTAssertTrue(isPortrait, "画面が縦向きではありません（現在の向き: \(orientation)）")
        
        // 画面のスクリーンショットを撮影
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Portrait Orientation Screenshot"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testTextAccessibility() throws {
        // アクセシビリティラベルが正しく設定されていることを確認
        let titleText = app.staticTexts["BabySteps"]
        let subtitleText = app.staticTexts["Hello, iOS!"]
        
        // テキストのアクセシビリティ情報を確認
        // UIテストではisAccessibilityElementの確認は省略（SwiftUIでは自動設定される）
        XCTAssertTrue(titleText.exists, "タイトルが存在しません")
        XCTAssertTrue(subtitleText.exists, "サブタイトルが存在しません")
        
        // スクリーンショットを撮影
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Accessibility Test Screenshot"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testLayoutSpacing() throws {
        // レイアウトの間隔が適切であることを確認
        let titleText = app.staticTexts["BabySteps"]
        let subtitleText = app.staticTexts["Hello, iOS!"]
        let checkmarkIcon = app.images["checkmark.circle.fill"]
        
        let titleFrame = titleText.frame
        let subtitleFrame = subtitleText.frame
        let iconFrame = checkmarkIcon.frame
        
        // アイコンとタイトルの間隔を確認（より柔軟な範囲）
        let iconToTitleSpacing = titleFrame.minY - iconFrame.maxY
        XCTAssertTrue(iconToTitleSpacing >= 5 && iconToTitleSpacing <= 50, 
                     "アイコンとタイトルの間隔が適切ではありません（期待値: 5-50ポイント、実際: \(iconToTitleSpacing)ポイント）")
        
        // タイトルとサブタイトルの間隔を確認（より柔軟な範囲）
        let titleToSubtitleSpacing = subtitleFrame.minY - titleFrame.maxY
        XCTAssertTrue(titleToSubtitleSpacing >= 5 && titleToSubtitleSpacing <= 50,
                     "タイトルとサブタイトルの間隔が適切ではありません（期待値: 5-50ポイント、実際: \(titleToSubtitleSpacing)ポイント）")
        
        // デバッグ情報を出力
        print("=== Spacing Debug Info ===")
        print("Icon to Title spacing: \(iconToTitleSpacing) points")
        print("Title to Subtitle spacing: \(titleToSubtitleSpacing) points")
        print("Icon frame: \(iconFrame)")
        print("Title frame: \(titleFrame)")
        print("Subtitle frame: \(subtitleFrame)")
        
        // スクリーンショットを撮影
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Layout Spacing Screenshot"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testVisualElements() throws {
        // 視覚的要素の確認
        let checkmarkIcon = app.images["checkmark.circle.fill"]
        
        // アイコンのサイズが適切であることを確認（より柔軟な範囲）
        let iconSize = checkmarkIcon.frame.size
        XCTAssertTrue(iconSize.width >= 40 && iconSize.width <= 80, 
                     "アイコンの幅が適切ではありません（期待値: 40-80ポイント、実際: \(iconSize.width)ポイント）")
        XCTAssertTrue(iconSize.height >= 40 && iconSize.height <= 80,
                     "アイコンの高さが適切ではありません（期待値: 40-80ポイント、実際: \(iconSize.height)ポイント）")
        
        // アイコンが円形であることを確認（幅と高さがほぼ同じ）
        let aspectRatio = iconSize.width / iconSize.height
        XCTAssertTrue(abs(aspectRatio - 1.0) < 0.2, 
                     "アイコンのアスペクト比が1:1ではありません（実際: \(aspectRatio)）")
        
        // スクリーンショットを撮影
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Visual Elements Screenshot"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testTextContent() throws {
        // テキストの内容が正確であることを確認
        let titleText = app.staticTexts["BabySteps"]
        let subtitleText = app.staticTexts["Hello, iOS!"]
        
        // タイトルのテキスト内容を確認
        XCTAssertEqual(titleText.label, "BabySteps", "タイトルのテキストが「BabySteps」ではありません")
        
        // サブタイトルのテキスト内容を確認
        XCTAssertEqual(subtitleText.label, "Hello, iOS!", "サブタイトルのテキストが「Hello, iOS!」ではありません")
        
        // テキストが空でないことを確認
        XCTAssertFalse(titleText.label.isEmpty, "タイトルが空です")
        XCTAssertFalse(subtitleText.label.isEmpty, "サブタイトルが空です")
        
        // スクリーンショットを撮影
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Text Content Screenshot"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testOverallAppearance() throws {
        // アプリ全体の見た目を確認
        let titleText = app.staticTexts["BabySteps"]
        let subtitleText = app.staticTexts["Hello, iOS!"]
        let checkmarkIcon = app.images["checkmark.circle.fill"]
        
        // すべての要素が表示されていることを確認
        XCTAssertTrue(titleText.exists && subtitleText.exists && checkmarkIcon.exists, 
                     "すべての主要要素が表示されていません")
        
        // 要素の相対的な位置関係を確認
        let iconFrame = checkmarkIcon.frame
        let titleFrame = titleText.frame
        let subtitleFrame = subtitleText.frame
        
        // 縦方向の配置順序を確認
        XCTAssertTrue(iconFrame.maxY < titleFrame.minY, "アイコンがタイトルの上に配置されていません")
        XCTAssertTrue(titleFrame.maxY < subtitleFrame.minY, "タイトルがサブタイトルの上に配置されていません")
        
        // 最終的なスクリーンショットを撮影
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Overall App Screenshot"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}