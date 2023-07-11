//
//  OAuth2CookieStorage.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 10.07.2023.
//

import WebKit

final class OAuth2CookieStorage {
    static func clean() {
       HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

       WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
          records.forEach { record in
             WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
          }
       }
    }
}
