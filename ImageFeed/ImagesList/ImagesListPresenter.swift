//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 18.07.2023.
//

import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var numberOfPhotos: Int { get }
    var viewController: ImagesListViewControllerProtocol! {get set}

    func viewDidLoad()
    func getPhoto(at: IndexPath) -> Photo?
    func fetchPhotosNextPage()
    func changeLike(for indexPath: IndexPath, _ completion: @escaping (Result<Bool, Error>) -> Void)
}

final class ImagesListPresenter {
    var numberOfPhotos: Int {
        get { imageListDataSource.numberOfPhotos }
    }
    weak var viewController: ImagesListViewControllerProtocol!
    var imageListDataSource: ImagesListDataSourceProtocol!

    init(viewController: ImagesListViewController, dataSource: ImagesListDataSourceProtocol) {
        self.viewController = viewController
        self.imageListDataSource = dataSource
    }

    private func dataSourceDidChange() {
        viewController.updateTableViewAnimated()
    }
}

// MARK: ImagesListPresenterProtocol
extension ImagesListPresenter: ImagesListPresenterProtocol {
    func viewDidLoad() {
        NotificationCenter.default.addObserver(
            forName: imageListDataSource.DidChangeNotification,
            object: nil,
            queue: .main) {[weak self] _ in
                self?.dataSourceDidChange()
            }

        if imageListDataSource.numberOfPhotos == 0 {
            imageListDataSource.fetchPhotosNextPage()
        }
    }

    func getPhoto(at indexPath: IndexPath) -> Photo? {
        imageListDataSource.photo(at: indexPath.row)
    }

    func fetchPhotosNextPage() {
        imageListDataSource.fetchPhotosNextPage()
    }

    func changeLike(for indexPath: IndexPath, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let photo = getPhoto(at: indexPath) else {return}

        imageListDataSource.changeLike(photoId: photo.id, isLike: !photo.isLiked) {result in
            completion(result)
        }
    }
}
