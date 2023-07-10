//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 06.07.2023.
//

import Foundation
import SwiftKeychainWrapper

final class ImagesListService {

    static var shared = ImagesListService()
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")

    private(set) var photos: [Photo] = []
    private let tokenKey = "UnsplashBearerToken"

    private let networkClient = NetworkClient()
    private let imageListURLPath = "/photos"
    private let likeURLPathFormat = "/photos/%@/like"
    private let pageSize = 10
    private var currentTask: URLSessionTask?

    private var lastLoadedPage: Int?

    func fetchPhotosNextPage() {
        guard let token = OAuth2TokenStorage().token else {
            assertionFailure("Token is not set")
            return
        }
        guard currentTask == nil else {return}

        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1

        let requestParams = [
            "page": "\(nextPage)",
            "per_page": "\(pageSize)"]

        let request = networkClient.makeGetRequest(token,
                                                   path: imageListURLPath,
                                                   requestParams: requestParams)

        let task = networkClient.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else {return}
            switch result {
            case .success(let photoResults):
                DispatchQueue.main.async {[weak self] in
                    guard let self else {return}

                    let receivedPhotos = photoResults.map{Photo(photoResult: $0)}
                    self.photos.append(contentsOf: receivedPhotos)
                    self.currentTask = nil
                    self.lastLoadedPage = nextPage

                    NotificationCenter.default
                        .post(
                            name: ImagesListService.DidChangeNotification,
                            object: self.photos.count)
                }
            case .failure:
                DispatchQueue.main.async {[weak self] in
                    self?.currentTask = nil
                }
                assertionFailure("Ошибка получения списка фото")
            }
        }
        task.resume()
        currentTask = task
    }

    func changeLike(photoId: String,
                    isLike: Bool,
                    _ completion: @escaping (Result<Bool, Error>) -> Void) {

        guard let token = OAuth2TokenStorage().token else {
            assertionFailure("Token is not set")
            return
        }

        let urlPath = String(format: likeURLPathFormat, photoId)
        let httpMethod = isLike ? "POST" : "DELETE"
        let request = networkClient.makeRequest(token, path: urlPath, httpMethod: httpMethod)

        let task = networkClient.objectTask(for: request) {(result: Result<LikePhotoResult, Error>) in
            switch result {
            case .success(let likePhotoResult):
                DispatchQueue.main.async {
                    self.setIsLiked(for: photoId, to: isLike)
                    completion(.success(likePhotoResult.photo.likedByUser))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}

extension ImagesListService {

    func setIsLiked(for photoId: String, to isLiked: Bool) {
        guard let index = self.photos.firstIndex(where: {$0.id == photoId}),
              self.photos[index].isLiked != isLiked
        else {return}

        self.photos[index].setIsLiked(to: isLiked)
    }
    
}
