//
//  CVPixelBuffer+Utility.swift
//  ChangeBackground
//
//  Created by Kent Tu on 3/16/24.
//

import Foundation
import Accelerate

public extension CVPixelBuffer {
    func isEmpty() -> Bool {
        CVPixelBufferLockBaseAddress(self, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(self, .readOnly) }
    
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        let baseAddress = CVPixelBufferGetBaseAddress(self)
        
        let byteBuffer = baseAddress?.assumingMemoryBound(to: UInt8.self)
        
        var isEmpty = true
        for x in 0..<width {
            for y in 0..<height {
                let pixel = byteBuffer![y * width + x]
                if pixel != 0 {
                    isEmpty = false
                    break
                }
            }
            if !isEmpty {
                break
            }
        }
        
        return isEmpty
    }
}
