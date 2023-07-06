//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 06.07.2023.
//

import Foundation

struct PhotoResult: Decodable {
    var id: String
    var createdAt: String?
    var width: Int
    var height: Int
    var likedByUser: Bool
    var description: String?
    var urls: UrlsResult
}

struct UrlsResult: Decodable {
    var thumb: String
    var full: String
}

struct PhotoResults: Decodable {
    var photoResults: [PhotoResult]
}
