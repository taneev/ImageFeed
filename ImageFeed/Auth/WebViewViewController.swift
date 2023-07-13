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

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

final class WebViewViewController: UIViewController {

    var presenter: WebViewPresenterProtocol?
    private lazy var webView: WKWebView = {setupWebView()}()
    private lazy var backButton: UIButton = {setupButton()}()
    private lazy var progressView: UIProgressView = {setupProgressView()}()

    private var estimatedProgressObservation: NSKeyValueObservation?

    weak var delegate: WebViewViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()

        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] webView, change in
                 guard let self = self else { return }
                 self.presenter?.didUpdateProgressValue(change.newValue ?? webView.estimatedProgress)
             })

        presenter?.viewDidLoad()
    }

    @objc private func didTapBackButton(_ sender: Any) {
        delegate?.webViewViewControllerDidCancel(self)
    }
}

// MARK: управление ViewController'ом из Presenter'а
extension WebViewViewController: WebViewViewControllerProtocol {
    func load(request: URLRequest) {
        webView.load(request)
    }

    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
}

// MARK: Инициализация UI и верстка
private extension WebViewViewController {
    func setupViews() {
        view.addSubview(webView)
        view.addSubview(backButton)
        view.addSubview(progressView)
        setupConstraints()
    }

    func setupConstraints() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.topAnchor.constraint(equalTo: view.topAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

                backButton.widthAnchor.constraint(equalToConstant: 44),
                backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor),
                backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 9),
                backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),

                progressView.topAnchor.constraint(equalTo: backButton.bottomAnchor),
                progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ]
        )
    }

    func setupWebView() -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = self

        return webView
    }

    func setupButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "nav_back_button"), for: .normal)
        button.tintColor = .ypBlack
        button.addTarget(self, action: #selector(didTapBackButton(_:)), for: .touchUpInside)
        return button
    }

    func setupProgressView() -> UIProgressView {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = .ypBlack
        return progress
    }
}

// MARK: делегат управления webView
extension WebViewViewController: WKNavigationDelegate {
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        if let code = code(from: navigationAction) {
            decisionHandler(.cancel)
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
        }
        else {
            decisionHandler(.allow)
        }
    }
}

