//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 03.06.2023.
//

import UIKit

final class AuthViewController: UIViewController {

    private let webViewControllerSegueID = "ShowWebView"

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == webViewControllerSegueID {
            guard let webViewViewController = segue.destination as? WebViewViewController
            else {fatalError("Failed to prepare for \(webViewControllerSegueID)")}

            webViewViewController.delegate = self
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        //TODO: process code
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
