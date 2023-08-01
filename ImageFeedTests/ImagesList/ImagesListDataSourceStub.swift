//
//  ImagesListDataSourceStub.swift
//  ImageFeedTests
//
//  Created by Тимур Танеев on 19.07.2023.
//
import ImageFeed
import Foundation

final class ImageListDataSourceStub: ImagesListDataSourceProtocol {
    var fetchPhotosDidCall: Bool = false
    var didChangeNotification: Notification.Name {
        get {Notification.Name("stub")}
    }

    var numberOfPhotos: Int {
        get {0}
    }

    func photo(at index: Int) -> ImageFeed.Photo? {
        return nil
    }

    func fetchPhotosNextPage() {
        fetchPhotosDidCall = true
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Bool, Error>) -> Void) {

    }
}
