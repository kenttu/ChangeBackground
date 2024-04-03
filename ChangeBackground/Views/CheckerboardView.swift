//
//  CheckerboardView.swift
//  ChangeBackground
//
//  Created by Kent Tu on 3/19/24.
//
import UIKit

class CheckerboardView: UIView {
    let boxSize: CGFloat = 15  // Size of each check

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isOpaque = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isOpaque = false
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setFillColor(UIColor(white: 0.9, alpha: 1.0).cgColor)
        context.fill(rect)

        let numRows = Int(ceil(rect.height / boxSize))
        let numCols = Int(ceil(rect.width / boxSize))

        for row in 0..<numRows {
            for col in 0..<numCols {
                if (row + col).isMultiple(of: 2) {
                    let boxRect = CGRect(x: CGFloat(col) * boxSize, y: CGFloat(row) * boxSize, width: boxSize, height: boxSize)
                    context.setFillColor(UIColor.white.cgColor)
                    context.fill(boxRect)
                }
            }
        }
    }
}
