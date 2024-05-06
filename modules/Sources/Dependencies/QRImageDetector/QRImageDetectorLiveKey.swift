//
//  QRImageDetectorLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 2024-04-18.
//

import ComposableArchitecture
import CoreImage

extension QRImageDetectorClient: DependencyKey {
    public static let liveValue = Self(
        check: { image in
            guard let image else { return nil }
            guard let ciImage = CIImage(image: image) else { return nil }
            
            let detectorOptions = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: CIContext(), options: detectorOptions)
            let decoderOptions = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
            let features = qrDetector?.features(in: ciImage, options: decoderOptions)
            
            return features?.compactMap {
                ($0 as? CIQRCodeFeature)?.messageString
            }
        }
    )
}
