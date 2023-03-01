//
//  SupportDataGenerator.swift
//  secant
//
//  Created by Michal Fousek on 28.02.2023.
//

import AVFoundation
import Foundation
import LocalAuthentication
import UIKit

struct SupportData: Equatable {
    let toAddress: String
    let subject: String
    let message: String
}

enum SupportDataGenerator {
    static func generate() -> SupportData {
        let items: [SupportDataGeneratorItem] = [
            TimeItem(),
            AppVersionItem(),
            SystemVersionItem(),
            DeviceModelItem(),
            LocaleItem(),
            FreeDiskSpaceItem(),
            PermissionsItems()
        ]

        let message = items
            .map { $0.generate() }
            .flatMap { $0 }
            .map { "\($0.0): \($0.1)" }
            .joined(separator: "\n")

        return SupportData(toAddress: "support@electriccoin.co", subject: "sECCant", message: message)
    }
}

private protocol SupportDataGeneratorItem {
    func generate() -> [(String, String)]
}

private struct TimeItem: SupportDataGeneratorItem {
    private enum Constants {
        static let timeKey = "Current time"
    }

    let dateFormatter: DateFormatter

    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss a ZZZZ"
        dateFormatter.locale = Locale(identifier: "en_US")
    }

    func generate() -> [(String, String)] {
        return [(Constants.timeKey, dateFormatter.string(from: Date()))]
    }
}

private struct AppVersionItem: SupportDataGeneratorItem {
    private enum Constants {
        static let bundleIdentifierKey = "App identifier"
        static let versionKey = "App version"
        static let unknownVersion = "Unknown"
    }

    func generate() -> [(String, String)] {
        let bundle = Bundle.main
        guard let infoDict = bundle.infoDictionary else { return [(Constants.versionKey, Constants.unknownVersion)] }

        var data: [(String, String)] = []
        if let bundleIdentifier = bundle.bundleIdentifier {
            data.append((Constants.bundleIdentifierKey, bundleIdentifier))
        }

        if let build = infoDict["CFBundleVersion"] as? String, let version = infoDict["CFBundleShortVersionString"] as? String {
            data.append((Constants.versionKey, "\(version) (\(build))"))
        } else {
            data.append((Constants.versionKey, Constants.unknownVersion))
        }

        return data
    }
}

private struct SystemVersionItem: SupportDataGeneratorItem {
    private enum Constants {
        static let systemVersionKey = "iOS version"
    }

    func generate() -> [(String, String)] {
        return [(Constants.systemVersionKey, UIDevice.current.systemVersion)]
    }
}

private struct DeviceModelItem: SupportDataGeneratorItem {
    private enum Constants {
        static let deviceModelKey = "Device"
        static let unknownDevice = "unknown"
    }

    func generate() -> [(String, String)] {
        var systemInfo = utsname()
        uname(&systemInfo)
        var readModel: String?
        withUnsafePointer(to: &systemInfo.machine.0) { charPointer in
            readModel = String(cString: charPointer, encoding: .ascii)
        }

        let model = readModel ?? Constants.unknownDevice
        return [(Constants.deviceModelKey, model)]
    }
}

private struct LocaleItem: SupportDataGeneratorItem {
    private enum Constants {
        static let localKey = "Locale"
        static let groupingSeparatorKey = "Currency grouping separato"
        static let decimalSeparatorKey = "Currency decimal separator"
        static let unknownSeparator = "unknown"
    }

    func generate() -> [(String, String)] {
        let locale = Locale.current

        return [
            (Constants.localKey, locale.identifier),
            (Constants.groupingSeparatorKey, locale.groupingSeparator ?? Constants.unknownSeparator),
            (Constants.decimalSeparatorKey, locale.decimalSeparator ?? Constants.unknownSeparator)
        ]
    }
}

private struct FreeDiskSpaceItem: SupportDataGeneratorItem {
    private enum Constants {
        static let freeDiskSpaceKey = "Usable storage"
        static let freeDiskSpaceUnknown = "unknown"
    }

    func generate() -> [(String, String)] {
        let freeDiskSpace: String

        let fileURL = URL(fileURLWithPath: NSHomeDirectory())
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            if let freeSpace = values.volumeAvailableCapacityForImportantUsage {
                freeDiskSpace = "\(freeSpace / 1024 / 1024) MB"
            } else {
                freeDiskSpace = Constants.freeDiskSpaceUnknown
            }
        } catch {
            LoggerProxy.debug("Can't get free disk space: \(error)")
            freeDiskSpace = Constants.freeDiskSpaceUnknown
        }

        return [(Constants.freeDiskSpaceKey, freeDiskSpace)]
    }
}

private struct PermissionsItems: SupportDataGeneratorItem {
    private enum Constants {
        static let permissionsKey = "Permissions"
        static let cameraPermKey = "Camera access"
        static let faceIDAvailable = "FaceID available"
        static let touchIDAvailable = "TouchID available"
        static let yesText = "yes"
        static let noText = "no"
    }

    func generate() -> [(String, String)] {
        let cameraAuthorized = AVCaptureDevice.authorizationStatus(for: .video) == .authorized

        let bioAuthContext = LAContext()
        let biometricAuthAvailable = bioAuthContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)

        return [
            (Constants.permissionsKey, ""),
            (Constants.cameraPermKey, cameraAuthorized ? Constants.yesText : Constants.noText),
            (Constants.faceIDAvailable, biometricAuthAvailable && bioAuthContext.biometryType == .faceID ? Constants.yesText : Constants.noText),
            (Constants.touchIDAvailable, biometricAuthAvailable && bioAuthContext.biometryType == .touchID ? Constants.yesText : Constants.noText)
        ]
    }
}
