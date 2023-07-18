//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 30.04.2023.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {

    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    private lazy var tableView: UITableView = { createTableView() }()
    private let imageListService = ImagesListService.shared
    private let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()

        NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main) {[weak self] _ in
                self?.updateTableViewAnimated()
            }

        if imageListService.photos.isEmpty {
            imageListService.fetchPhotosNextPage()
        }
    }
}

// MARK: - логика таблицы
private extension ImagesListViewController {

    func updateTableViewAnimated() {
        tableView.performBatchUpdates { [weak self] in
            guard let self else {return}

            let lastAddedPhotosRange = self.tableView.numberOfRows(inSection: 0) ..< imageListService.photos.count
            let lastAddedIndexPaths: [IndexPath] = lastAddedPhotosRange.map{IndexPath(row: $0, section: 0)}
            self.tableView.insertRows(at: lastAddedIndexPaths, with: .automatic)
        }
    }

    func showError() {
        let alertPresenter = AlertPresenter(controller: self)
        let alert = AlertModel(title: "Что-то пошло не так (",
                               message: "Не удалось изменить лайк",
                               cancelButtonText: "Ok")
        alertPresenter.showAlert(alert: alert)
    }
}

// MARK: - верстка
private extension ImagesListViewController {
    func createTableView() -> UITableView {
        let tableView = UITableView()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.accessibilityIdentifier = "imageListTableView"

        return tableView
    }

    func setupTableView() {
        view.addSubview(tableView)
        addConstraints()

        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .ypBlack
    }

    func addConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
    }
}

// MARK: UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleImageViewController = SingleImageViewController()
        let imageURL = imageListService.photos[indexPath.row].largeImageURL

        singleImageViewController.imageURL = imageURL
        singleImageViewController.modalPresentationStyle = .fullScreen
        present(singleImageViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellImageSize = imageListService.photos[indexPath.row].size

        if cellImageSize.width == 0 {
            return 0
        }

        let imageScaleFactor = (tableView.bounds.width - imageInsets.left - imageInsets.right) / cellImageSize.width

        let imageViewHeight = cellImageSize.height * imageScaleFactor
        let cellHeight = imageViewHeight + imageInsets.bottom + imageInsets.top

        return cellHeight
    }
}

// MARK: UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageListService.photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let imageListCell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }

        imageListCell.delegate = self
        imageListCell.config(thumbImageURL: imageListService.photos[indexPath.row].thumbImageURL,
                             createdAt: imageListService.photos[indexPath.row].createdAt,
                             isLiked: imageListService.photos[indexPath.row].isLiked)
        return imageListCell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == imageListService.photos.count {
            imageListService.fetchPhotosNextPage()
        }
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {

    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}

        UIBlockingProgressHUD.show()
        let photo = imageListService.photos[indexPath.row]
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) {[weak self] result in
            guard let self else {return}

            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let isLiked):
                cell.setIsLiked(to: isLiked)
            case .failure:
                self.showError()
            }
        }
    }
}
