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
    private let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

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
        if  let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        }
        return nil
    }

    private func loadWebViewContent() {
        var urlComponents = URLComponents(string: UnsplashAuthorizeURLString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: AccessScope)
        ]
        let url = urlComponents.url!

        let request = URLRequest(url: url)
        viewController?.load(request: request)
    }
}
