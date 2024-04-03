//
//  CheckerboardView.swift
//  ChangeBackground
//
//  Created by Kent Tu on 3/19/24.
//
import UIKit

class MaskingView: UIView {
    var lastPoint: CGPoint = .zero
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var zoomScale: CGFloat = 1.0
    
    var didUpdate: (() -> Void)? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitTestView = super.hitTest(point, with: event)
        print("Hit Test View: \(String(describing: hitTestView))")
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
        if let didUpdate {
            didUpdate()
        }
    }

    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        UIGraphicsBeginImageContext(self.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("Error: UIGraphicsGetCurrentContext() failed")
            return
        }
        
        let backgroundColor = UIColor.darkGray
        
        self.layer.render(in: context)
        
        context.move(to: fromPoint)
        context.addLine(to: toPoint)
        context.setLineCap(.round)
        context.setLineWidth(brushWidth)
        context.setStrokeColor(backgroundColor.cgColor)
        //context.setBlendMode(.clear)
        context.strokePath()
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let newImage = newImage {
            self.layer.contents = newImage.cgImage
        } else {
            print("Error: Image drawing failed")
        }
    }

}
