//
//  BackgroundCollectionCell.swift
//  ChangeBackground
//
//  Created by Kent Tu on 3/27/24.
//

import UIKit

class BackgroundCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = 10
    }
}
