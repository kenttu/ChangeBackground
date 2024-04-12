//
//  DZImageView.swift
//  ChangeBackground
//
//  Created by Kent Tu on 3/15/24.
//

import UIKit

@IBDesignable
class DraggableZoomableImageView: UIImageView {
    private var currentScale: CGFloat = 1.0
    private var lastScale: CGFloat = 1.0
    private var originalCenter: CGPoint = CGPoint()
    private let minScale: CGFloat = 0.5  // Minimum scale limit

    // Erase more
    private var lastPoint: CGPoint = .zero
    private var brushWidth: CGFloat = 10.0
    private var opacity: CGFloat = 1.0
    private var isErasing = false
    private var maskView2: UIView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    
    private func commonInit() {
        self.isUserInteractionEnabled = true
        self.contentMode = .scaleAspectFill
        self.backgroundColor = .clear

        addGestureRecognizers()
        
        self.isErasing = true
        maskView2.frame  = self.frame
        maskView2.backgroundColor = .clear
        self.addSubview(maskView2)

    }

    private func addGestureRecognizers() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        // Configure the gesture recognizer to detect only two-finger pan gestures
        panGesture.minimumNumberOfTouches = 2
        panGesture.maximumNumberOfTouches = 2
        panGesture.delegate = self

        self.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        pinchGesture.delegate = self
        self.addGestureRecognizer(pinchGesture)
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)

        if gesture.state == .began {
            originalCenter = self.center
        }

        if gesture.state == .changed {
            let newCenter = CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y + translation.y)
            self.center = newCenter
        }
    }

    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .began {
            lastScale = currentScale
        } else if gesture.state == .changed, gesture.scale != 0 {
            var newScale = lastScale * gesture.scale
            newScale = max(newScale, minScale)
            self.transform = CGAffineTransform(scaleX: newScale, y: newScale)
            currentScale = newScale
        }
    }
    
}

extension DraggableZoomableImageView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true  
    }
}

extension DraggableZoomableImageView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastPoint = touch.location(in: maskView2)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentPoint = touch.location(in: maskView2)
        drawLine(from: lastPoint, to: currentPoint)
        
        lastPoint = currentPoint
    }

    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        UIGraphicsBeginImageContext(maskView2.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        maskView2.layer.render(in: context)
        
        context.move(to: fromPoint)
        context.addLine(to: toPoint)
        
        context.setLineCap(.round)
        context.setLineWidth(brushWidth)
        context.setStrokeColor(isErasing ? UIColor.clear.cgColor : UIColor.black.cgColor)
        context.setBlendMode(isErasing ? .clear : .normal)
        
        context.strokePath()
        
        maskView2.layer.contents = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }

}
