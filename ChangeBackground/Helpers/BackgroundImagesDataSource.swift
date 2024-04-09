//
//  BackgroundDatasource.swift
//  ChangeBackground
//
//  Created by Kent Tu on 4/6/24.
//

import UIKit

class BackgroundImagesDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let backgroundImages = ["background-1", "background-2", "background-3", "background-4", "background-5", "background-5", "background-6"]
    private var backgroundImageView: UIImageView

    init(imageView: UIImageView) {
        self.backgroundImageView = imageView
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return backgroundImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BackgroundCollectionViewCell", for: indexPath) as! BackgroundCollectionViewCell
        let imageName = backgroundImages[indexPath.item]
        cell.imageView.image = UIImage(named: imageName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageName = backgroundImages[indexPath.item]
        backgroundImageView.image = UIImage(named: imageName)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
}

