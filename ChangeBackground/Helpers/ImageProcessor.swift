//
//  ImageProcessor.swift
//  ChangeBackground
//
//  Created by Kent Tu on 4/5/24.
//
import UIKit
import Vision
import CoreML

class ImageProcessor {
    func getForegroundMaskedImage(cgImage: CGImage, completion: @escaping (CGImage?) -> Void) {
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let segmentationRequest = VNGenerateForegroundInstanceMaskRequest()

        do {
            try requestHandler.perform([segmentationRequest])
        } catch {
            print(error)
            completion(nil)
            return
        }

        guard let result = segmentationRequest.results?.first else {
            print("result is empty", segmentationRequest.results ?? "nil")
            completion(nil)
            return
        }
        
        var pixelBuffer: CVPixelBuffer
        do {
            try pixelBuffer = result.generateMaskedImage(ofInstances: result.allInstances, from: requestHandler, croppedToInstancesExtent: true)
        }
        catch {
            print("generateMaskedImage failed")
            completion(nil)
            return
        }

        let ciContext = CIContext()
        let mask = CIImage(cvPixelBuffer: pixelBuffer)
        guard let maskCGImage = ciContext.createCGImage(mask, from: mask.extent) else {
            print("maskCGImage failed")
            completion(nil)
            return
        }
        completion(maskCGImage)
    }
}
