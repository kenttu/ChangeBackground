//
//  UIImage+Utility.swift
//  EraseImage
//
//  Created by Kent Tu on 4/5/24.
//

import UIKit

extension UIImage {
    func scaled(toSize size: CGSize) -> UIImage? {
        guard let maskCGImage = self.cgImage else {
            return nil
        }
        var scaledMask = CIImage(cgImage: maskCGImage)
        let scaleX = size.width / scaledMask.extent.width
        let scaleY = size.height / scaledMask.extent.height

        scaledMask = scaledMask.transformed(by: .init(scaleX: scaleX, y: scaleY))
        let ciContext = CIContext()
        guard let scaledMaskCGImage = ciContext.createCGImage(scaledMask, from: scaledMask.extent) else {
            print("maskCGImage failed")
            return nil
        }
        return UIImage(cgImage: scaledMaskCGImage)
    }

    func replacingTransparentPixels(withColor color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: self.size))
        
        // Draw the original image over the white background
        self.draw(at: .zero)
        
        // Capture the modified image
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /**
      Resizes the image.

      - Parameter scale: If this is 1, `newSize` is the size in pixels.
    */
    @nonobjc public func resized(to newSize: CGSize, scale: CGFloat = 1) -> UIImage {
      let format = UIGraphicsImageRendererFormat.default()
      format.scale = scale
      let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
      let image = renderer.image { _ in
        draw(in: CGRect(origin: .zero, size: newSize))
      }
      return image
    }
    
    /**
      Rotates the image around its center.

      - Parameter degrees: Rotation angle in degrees.
      - Parameter keepSize: If true, the new image has the size of the original
        image, so portions may be cropped off. If false, the new image expands
        to fit all the pixels.
    */

    func rotated(by degrees: CGFloat, flipped: Bool = false) -> UIImage? {
        let radians = degrees * .pi / 180
        var newSize = CGRect(origin: .zero, size: self.size).applying(CGAffineTransform(rotationAngle: radians)).size
        // Trim off the extremely small float value to avoid core graphics rounding errors
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: radians)
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        if flipped {
            // Flip or mirror the image
            let flippedImage = UIGraphicsGetImageFromCurrentImageContext()?.withHorizontallyFlippedOrientation()
            UIGraphicsEndImageContext()
            return flippedImage
        }

        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return rotatedImage
    }
}
