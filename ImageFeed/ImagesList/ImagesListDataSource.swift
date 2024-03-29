//
//  ImagesListDataSource.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 18.07.2023.
//
import UIKit

public protocol ImagesListDataSourceProtocol {
    var  didChangeNotification: Notification.Name { get }
    var  numberOfPhotos: Int { get }

    func photo(at index: Int) -> Photo?
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Bool, Error>) -> Void)
}
