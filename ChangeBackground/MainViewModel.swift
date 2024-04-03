//
//  ImagePickerViewModel.swift
//  ChangeBackground
//
//  Created by Kent Tu on 3/15/24.
//

import UIKit
import Vision
import CoreML

class MainViewModel {
    @Published var selectedImage: UIImage?
    @Published var isImagePickerDisplayed: Bool = false
    @Published var foregroundImage: UIImage?

    var imageDidChange: ((UIImage?) -> Void)?
    var shareImage: ((UIImage?) -> Void)?

    func subjectImageSelected(_ image: UIImage?) {
        foregroundImage = image
        
        if let cgImage = image?.cgImage, let filteredImage =  getForegroundMaskedImage(cgImage: cgImage) {
                foregroundImage = UIImage(cgImage: filteredImage)
                return
        }
    }

    func getForegroundMaskedImage(cgImage: CGImage) -> (CGImage?) {
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let segmentationRequest = VNGenerateForegroundInstanceMaskRequest()

        do {
            try requestHandler.perform([segmentationRequest])
        } catch {
            print(error)
            return nil
        }

        guard let result = segmentationRequest.results?.first else {
            print("result is empty", segmentationRequest.results ?? "nil")
            return nil
        }
        
        var pixelBuffer: CVPixelBuffer
        do {
            try pixelBuffer = result.generateMaskedImage(ofInstances: result.allInstances, from: requestHandler, croppedToInstancesExtent: true)
        }
        catch {
            print("generateMaskedImage failed")
            return nil
        }

        let ciContext = CIContext()
        let mask = CIImage(cvPixelBuffer: pixelBuffer)
        guard let maskCGImage = ciContext.createCGImage(mask, from: mask.extent) else {
            print("maskCGImage failed")
            return nil
        }
        return maskCGImage
    }
}


extension MainViewModel {
    func handleShareButtonTapped(_ parentView: UIView) {
        if let shareImage, let imageToShare = createCompositeImage(from: parentView) {
            shareImage(imageToShare)
        }
    }
    func createCompositeImage(from commonSuperview: UIView) -> UIImage? {
        guard self.containsImageViews(in: commonSuperview) else {
            print("Image views must be in the same view hierarchy")
            return nil
        }

        let renderer = UIGraphicsImageRenderer(bounds: commonSuperview.bounds)
        let compositeImage = renderer.image { context in
            for subview in commonSuperview.subviews {
                if let imageView = subview as? UIImageView {
                    context.cgContext.saveGState()
                    context.cgContext.translateBy(x: imageView.frame.origin.x, y: imageView.frame.origin.y)
                    context.cgContext.concatenate(imageView.transform)
                    imageView.layer.render(in: context.cgContext)
                    context.cgContext.restoreGState()
                }
            }
        }
        return compositeImage
    }
    
    func containsImageViews(in view: UIView) -> Bool {
        for subview in view.subviews {
            if subview is UIImageView {
                return true
            }
        }
        return false
    }
}
