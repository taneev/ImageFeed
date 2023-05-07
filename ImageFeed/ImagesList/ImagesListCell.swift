//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 01.05.2023.
//

import UIKit

class ImagesListCell: UITableViewCell {

    static let reuseIdentifier = "ImagesListCell"

    @IBOutlet weak var imageDateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
