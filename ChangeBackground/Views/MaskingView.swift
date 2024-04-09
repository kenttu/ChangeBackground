//
//  MaskingView.swift
//  ChangeBackground
//
//  Created by Kent Tu on 3/19/24.
//
import UIKit

class MaskingView: UIView {
    private var lastPoint: CGPoint = .zero
    private var brushWidth: CGFloat = 10.0
    private var opacity: CGFloat = 1.0
    private var zoomScale: CGFloat = 1.0
    private var imageStack: [CGImage] = []
    
    var didUpdate: ((_ newImage: UIImage) -> Void)? = nil

    weak var imageView: UIImageView?
    
    init(imageView: UIImageView) {
        self.imageView = imageView
        super.init(frame: imageView.imageFrame() ?? imageView.bounds)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitTestView = super.hitTest(point, with: event)
        return hitTestView
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastPoint = touch.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)

        // Convert touch point to zoomed-in scale
        let scaledLocation = CGPoint(x: location.x / zoomScale,
                                     y: location.y / zoomScale)

        // Continue with drawing operation using 'scaledLocation'
        drawLine(from: lastPoint, to: scaledLocation)
        lastPoint = scaledLocation
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newImage = self.applyMask() else {
            return
        }
        if let didUpdate {
            didUpdate(newImage)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        undoLastDraw()
    }

    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        UIGraphicsBeginImageContext(self.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("Error: UIGraphicsGetCurrentContext() failed")
            return
        }
        
        // Render the current layer into the context and push it to the stack before drawing
        if let currentLayerImage = self.layer.contents {
            imageStack.append(currentLayerImage as! CGImage)
        }
        
        let backgroundColor = UIColor.darkGray
        
        self.layer.render(in: context)
        
        context.move(to: fromPoint)
        context.addLine(to: toPoint)
        context.setLineCap(.round)
        context.setLineWidth(brushWidth)
        context.setStrokeColor(backgroundColor.cgColor)
        context.strokePath()
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let newImage = newImage {
            self.layer.contents = newImage.cgImage
        } else {
            print("Error: Image drawing failed")
        }
    }
    
    func undoLastDraw() {
        guard !imageStack.isEmpty else {
            print("No more undo steps available")
            self.layer.contents = nil
            return
        }

        let previousImage = imageStack.removeLast()
        self.layer.contents = previousImage
        self.layer.setNeedsDisplay()
    }
}

extension MaskingView {
    func applyMask() -> UIImage? {
        guard let imageView = imageView,
              let image = imageView.image,
              let cgImage = image.cgImage,
              let cgMask = applyMaskToImage()?.cgImage else {
            return nil
        }
                        
        let blendFilter = CIFilter(name: "CIBlendWithMask")
        blendFilter?.setValue(CIImage(cgImage: cgImage), forKey: kCIInputImageKey)
        blendFilter?.setValue(CIImage(cgImage: cgMask), forKey: kCIInputMaskImageKey)
            
        let ciContext = CIContext()
        guard let blend = blendFilter?.outputImage,
              let filteredCGImage = ciContext.createCGImage(blend, from: blend.extent) else {
            return nil
        }
        
        clearMaskView()
        return UIImage(cgImage: filteredCGImage)
    }
    
    func applyMaskToImage() -> UIImage? {
        guard let imageView, let image = imageView.image else {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        self.layer.render(in: context)
        
        let clearedMaskedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let clearedMaskedImage, let maskedImage = clearedMaskedImage.replacingTransparentPixels(withColor: .white) else {
            return nil
        }
        
        return maskedImage.scaled(toSize: image.size)
    }

    func clearMaskView() {
        self.layer.contents = nil
    }
}
