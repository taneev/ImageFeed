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
    private let perPage = 10
    private var currentTask: URLSessionTask?

    private var lastLoadedPage: Int?

    func fetchPhotosNextPage() {
        guard let token = KeychainWrapper.standard.string(forKey: tokenKey) else {
            assertionFailure("Token is not set")
            return
        }
        guard currentTask == nil else {return}

        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1

        let requestParams = [
            "page": "\(nextPage)",
            "per_page": "\(perPage)"]

        let request = networkClient.makeGetRequest(token,
                                                   path: imageListURLPath,
                                                   requestParams: requestParams)

        let task = networkClient.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else {return}
            switch result {
            case .success(let photoResults):
                DispatchQueue.main.async {[weak self] in

                    let receivedPhotos = photoResults.map{Photo(photoResult: $0)}
                    self?.photos.append(contentsOf: receivedPhotos)
                    self?.currentTask = nil
                    self?.lastLoadedPage = nextPage

                    NotificationCenter.default
                        .post(
                            name: ImagesListService.DidChangeNotification,
                            object: self)
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
}
