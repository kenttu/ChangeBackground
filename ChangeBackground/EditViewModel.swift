//
//  EditModelView.swift
//  ChangeBackground
//
//  Created by Kent Tu on 4/12/24.
//

import UIKit
import Vision
import CoreML
import Combine

class EditViewModel {
    @Published var foregroundImage: UIImage?
    
    var undoForegroundImageStack = MostRecentArray<UIImage>(maxSize: 10)
    
    func foregroundImageDidChange(_ newImage: UIImage) {
        self.foregroundImage = newImage
        self.undoForegroundImageStack.add(newImage)
    }
    
    func undoForegroundImageEdit() {
        guard undoForegroundImageStack.count() > 1 else {
            return
        }
        _ = self.undoForegroundImageStack.removeLast()
        self.foregroundImage = self.undoForegroundImageStack.last()
    }
}
