//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 11.06.2023.
//

import Foundation

final class ProfileImageService {

    static let shared = ProfileImageService()
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")

    private let networkClient = NetworkClient()
    private let profileImageURLPath = "/users"
    private var task: URLSessionTask?
    private (set) var avatarURL: String?

    func fetchProfileImageURL(_ token: String, username: String, _ completion: @escaping (Result<String, Error>) -> Void) {

        task?.cancel()

        let request = networkClient.makeGetRequest(token,
                                                   path: profileImageURLPath,
                                                   requestParams: ["username": username])
        let task = networkClient.getDecodedObject(for: request,
                                                  of: UserResult.self) { [weak self] result in
            switch result {
            case .success(let userResult):
                if let smallImageURLString = userResult.profileImage?["small"] {
                    self?.avatarURL = smallImageURLString
                    completion(.success(smallImageURLString))
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.DidChangeNotification,
                            object: self,
                            userInfo: ["URL": smallImageURLString])
                }
                else {
                    completion(.failure(NetworkError.JSONError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
            self?.task = nil
        }
        self.task = task
        task.resume()
    }
}
