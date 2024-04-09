//
//  ImagePickerViewModel.swift
//  ChangeBackground
//
//  Created by Kent Tu on 3/15/24.
//

import UIKit
import Vision
import CoreML
import Combine

class MainViewModel {
    @Published var selectedImage: UIImage?
    @Published var isImagePickerDisplayed: Bool = false
    @Published var foregroundImage: UIImage?
    
    
    var undoForegroundImageStack = MostRecentArray<UIImage>(maxSize: 10)
    var imageDidChange: ((UIImage?) -> Void)?
    var shareImage: ((UIImage?) -> Void)?

    private var imageProcessor: ImageProcessor
    private var cancellables: Set<AnyCancellable> = []

    init(imageProcessor: ImageProcessor = ImageProcessor()) {
        self.imageProcessor = imageProcessor
    }

    func subjectImageSelected(_ image: UIImage?) {
        foregroundImage = image
        
        if let cgImage = image?.cgImage {
            imageProcessor.getForegroundMaskedImage(cgImage: cgImage, completion: { [weak self] foregroundCGImage in
                guard let foregroundCGImage, let self  else {
                    return
                }
                let uiImage = UIImage(cgImage: foregroundCGImage)
                self.foregroundImage = uiImage
                foregroundImageDidChange(uiImage)
            })
        }
    }
    
    func foregroundImageDidChange(_ newImage: UIImage) {
        self.foregroundImage = newImage
        self.undoForegroundImageStack.add(newImage)
    }
    
    func undoForegroundImageEdit() {
        guard undoForegroundImageStack.count() > 1 else {
            return
        }
        self.undoForegroundImageStack.remove()
        self.foregroundImage = self.undoForegroundImageStack.last()
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
