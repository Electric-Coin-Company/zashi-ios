//
//  QRCodeGenerator.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.07.2022.
//

import Foundation
import Combine
import CoreImage.CIFilterBuiltins
import SwiftUI

enum QRCodeGenerator {
    enum QRCodeError: Error {
        case failedToGenerate
    }
    
    static func generate(from string: String) -> Future<CGImage, QRCodeError> {
        Future<CGImage, QRCodeError> { promise in
            DispatchQueue.global().async {
                guard let image = generate(from: string) else {
                    promise(.failure(QRCodeGenerator.QRCodeError.failedToGenerate))
                    return
                }
                
                return promise(.success(image))
            }
        }
    }
    
    static func generate(from string: String, scale: CGFloat = 5) -> CGImage? {
        let data = string.data(using: String.Encoding.utf8)
        
        let context = CIContext()
        let filter = CoreImage.CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        
        guard let output = filter.outputImage?.transformed(by: transform) else {
            return nil
        }
        
        return context.createCGImage(output, from: output.extent)
    }
}
