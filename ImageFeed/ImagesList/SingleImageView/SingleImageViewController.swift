//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 15.05.2023.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    var imageURL: String! {
        didSet {
            if isViewLoaded {
                setAndRescaleImage()
            }
        }
    }
    private lazy var imageView: UIImageView = { setupImageView() }()
    private lazy var scrollView: UIScrollView = { setupScrollView() }()
    private lazy var backButton: UIButton = { setupBackButton() }()
    private lazy var shareButton: UIButton = { setupShareButton() }()

    override func loadView() {
        super.loadView()

        view.backgroundColor = .ypBlack
        view.addSubview(scrollView)
        view.addSubview(backButton)
        view.addSubview(shareButton)

        addConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setAndRescaleImage()
    }

    @objc private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true)
    }

    @objc private func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else {return}
        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil)
        present(activityViewController, animated: true)
    }
}

// MARK: - основная логика
extension SingleImageViewController {
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }

    private func setAndRescaleImage() {
        guard let url = URL(string: imageURL) else {
            print("Image url is not valid")
            return
        }

        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let resultImage):
                self?.rescaleAndCenterImageInScrollView(image: resultImage.image)
            case .failure:
                self?.showError()
            }
        }
    }

    private func showError() {
        let alertPresenter = AlertPresenter(controller: self)

        let alertTitle = "Что-то пошло не так."
        let alertMessage = "Попробовать ещё раз?"
        let retryActionTitle = "Повторить"
        let cancelActionTitle = "Не надо"
        let alert = AlertModel(title: alertTitle,
                               message: alertMessage,
                               cancelButtonText: cancelActionTitle,
                               approveButtonText: retryActionTitle)

        alertPresenter.showAlert(alert: alert) { [weak self] action in
            if action.title == retryActionTitle {
                self?.setAndRescaleImage()
            }
        }
    }
}

// MARK: - верстка
extension SingleImageViewController {
    private func setupImageView() -> UIImageView {
        let imageView = UIImageView()
        return imageView
    }

    private func setupScrollView() -> UIScrollView {
        let scrollView = UIScrollView()

        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 2.7
        scrollView.delegate = self

        scrollView.addSubview(imageView)

        return scrollView
    }

    private func setupBackButton() -> UIButton {
        let backButton = UIButton()

        backButton.setImage(UIImage(named: "chevron.backward"), for: .normal)
        backButton.tintColor = .ypWhite

        backButton.addTarget(self, action: #selector(didTapBackButton(_:)), for: .touchUpInside)

        return backButton
    }

    private func setupShareButton() -> UIButton {
        let shareButton = UIButton()

        shareButton.setImage(UIImage(named: "sharing_button"), for: .normal)
        shareButton.tintColor = .ypWhite

        shareButton.addTarget(self, action: #selector(didTapShareButton(_:)), for: .touchUpInside)

        return shareButton
    }

    private func addConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

                imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
                imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
                imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

                backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
                backButton.heightAnchor.constraint(equalToConstant: 44),
                backButton.widthAnchor.constraint(equalTo: backButton.widthAnchor),

                shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -38),
                shareButton.heightAnchor.constraint(equalToConstant: 50),
                shareButton.widthAnchor.constraint(equalTo: shareButton.heightAnchor),

            ]
        )
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
