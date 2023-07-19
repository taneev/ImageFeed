//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 30.04.2023.
//

import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol! { get set }
    func updateTableViewAnimated()
}

final class ImagesListViewController: UIViewController {

    private lazy var tableView: UITableView = { createTableView() }()
    private let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
    var presenter: ImagesListPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        presenter.viewDidLoad()
    }
}

// MARK: ImagesListViewControllerProtocol
extension ImagesListViewController: ImagesListViewControllerProtocol {

    func updateTableViewAnimated() {
        tableView.performBatchUpdates { [weak self] in
            guard let self else {return}

            let lastAddedPhotosRange = self.tableView.numberOfRows(inSection: 0) ..< presenter.numberOfPhotos
            let lastAddedIndexPaths: [IndexPath] = lastAddedPhotosRange.map{IndexPath(row: $0, section: 0)}
            self.tableView.insertRows(at: lastAddedIndexPaths, with: .automatic)
        }
    }
}

// MARK: - логика таблицы
extension ImagesListViewController {
    private func showError() {
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

    func getCellHeight(for photo: Photo) -> CGFloat {
        let cellImageSize = photo.size

        if cellImageSize.width == 0 {
            return 0
        }

        let imageScaleFactor = (tableView.bounds.width - imageInsets.left - imageInsets.right) / cellImageSize.width

        let imageViewHeight = cellImageSize.height * imageScaleFactor
        let cellHeight = imageViewHeight + imageInsets.bottom + imageInsets.top

        return cellHeight
    }
}

// MARK: UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let photo = presenter.getPhoto(at: indexPath) else {return}

        let singleImageViewController = SingleImageViewController()
        let imageURL = photo.largeImageURL

        singleImageViewController.imageURL = imageURL
        singleImageViewController.modalPresentationStyle = .fullScreen
        present(singleImageViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter.getPhoto(at: indexPath) else {return 0}

        let cellHeight = getCellHeight(for: photo)
        return cellHeight
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let visibleRows = tableView.indexPathsForVisibleRows,
           visibleRows.contains(indexPath) {
            if indexPath.row + 1 == presenter.numberOfPhotos {
                presenter.fetchPhotosNextPage()
            }
        }
    }
}

// MARK: UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfPhotos
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let photo = presenter.getPhoto(at: indexPath),
              let imageListCell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell
               else { return UITableViewCell() }

        imageListCell.delegate = self
        imageListCell.config(thumbImageURL: photo.thumbImageURL,
                             createdAt: photo.createdAt,
                             isLiked: photo.isLiked)
        return imageListCell
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {

    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}

        UIBlockingProgressHUD.show()
        presenter.changeLike(for: indexPath) {[weak self] result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let isLiked):
                cell.setIsLiked(to: isLiked)
            case .failure:
                self?.showError()
            }
        }
    }
}
