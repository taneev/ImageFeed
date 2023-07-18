//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 01.05.2023.
//

import UIKit

final class ImagesListCell: UITableViewCell {

    static let reuseIdentifier = "ImagesListCell"

    weak var delegate: ImagesListCellDelegate?

    lazy var imageDateLabel: UILabel = { createDateLabel() }()
    lazy var likeButton: UIButton = { createLikeButton() }()
    lazy var cellImage: UIImageView = { createImageView() }()

    private let isLikedImage = UIImage(named: "Active.png") ?? UIImage()
    private let isUnlikedImage = UIImage(named: "No Active.png") ?? UIImage()

    private var isLiked: Bool = false {
        didSet {
            let likeButtonImage = isLiked ? isLikedImage : isUnlikedImage
            likeButton.setImage(likeButtonImage, for: .normal)
            likeButton.accessibilityIdentifier = "likeButton"
        }
    }

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()

    private var didSetupConstraints: Bool = false

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        cellImage.kf.cancelDownloadTask()
    }

    override func updateConstraints() {
        super.updateConstraints()

        if !didSetupConstraints {
            didSetupConstraints = true
            NSLayoutConstraint.activate(
                [
                    cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                    cellImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
                    cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                    cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

                    likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor),
                    likeButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
                    likeButton.heightAnchor.constraint(equalToConstant: 44),
                    likeButton.widthAnchor.constraint(equalTo: likeButton.heightAnchor, multiplier: 1),

                    imageDateLabel.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor, constant: 8),
                    imageDateLabel.trailingAnchor.constraint(lessThanOrEqualTo: cellImage.trailingAnchor, constant: -8),
                    imageDateLabel.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor, constant: -8),
                ]
            )
        }
    }
}

// MARK: верстка ячейки
private extension ImagesListCell {
    func createDateLabel() -> UILabel {
        let dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)
        return dateLabel
    }

    func createLikeButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button)
        button.addTarget(self, action: #selector(likeButtonDidTapped), for: .touchUpInside)
        return button
    }

    func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        return imageView
    }
}

// MARK: основная функциональность ячейки
extension ImagesListCell {
    @objc private func likeButtonDidTapped() {
        delegate?.imageListCellDidTapLike(self)
    }

    func setIsLiked(to isLike: Bool) {
        self.isLiked = isLike
    }

    func config(thumbImageURL: String, createdAt: Date?, isLiked: Bool) {
        backgroundColor = .ypBlack
        cellImage.backgroundColor = .ypWhite
        selectionStyle = .none

        // Настройка alpha-канала на время отображения плейсхолдера (по дизайн-макету)
        cellImage.alpha = 0.5

        let placeholder = ImagePlaceholderView()
        let thumbImageURL = thumbImageURL
        guard let url = URL(string: thumbImageURL) else {
            cellImage.addSubview(placeholder)
            return
        }

        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(with: url, placeholder: placeholder) {[weak self] _ in
            self?.cellImage.alpha = 1
        }

        imageDateLabel.text = createdAt == nil ? "" : dateFormatter.string(from: createdAt!)
        setIsLiked(to: isLiked)
        updateConstraintsIfNeeded()
    }
}
