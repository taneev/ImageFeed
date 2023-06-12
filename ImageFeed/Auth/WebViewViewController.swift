//
//  WebViewController.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 03.06.2023.
//

import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {

    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    private var estimatedProgressObservation: NSKeyValueObservation?

    weak var delegate: WebViewViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self

        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: [],
            changeHandler: { [weak self] _, _ in
                guard let self = self else { return }
                self.updateProgress()
            })

        var urlComponents = URLComponents(string: UnsplashAuthorizeURLString)!
        urlComponents.queryItems = [
           URLQueryItem(name: "client_id", value: AccessKey),
           URLQueryItem(name: "redirect_uri", value: RedirectURI),
           URLQueryItem(name: "response_type", value: "code"),
           URLQueryItem(name: "scope", value: AccessScope)
        ]
        let url = urlComponents.url!

        let request = URLRequest(url: url)
        webView.load(request)
        updateProgress()
    }

    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }

    @IBAction func didTapBackButton(_ sender: Any) {
        delegate?.webViewViewControllerDidCancel(self)
    }
}

extension WebViewViewController: WKNavigationDelegate {
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        }
        else {
            return nil
        }
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        }
        else {
            decisionHandler(.allow)
        }
    }
}

