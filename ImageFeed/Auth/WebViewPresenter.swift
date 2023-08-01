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
    func didTapBackButton()
    func didAuthenticate(withCode code: String)
}

protocol WebViewPresenterAuthDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var viewController: WebViewViewControllerProtocol?
    weak var delegate: WebViewPresenterAuthDelegate?
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

    func didTapBackButton() {
        guard let webViewViewController = viewController as? WebViewViewController else {return}
        delegate?.webViewViewControllerDidCancel(webViewViewController)
    }

    func didAuthenticate(withCode code: String) {
        guard let webViewViewController = viewController as? WebViewViewController else {return}
        delegate?.webViewViewController(webViewViewController, didAuthenticateWithCode: code)
    }

    private func loadWebViewContent() {
        let request = authHelper.authRequest()
        viewController?.load(request: request)
    }
}
