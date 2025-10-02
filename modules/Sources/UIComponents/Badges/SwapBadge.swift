//
//  SwapBadge.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-06-22.
//

import SwiftUI

import Generated

public struct SwapBadge: View {
    @Environment(\.colorScheme) private var colorScheme
    
    public enum Status {
        case failed
        case pending
        case pendingDeposit
        case processing
        case refunded
        case success
        case expired
        
        public var title: String {
            switch self {
            case .pending: return L10n.SwapAndPay.Status.pending
            case .processing: return L10n.SwapAndPay.Status.processing
            case .refunded: return L10n.SwapAndPay.Status.refunded
            case .success: return L10n.SwapAndPay.Status.success
            case .failed: return L10n.SwapAndPay.Status.failed
            case .pendingDeposit: return L10n.SwapAndPay.Status.pendingDeposit
            case .expired: return L10n.SwapAndPay.Status.expired
            }
        }
        
        public var fontStyle: Colorable {
            switch self {
            case .pending: return Design.Utility.HyperBlue._700
            case .processing: return Design.Utility.HyperBlue._700
            case .refunded: return Design.Utility.ErrorRed._700
            case .success: return Design.Utility.SuccessGreen._700
            case .failed: return Design.Utility.ErrorRed._700
            case .pendingDeposit: return Design.Utility.WarningYellow._700
            case .expired: return Design.Utility.ErrorRed._700
            }
        }
        
        public var bcgStyle: Colorable {
            switch self {
            case .pending: return Design.Utility.HyperBlue._50
            case .processing: return Design.Utility.HyperBlue._50
            case .refunded: return Design.Utility.ErrorRed._50
            case .success: return Design.Utility.SuccessGreen._50
            case .failed: return Design.Utility.ErrorRed._50
            case .pendingDeposit: return Design.Utility.WarningYellow._50
            case .expired: return Design.Utility.ErrorRed._50
            }
        }
        
        public var outlineStyle: Colorable {
            switch self {
            case .pending: return Design.Utility.HyperBlue._200
            case .processing: return Design.Utility.HyperBlue._200
            case .refunded: return Design.Utility.ErrorRed._200
            case .success: return Design.Utility.SuccessGreen._200
            case .failed: return Design.Utility.ErrorRed._200
            case .pendingDeposit: return Design.Utility.WarningYellow._200
            case .expired: return Design.Utility.ErrorRed._200
            }
        }
    }
    
    let status: Status
    
    public init(_ privacy: Status) {
        self.status = privacy
    }
    
    public var body: some View {
        Text(status.title)
            .zFont(.medium, size: 14, style: status.fontStyle)
            .padding(.vertical, 2)
            .padding(.horizontal, 10)
            .background {
                RoundedRectangle(cornerRadius: Design.Radius._2xl)
                    .fill(status.bcgStyle.color(colorScheme))
                    .background {
                        RoundedRectangle(cornerRadius: Design.Radius._2xl)
                            .stroke(status.outlineStyle.color(colorScheme))
                    }
            }
    }
}

#Preview {
    VStack(spacing: 40) {
        SwapBadge(.success)
        SwapBadge(.pending)
        SwapBadge(.refunded)
    }
}
