//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Тимур Танеев on 16.07.2023.
//

import XCTest

class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testAuth() throws {
        app.buttons["Authenticate"].tap()

        let webView = app.webViews["UnsplashWebView"]

        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))

        loginTextField.tap()
        webView.swipeUp()
        loginTextField.typeText("<Логин>")
        if app.keyboards.element(boundBy: 0).exists {
            app.toolbars.buttons["Done"].tap()
        }

        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))

        passwordTextField.tap()
        webView.swipeUp()
        passwordTextField.typeText("<Пароль>")
        if app.keyboards.element(boundBy: 0).exists {
            app.toolbars.buttons["Done"].tap()
        }

        webView.buttons["Login"].tap()

        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)

        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }

    func testFeed() throws {
        // Данный вариант теста работает при условии невысокой скорости соединения
        // Тест успешно проходит на скорости до 256 kbps (в обе стороны)
        let tableView = app.tables["imageListTableView"]
        // лайк
        tableView.cells.element(boundBy: 0).buttons["likeButton"].tap()

        // еще раз нажатие той же кнопки
        tableView.cells.element(boundBy: 0).buttons["likeButton"].tap()

        // работа с изображением
        let cellToZoom = tableView.cells.element(boundBy: 0)
        cellToZoom.tap()

        let image = app.scrollViews.images.element(boundBy: 0)
        // на рабочей для теста скорости картинка читается очень долго.
        // Для больших размеров - более минуты
        XCTAssertTrue(image.waitForExistence(timeout: 120))

        // увеличить
        image.pinch(withScale: 3, velocity: 1)
        // уменьшить
        image.pinch(withScale: 0.5, velocity: -1)

        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        XCTAssertTrue(navBackButtonWhiteButton.waitForExistence(timeout: 5))

        navBackButtonWhiteButton.tap()
        XCTAssertTrue(cellToZoom.waitForExistence(timeout: 5))

        // скроллинг ленты
        cellToZoom.swipeUp()
    }

    func testProfile() throws {
        // Подождать, пока открывается и загружается экран ленты
        sleep(5)
        // Перейти на экран профиля
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(2)
        // Проверить, что на нём отображаются ваши персональные данные
        XCTAssertTrue(app.staticTexts["@taneev"].exists)
        XCTAssertTrue(app.staticTexts["Timur Taneev"].exists)
        XCTAssertTrue(app.staticTexts["some bio"].exists)
        // Нажать кнопку логаута
        app.buttons["logoutButton"].tap()
        sleep(2)
        let alert = app.alerts["Пока, пока!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3))
        alert.scrollViews.otherElements.buttons["Да"].tap()
        // Проверить, что открылся экран авторизации
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
    }
}
