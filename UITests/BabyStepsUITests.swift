import XCTest

final class BabyStepsUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
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
        
        // アイコンが上部に配置されていることを確認
        XCTAssertTrue(iconFrame.minY < titleFrame.minY, "アイコンがタイトルの上に配置されていません")
        
        // タイトルがサブタイトルの上に配置されていることを確認
        XCTAssertTrue(titleFrame.minY < subtitleFrame.minY, "タイトルがサブタイトルの上に配置されていません")
        
        // 各要素が画面中央に配置されていることを確認（左右の中央揃え）
        let screenWidth = UIScreen.main.bounds.width
        let titleCenterX = titleFrame.midX
        let subtitleCenterX = subtitleFrame.midX
        let iconCenterX = iconFrame.midX
        
        let tolerance: CGFloat = 20.0 // 中央揃えの許容誤差
        
        XCTAssertTrue(abs(titleCenterX - screenWidth / 2) < tolerance, "タイトルが画面中央に配置されていません")
        XCTAssertTrue(abs(subtitleCenterX - screenWidth / 2) < tolerance, "サブタイトルが画面中央に配置されていません")
        XCTAssertTrue(abs(iconCenterX - screenWidth / 2) < tolerance, "アイコンが画面中央に配置されていません")
    }
    
    func testScreenOrientation() throws {
        // 画面の向きが縦向き（Portrait）であることを確認
        let orientation = XCUIDevice.shared.orientation
        XCTAssertEqual(orientation, .portrait, "画面が縦向きではありません")
        
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
        XCTAssertTrue(titleText.isAccessibilityElement, "タイトルがアクセシビリティ要素として認識されていません")
        XCTAssertTrue(subtitleText.isAccessibilityElement, "サブタイトルがアクセシビリティ要素として認識されていません")
        
        // フォントサイズとスタイルの確認
        let titleFont = titleText.font
        let subtitleFont = subtitleText.font
        
        // タイトルがlargeTitleフォントであることを確認
        XCTAssertEqual(titleFont, .largeTitle, "タイトルがlargeTitleフォントではありません")
        
        // サブタイトルがtitle2フォントであることを確認
        XCTAssertEqual(subtitleFont, .title2, "サブタイトルがtitle2フォントではありません")
    }
    
    func testLayoutSpacing() throws {
        // レイアウトの間隔が適切であることを確認
        let titleText = app.staticTexts["BabySteps"]
        let subtitleText = app.staticTexts["Hello, iOS!"]
        let checkmarkIcon = app.images["checkmark.circle.fill"]
        
        let titleFrame = titleText.frame
        let subtitleFrame = subtitleText.frame
        let iconFrame = checkmarkIcon.frame
        
        // アイコンとタイトルの間隔を確認（20ポイントのspacing）
        let iconToTitleSpacing = titleFrame.minY - iconFrame.maxY
        XCTAssertTrue(iconToTitleSpacing >= 15 && iconToTitleSpacing <= 25, 
                     "アイコンとタイトルの間隔が適切ではありません（期待値: 20±5ポイント、実際: \(iconToTitleSpacing)ポイント）")
        
        // タイトルとサブタイトルの間隔を確認（20ポイントのspacing）
        let titleToSubtitleSpacing = subtitleFrame.minY - titleFrame.maxY
        XCTAssertTrue(titleToSubtitleSpacing >= 15 && titleToSubtitleSpacing <= 25,
                     "タイトルとサブタイトルの間隔が適切ではありません（期待値: 20±5ポイント、実際: \(titleToSubtitleSpacing)ポイント）")
        
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
        
        // アイコンのサイズが適切であることを確認
        let iconSize = checkmarkIcon.frame.size
        XCTAssertTrue(iconSize.width >= 50 && iconSize.width <= 70, 
                     "アイコンの幅が適切ではありません（期待値: 50-70ポイント、実際: \(iconSize.width)ポイント）")
        XCTAssertTrue(iconSize.height >= 50 && iconSize.height <= 70,
                     "アイコンの高さが適切ではありません（期待値: 50-70ポイント、実際: \(iconSize.height)ポイント）")
        
        // アイコンが円形であることを確認（幅と高さがほぼ同じ）
        let aspectRatio = iconSize.width / iconSize.height
        XCTAssertTrue(abs(aspectRatio - 1.0) < 0.1, 
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
}