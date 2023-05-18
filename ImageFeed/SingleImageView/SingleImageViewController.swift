//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 15.05.2023.
//

import UIKit

final class SingleImageViewController: UIViewController {

    var image: UIImage!{
        didSet {
            if isViewLoaded {
                rescaleAndCenterImageInScrollView()
            }
        }
    }
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        rescaleAndCenterImageInScrollView()
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }

    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true)
    }

    private func rescaleAndCenterImageInScrollView() {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
