//
//  WebViewPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Тимур Танеев on 13.07.2023.
//

@testable import ImageFeed
import Foundation

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    
    var viewController: WebViewViewControllerProtocol?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didUpdateProgressValue(_ newValue: Double) {

    }

    func code(from url: URL) -> String? {
        return nil
    }

    func didTapBackButton() {

    }

    func didAuthenticate(withCode code: String) {

    }
}
