//
//  Photo.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 06.07.2023.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool

    init(photoResult: PhotoResult) {
        self.id = photoResult.id
        self.size = CGSize(width: photoResult.width, height: photoResult.height)

        let dateFormatter = ISO8601DateFormatter()
        self.createdAt = dateFormatter.date(from: photoResult.createdAt ?? "")

        self.welcomeDescription = photoResult.description
        self.thumbImageURL = photoResult.urls.thumb
        self.largeImageURL = photoResult.urls.full
        self.isLiked = photoResult.likedByUser
    }

    mutating func setIsLiked(to isLiked: Bool) {
        self.isLiked = isLiked
    }
}
