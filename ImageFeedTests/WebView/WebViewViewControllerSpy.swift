//
//  WebViewViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Тимур Танеев on 13.07.2023.
//

import ImageFeed
import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var loadRequestDidCall: Bool = false

    var presenter: WebViewPresenterProtocol?

    func load(request: URLRequest) {
        loadRequestDidCall = true
    }

    func setProgressValue(_ newValue: Float) {

    }

    func setProgressHidden(_ isHidden: Bool) {
        
    }


}
