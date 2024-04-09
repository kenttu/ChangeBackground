//
//  UIImageView+Helper.swift
//  EraseImage
//
//  Created by Kent Tu on 4/4/24.
//

import UIKit
extension UIImageView {

    func imageFrame() -> CGRect? {
        guard let imageSize = self.image?.size else {
            return nil
        }

        switch self.contentMode {
        case .scaleAspectFit:
            let viewSize = self.bounds.size
            let imageScale = min(viewSize.width / imageSize.width, viewSize.height / imageSize.height)
            let imageWidth = imageSize.width * imageScale
            let imageHeight = imageSize.height * imageScale
            let imageX = (viewSize.width - imageWidth) / 2.0
            let imageY = (viewSize.height - imageHeight) / 2.0
            return CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight)

        case .scaleAspectFill:
            let viewSize = self.bounds.size
            let imageRatio = imageSize.width / imageSize.height
            let viewRatio = viewSize.width / viewSize.height
            var width: CGFloat
            var height: CGFloat

            if imageRatio > viewRatio {
                height = viewSize.height
                width = height * imageRatio
            } else {
                width = viewSize.width
                height = width / imageRatio
            }

            let imageX = (viewSize.width - width) / 2.0
            let imageY = (viewSize.height - height) / 2.0
            return CGRect(x: imageX, y: imageY, width: width, height: height)

        default:
            return nil
        }
    }
}
