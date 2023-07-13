//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 13.07.2023.
//
import Foundation

public protocol WebViewPresenterProtocol {
    var viewController: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var viewController: WebViewViewControllerProtocol?
    var authHelper: AuthHelperProtocol

    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }

    func viewDidLoad() {
        didUpdateProgressValue(0.0)
        loadWebViewContent()
    }

    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        viewController?.setProgressValue(newProgressValue)

        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        viewController?.setProgressHidden(shouldHideProgress)
    }

    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }

    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }

    private func loadWebViewContent() {
        let request = authHelper.authRequest()
        viewController?.load(request: request)
    }
}
