//
//  ImagesListPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Тимур Танеев on 19.07.2023.
//
import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {

    var viewDidLoadDidCall: Bool = false

    var numberOfPhotos: Int {
        get { 1 }
    }

    var viewController: ImageFeed.ImagesListViewControllerProtocol!

    func viewDidLoad() {
        viewDidLoadDidCall = true
    }

    func getPhoto(at: IndexPath) -> ImageFeed.Photo? {
        return nil
    }

    func fetchPhotosNextPage() {

    }

    func changeLike(for indexPath: IndexPath, _ completion: @escaping (Result<Bool, Error>) -> Void) {

    }


}
