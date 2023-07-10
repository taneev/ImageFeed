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

    private var photos: [Photo] = []
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        addConstraints()

        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .ypBlack

        NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main) {[weak self] notification in
                guard let self,
                      let receivedPhotos = notification.object as? [Photo] else {return}
                self.updateTableViewAnimated(receivedPhotos)
            }
        if photos.isEmpty {
            imageListService.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath)
    {
        cell.backgroundColor = .ypBlack
        cell.cellImage.backgroundColor = .ypWhite
        cell.cellImage.alpha = 0.5

        let placeholder = ImagePlaceholderView()
        let thumbImageURL = photos[indexPath.row].thumbImageURL
        guard let url = URL(string: thumbImageURL) else {
            cell.cellImage.addSubview(placeholder)
            return
        }

        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: url,
                                   placeholder: placeholder) {[weak self] _ in
            cell.cellImage.alpha = 1
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        if let imageDate = photos[indexPath.row].createdAt {
            let imageDateString = dateFormatter.string(from: imageDate)
            cell.imageDateLabel.text = imageDateString
        }
        else {
            cell.imageDateLabel.text = ""
        }
        cell.setIsLiked(to: photos[indexPath.row].isLiked)
        cell.updateConstraintsIfNeeded()
    }

    private func updateTableViewAnimated(_ receivedPhotos: [Photo]) {
        tableView.performBatchUpdates {
            let lastAddedPhotosRange = photos.count ..< photos.count + receivedPhotos.count
            let lastAddedIndexPaths: [IndexPath] = lastAddedPhotosRange.map{IndexPath(row: $0, section: 0)}

            photos.append(contentsOf: receivedPhotos)
            tableView.insertRows(at: lastAddedIndexPaths, with: .automatic)
        }
    }

    private func showError() {
        let alertPresenter = AlertPresenter(controller: self)
        let alert = AlertModel(title: "Что-то пошло не так (",
                               message: "Не удалось изменить лайк",
                               buttonText: "Ok")
        alertPresenter.showAlert(alert: alert)
    }
}

// MARK: - верстка
extension ImagesListViewController {
    private func createTableView() -> UITableView {
        let tableView = UITableView()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.dataSource = self
        tableView.delegate = self

        return tableView
    }

    private func addConstraints() {
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
        let imageURL = photos[indexPath.row].largeImageURL

        singleImageViewController.imageURL = imageURL
        singleImageViewController.modalPresentationStyle = .fullScreen
        present(singleImageViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellImageSize = photos[indexPath.row].size

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
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let imageListCell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }

        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imageListService.fetchPhotosNextPage()
        }
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {

    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}

        UIBlockingProgressHUD.show()
        let photo = photos[indexPath.row]
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) {[weak self] result in
            guard let self else {return}

            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let isLiked):
                self.photos[indexPath.row].setIsLiked(to: isLiked)
                cell.setIsLiked(to: isLiked)
            case .failure:
                self.showError()
            }
        }
    }
}
