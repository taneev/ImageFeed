//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Тимур Танеев on 13.07.2023.
//

@testable import ImageFeed
import XCTest

final class WebViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let webViewController = WebViewViewController()
        let presenter = WebViewPresenterSpy()

        webViewController.presenter = presenter
        presenter.viewController = webViewController

        //when
        _ = webViewController.view

        //then
        XCTAssertTrue(presenter.viewDidLoadCalled) //behaviour verification
    }

    func testPresenterCallsLoadRequest() {
        //given
        let webViewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)

        webViewController.presenter = presenter
        presenter.viewController = webViewController

        //when
        presenter.viewDidLoad()

        //then
        XCTAssertTrue(webViewController.loadRequestDidCall) //behaviour verification
    }

    func testProgressVisibleWhenLessThenOne() {
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6

        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)

        //then
        XCTAssertFalse(shouldHideProgress)
    }

    func testProgressVisibleWhenOne() {
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1

        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)

        //then
        XCTAssertTrue(shouldHideProgress)
    }

    func testAuthHelperAuthURL() {
        //given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)

        //when
        let url = authHelper.authURL()
        let urlString = url.absoluteString

        //then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }

    func testCodeFromURL() {
        //given
        let authHelper = AuthHelper()
        let testAuthCode = "test code"
        var authURLComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        authURLComponents.queryItems = [URLQueryItem(name: "code", value: testAuthCode)]
        let authURL = authURLComponents.url!

        //when
        let code = authHelper.code(from: authURL)

        //then
        XCTAssertEqual(code, testAuthCode)
    }
}

final class ProfileTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let profileViewController = ProfileViewController()
        let presenter = ProfilePresenterSpy(viewController: profileViewController,
                                            profileDataSource: ProfileDataSourceDummy())

        profileViewController.presenter = presenter

        //when
        _ = profileViewController.view

        //then
        XCTAssertTrue(presenter.viewDidLoadCalled) //behaviour verification
    }

    func testPresentersCallsUpdateAvatar() {
        //given
        let profileViewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(viewController: profileViewController,
                                         profileDataSource: ProfileDataSourceDummy())

        profileViewController.presenter = presenter

        //when
        presenter.viewDidLoad()

        //then
        XCTAssertTrue(profileViewController.updateAvatarCalled)
        XCTAssertTrue(profileViewController.updateProfileDetailsCalled) 
    }
}

final class ImagesListTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let imagesListViewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()

        imagesListViewController.presenter = presenter

        //when
        _ = imagesListViewController.view

        //then
        XCTAssertTrue(presenter.viewDidLoadDidCall) //behaviour verification
    }

    func testPresenterCallsFetchPhotos() {
        //given
        let viewControllerSpy = ImagesListViewController()
        let imageListDataSourceStub = ImageListDataSourceStub()
        let presenter = ImagesListPresenter(viewController: viewControllerSpy,
                                            dataSource: imageListDataSourceStub)

        //when
        presenter.viewDidLoad()

        //then
        XCTAssertTrue(imageListDataSourceStub.fetchPhotosDidCall) //behaviour verification
    }
}
