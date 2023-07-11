//
//  ImagePlaceholderView.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 07.07.2023.
//

import UIKit
import Kingfisher

final class ImagePlaceholderView: UIView, Placeholder {

    private let placeholderImageName = "Stub"
    private lazy var imageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .ypPlaceholderBack
        imageView.contentMode = .center
        imageView.image = UIImage(named: placeholderImageName)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
    }
}

private extension ImagePlaceholderView {
    func setupView() {
        backgroundColor = .ypBlack
        layer.cornerRadius = 16
        layer.masksToBounds = true
        addSubview(imageView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
}
