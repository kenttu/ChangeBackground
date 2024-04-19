//
//  ImageFilterProcessor.swift
//  ChangeBackground
//
//  Created by Kent Tu on 4/16/24.
//

import UIKit
import CoreImage

class ImageFilterProcessor {
    private var context: CIContext

    init() {
        self.context = CIContext()
    }

    // Function to apply Gaussian Blur
    func applyGaussianBlur(to inputImage: UIImage, withRadius radius: Double) -> UIImage? {
        guard let ciImage = CIImage(image: inputImage) else { return nil }
        
        let blurFilter = CIFilter(name: "CIGaussianBlur")!
        blurFilter.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter.setValue(radius, forKey: kCIInputRadiusKey)
        
        guard let outputCIImage = blurFilter.outputImage,
              let outputCGImage = context.createCGImage(outputCIImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: outputCGImage)
    }

}

