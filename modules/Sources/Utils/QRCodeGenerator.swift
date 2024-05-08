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
import Generated

public enum QRCodeGenerator {
    public enum QRCodeError: Error {
        case failedToGenerate
    }
    
    public static func generate(from string: String) -> Future<CGImage, QRCodeError> {
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
    
    public static func generate(from string: String, scale: CGFloat = 15, color: UIColor = Asset.Colors.primary.systemColor) -> CGImage? {
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

extension CIImage {
    var transparent: CIImage? {
        return inverted?.blackTransparent
    }

    var inverted: CIImage? {
        guard let invertedColorFilter = CIFilter(name: "CIColorInvert") else { return nil }

        invertedColorFilter.setValue(self, forKey: "inputImage")
        return invertedColorFilter.outputImage
    }

    var blackTransparent: CIImage? {
        guard let blackTransparentFilter = CIFilter(name: "CIMaskToAlpha") else { return nil }
        blackTransparentFilter.setValue(self, forKey: "inputImage")
        return blackTransparentFilter.outputImage
    }

    func tinted(using color: UIColor) -> CIImage?
    {
        guard
            let transparentQRImage = transparent,
            let filter = CIFilter(name: "CIMultiplyCompositing"),
            let colorFilter = CIFilter(name: "CIConstantColorGenerator") else { return nil }

        let ciColor = CIColor(color: color)
        colorFilter.setValue(ciColor, forKey: kCIInputColorKey)
        let colorImage = colorFilter.outputImage

        filter.setValue(colorImage, forKey: kCIInputImageKey)
        filter.setValue(transparentQRImage, forKey: kCIInputBackgroundImageKey)

        return filter.outputImage!
    }
}
