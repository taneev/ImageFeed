//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 15.05.2023.
//

import UIKit

final class SingleImageViewController: UIViewController {

    var image: UIImage!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }

    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true)
    }

}
