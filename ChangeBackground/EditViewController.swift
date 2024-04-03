//
//  EditViewController.swift
//  EraseImage
//
//  Created by Kent Tu on 3/19/24.
//

import UIKit

class EditViewController: UIViewController {

    @IBOutlet var containerView: UIView!
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var maskView: MaskingView!
    var isErasing = true // Determine if the user is erasing or drawing.

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViews()
    }
    
    func setupViews() {
        guard let image = UIImage(named: "unsplash") else { return }
        
        imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true

        containerView.addSubview(imageView)
        imageView.frame = containerView.bounds
//        imageView.sizeToFit()

        scrollView = UIScrollView(frame: containerView.bounds)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 6.0
        scrollView.isScrollEnabled = true
        scrollView.decelerationRate = .fast
        scrollView.contentSize = imageView.frame.size
        containerView.addSubview(scrollView)

        scrollView.addSubview(imageView)

        maskView = MaskingView(frame: imageView.bounds)
        maskView.backgroundColor = .clear
        maskView.isUserInteractionEnabled = true
        maskView.didUpdate = { [weak self] in
            self?.applyMask()
        }

        imageView.addSubview(maskView)

        self.containerView.backgroundColor = .gray
        self.scrollView.backgroundColor = .green
        
        // Force the layout of containerView to update immediately
        containerView.layoutIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        // Setting initial zoom scale
        let scaleX = scrollView.bounds.size.width / imageView.bounds.size.width
        let scaleY = scrollView.bounds.size.height / imageView.bounds.size.height
        let minScale = min(scaleX, scaleY)
        scrollView.zoomScale = minScale  // Set to minimum scale to show the whole image

    }

    func toggleEraseMode(isErasing: Bool) {
        self.isErasing = isErasing
        // You might change the cursor or brush appearance here
    }
    
    func applyMask() {
        if let image = self.imageView.image, let cgImage = image.cgImage, let cgMask = applyMaskToImage()?.cgImage {
                        
            let blendFilter = CIFilter(name: "CIBlendWithMask")
            blendFilter?.setValue(CIImage(cgImage: cgImage), forKey: kCIInputImageKey)
            blendFilter?.setValue(CIImage(cgImage: cgMask), forKey: kCIInputMaskImageKey)
            
            let ciContext = CIContext()
            guard let blend = blendFilter?.outputImage,
                  let filteredCGImage = ciContext.createCGImage(blend, from: blend.extent)
            else { return }

            self.imageView.image = UIImage(cgImage: filteredCGImage)

        }
        self.clearMaskView()
    }
    
    @IBAction func editSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            isErasing = true
            scrollView.isScrollEnabled = false
            maskView.isUserInteractionEnabled = true
        } else {
            isErasing = false
            scrollView.isScrollEnabled = true
            maskView.isUserInteractionEnabled = false
        }
    }

    
    func applyMaskToImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // imageView.layer.render(in: context)
        maskView.layer.render(in: context)
        
        let clearedMaskedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let clearedMaskedImage, let maskedImage = replaceTransparentWithWhite(in: clearedMaskedImage) else {
            return nil
        }
        
        if let size = imageView.image?.size {
            return scaleMask(mask: maskedImage, toSize: size)
        }
        else {
            return maskedImage
        }
    }
    
    func scaleMask(mask: UIImage, toSize size: CGSize) -> UIImage? {
        // Begin a new image context
        guard let cgImage = self.imageView.image?.cgImage, let maskCGImage = mask.cgImage else {
            return nil
        }
        let original = CIImage(cgImage: cgImage)
        let ciContext = CIContext()

        var scaledMask = CIImage(cgImage: maskCGImage)
        let scaleX = original.extent.width / scaledMask.extent.width
        let scaleY = original.extent.height / scaledMask.extent.height
        scaledMask = scaledMask.transformed(by: .init(scaleX: scaleX, y: scaleY))
        guard let scaledMaskCGImage = ciContext.createCGImage(scaledMask, from: scaledMask.extent) else {
            print("maskCGImage failed")
            return nil
        }
        return UIImage(cgImage: scaledMaskCGImage)
    }

    func replaceTransparentWithWhite(in image: UIImage) -> UIImage? {
        // Start a new image context
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        UIColor.white.setFill() // Set the background to white
        UIRectFill(CGRect(origin: .zero, size: image.size)) // Fill the background with white
        
        image.draw(at: .zero) // Draw the original image over the white background
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() // Capture the modified image
        UIGraphicsEndImageContext()
        
        return newImage
    }

    func clearMaskView() {
        maskView.layer.contents = nil
    }


}

extension EditViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let subView = scrollView.subviews[0] // The imageView
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)
        subView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,
                                 y: scrollView.contentSize.height * 0.5 + offsetY)
       // maskView.zoomScale = scrollView.zoomScale
    }
}

