//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 30.04.2023.
//

import UIKit

class ImagesListViewController: UIViewController {


    @IBOutlet private var tableView: UITableView!

    private let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
    private let mockImageDate = Date()

    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }

}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath)
    {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        cell.cellImage.image = image

        let imageDate = dateFormatter.string(from: mockImageDate)
        cell.imageDateLabel.text = imageDate

        let likeButtonImage = (indexPath.row % 2 == 0 ? UIImage(named: "Active.png") : UIImage(named: "No Active.png")) ?? UIImage()
        cell.likeButton.imageView?.image = likeButtonImage
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cellImage = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }

        if cellImage.size.width == 0 {
            return 0
        }

        let imageScaleFactor = (tableView.bounds.width - imageInsets.left - imageInsets.right) / cellImage.size.width

        let imageViewHeight = cellImage.size.height * imageScaleFactor
        let cellHeight = imageViewHeight + imageInsets.bottom + imageInsets.top

        return cellHeight
    }
}


extension ImagesListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let imageListCell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }

        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }

}
