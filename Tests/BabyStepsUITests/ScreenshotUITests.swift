import XCTest

final class ScreenshotUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        // スクリーンショット用のサンプルデータを準備
        prepareSampleData()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Screenshot Tests
    
    func testMainScreenScreenshot() throws {
        // メイン画面のスクリーンショット
        let mainScreen = app.collectionViews.firstMatch
        XCTAssertTrue(mainScreen.waitForExistence(timeout: 5))
        
        // スクリーンショットを撮影
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "01-main-screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testTaskListScreenshot() throws {
        // タスクリストのスクリーンショット
        let taskList = app.collectionViews.firstMatch
        XCTAssertTrue(taskList.waitForExistence(timeout: 5))
        
        // スクリーンショットを撮影
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "02-task-list"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testAddTaskScreenshot() throws {
        // タスク追加画面のスクリーンショット
        let addButton = app.buttons["Add Task"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()
        
        // モーダルが表示されるまで待機
        let addTaskModal = app.otherElements["AddTaskModal"]
        XCTAssertTrue(addTaskModal.waitForExistence(timeout: 5))
        
        // スクリーンショットを撮影
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "03-add-task"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // モーダルを閉じる
        let cancelButton = app.buttons["Cancel"]
        cancelButton.tap()
    }
    
    func testTaskDetailScreenshot() throws {
        // タスク詳細画面のスクリーンショット
        let firstTask = app.collectionViews.cells.firstMatch
        XCTAssertTrue(firstTask.waitForExistence(timeout: 5))
        firstTask.tap()
        
        // 詳細画面が表示されるまで待機
        let detailView = app.otherElements["TaskDetailView"]
        XCTAssertTrue(detailView.waitForExistence(timeout: 5))
        
        // スクリーンショットを撮影
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "04-task-detail"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // 戻る
        let backButton = app.navigationBars.buttons.firstMatch
        backButton.tap()
    }
    
    func testProgressViewScreenshot() throws {
        // 進捗表示画面のスクリーンショット
        let progressView = app.otherElements["ProgressView"]
        XCTAssertTrue(progressView.waitForExistence(timeout: 5))
        
        // スクリーンショットを撮影
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "05-progress-view"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    // MARK: - Helper Methods
    
    private func prepareSampleData() {
        // サンプルタスクを作成
        let addButton = app.buttons["Add Task"]
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()
            
            let titleField = app.textFields["Task Title"]
            let descriptionField = app.textFields["Task Description"]
            
            if titleField.waitForExistence(timeout: 3) {
                titleField.tap()
                titleField.typeText("朝のルーティン")
                
                if descriptionField.waitForExistence(timeout: 3) {
                    descriptionField.tap()
                    descriptionField.typeText("毎日の朝の習慣を管理")
                }
                
                let saveButton = app.buttons["Save"]
                saveButton.tap()
            }
        }
        
        // アプリが安定するまで待機
        Thread.sleep(forTimeInterval: 2)
    }
}