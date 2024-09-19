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

    public static func generate(from string: String, color: UIColor = Asset.Colors.primary.systemColor) -> Future<CGImage, Never> {
        Future<CGImage, Never> { promise in
            DispatchQueue.global().async {
                guard let image = generateCode(from: string, color: color) else {
                    return
                }
                
                return promise(.success(image))
            }
        }
    }

    public static func generateCode(from string: String, scale: CGFloat = 15, color: UIColor = Asset.Colors.primary.systemColor) -> CGImage? {
        let data = string.data(using: String.Encoding.utf8)
        
        let context = CIContext()
        let filter = CoreImage.CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        
        if color == .black {
            guard let baseImage = filter.outputImage?.transformed(by: transform) else {
                return nil
            }

            return QRCodeGenerator.overlayWithZecLogo(baseImage, context: context)
        } else {
            guard let baseImage = filter.outputImage?.transformed(by: transform).tinted(using: color) else {
                return nil
            }

            return QRCodeGenerator.overlayWithZecLogo(baseImage, context: context, export: false)
        }
    }
    
    public static func overlayWithZecLogo(_ baseImage: CIImage, context: CIContext, export: Bool = true) -> CGImage? {
        guard let overlayImage = UIImage(named: export ? "QROverlay" : "QRDynamicOverlay") else {
            return nil
        }
        
        guard let iconCIImage = CIImage(image: overlayImage) else {
            return nil
        }
        
        let ratio = 0.25
        let size = baseImage.extent.width * ratio
        let halfSize = size * 0.5
        let iconRect = CGRect(x: baseImage.extent.width * 0.5 - halfSize, y: baseImage.extent.height * 0.5 - halfSize, width: size, height: size)
        let scaleTransform = CGAffineTransform(scaleX: iconRect.size.width / iconCIImage.extent.width, y: iconRect.size.height / iconCIImage.extent.height)
        let translationTransform = CGAffineTransform(translationX: iconRect.origin.x, y: iconRect.origin.y)
        let transformedIconCIImage = iconCIImage.transformed(by: scaleTransform.concatenating(translationTransform))
        let combinedImage = transformedIconCIImage.composited(over: baseImage)
                                               
        return context.createCGImage(combinedImage, from: combinedImage.extent)
    }
}

extension CIImage {
    var transparent: CIImage? {
        inverted?.blackTransparent
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
