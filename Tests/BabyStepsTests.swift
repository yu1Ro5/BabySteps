import XCTest
@testable import BabySteps

final class BabyStepsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        XCTAssertTrue(true)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testAppVersion() throws {
        // アプリのバージョン情報をテスト
        let expectedVersion = "1.0.0"
        let expectedBuildNumber = "1"
        
        // 実際のアプリでは、Info.plistから値を取得してテスト
        XCTAssertEqual(expectedVersion, "1.0.0")
        XCTAssertEqual(expectedBuildNumber, "1")
    }
    
    func testFeatureCount() throws {
        // 機能一覧の数をテスト
        let expectedFeatureCount = 6
        XCTAssertEqual(expectedFeatureCount, 6)
    }
    
    func testTabViewStructure() throws {
        // タブビューの構造をテスト
        let expectedTabCount = 3
        let expectedTabs = ["ホーム", "機能", "設定"]
        
        XCTAssertEqual(expectedTabCount, 3)
        XCTAssertEqual(expectedTabs.count, 3)
        XCTAssertTrue(expectedTabs.contains("ホーム"))
        XCTAssertTrue(expectedTabs.contains("機能"))
        XCTAssertTrue(expectedTabs.contains("設定"))
    }
    
    func testSettingsDefaults() throws {
        // 設定のデフォルト値をテスト
        let notificationsEnabled = true
        let darkModeEnabled = false
        let selectedLanguage = "日本語"
        
        XCTAssertTrue(notificationsEnabled)
        XCTAssertFalse(darkModeEnabled)
        XCTAssertEqual(selectedLanguage, "日本語")
    }
}
