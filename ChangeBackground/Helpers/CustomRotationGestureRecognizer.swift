//
//  CustomRotationGestureRecognizer.swift
//  ChangeBackground
//
//  Created by Kent Tu on 4/13/24.
//

import UIKit

class CustomRotationGestureRecognizer: UIPanGestureRecognizer {
    private var initialAngle: CGFloat = 0
    private var currentRotation: CGFloat = 0

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        self.minimumNumberOfTouches = 3
        self.maximumNumberOfTouches = 3
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        initialAngle = calculateAngle(from: touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        let newAngle = calculateAngle(from: touches)
        currentRotation = newAngle - initialAngle
        self.state = .changed
    }

    private func calculateAngle(from touches: Set<UITouch>) -> CGFloat {
        guard touches.count == 3, let view = view else { return 0 }
        let touchArray = Array(touches)
        let center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        let touchPoint = touchArray[0].location(in: view)
        let dx = touchPoint.x - center.x
        let dy = touchPoint.y - center.y
        return atan2(dy, dx)
    }

    func rotation() -> CGFloat {
        return currentRotation
    }
}
