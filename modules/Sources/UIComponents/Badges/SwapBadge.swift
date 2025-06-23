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
        case pending
        case refunded
        case success
        
        public var title: String {
            switch self {
            case .pending:
                return L10n.SwapAndPay.Status.pending
            case .refunded:
                return L10n.SwapAndPay.Status.refunded
            case .success:
                return L10n.SwapAndPay.Status.success
            }
        }
        
        public var fontStyle: Colorable {
            switch self {
            case .pending:
                return Design.Utility.HyperBlue._700
            case .refunded:
                return Design.Utility.WarningYellow._700
            case .success:
                return Design.Utility.SuccessGreen._700
            }
        }
        
        public var bcgStyle: Colorable {
            switch self {
            case .pending:
                return Design.Utility.HyperBlue._50
            case .refunded:
                return Design.Utility.WarningYellow._50
            case .success:
                return Design.Utility.SuccessGreen._50
            }
        }
        
        public var outlineStyle: Colorable {
            switch self {
            case .pending:
                return Design.Utility.HyperBlue._200
            case .refunded:
                return Design.Utility.WarningYellow._200
            case .success:
                return Design.Utility.SuccessGreen._200
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
