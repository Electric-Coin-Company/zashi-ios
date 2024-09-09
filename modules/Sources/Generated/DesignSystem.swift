//
//  DesignSystem.swift
//  Zashi
//
//  Created by Lukáš Korba on 28.08.2024.
//

import Foundation
import SwiftUI

public protocol Colorable {
    var color: Color { get }
}

public enum Design {

    // MARK: Color Variables
    
    public enum Surfaces: Colorable {
        case bgPrimary
        case bgAdjust
        case bgSecondary
        case bgTertiary
        case bgQuaternary
        case strokePrimary
        case strokeSecondary
        case bgAlt
        case bgHide
        case brandBg
        case brandFg
        case divider
    }
    
    public enum Text: Colorable {
        case primary
        case secondary
        case tertiary
        case quaternary
        case support
        case disabled
        case error
        case link
        case light
        case lightSupport
    }

    public enum Btns {
        public enum Primary: Colorable {
            case bg
            case bgHover
            case fg
            case bgDisabled
            case fgDisabled
        }

        public enum Secondary: Colorable {
            case bg
            case bgHover
            case fg
            case fgHover
            case border
            case borderHover
            case bgDisabled
            case fgDisabled
        }

        public enum Tertiary: Colorable {
            case bg
            case bgHover
            case fg
            case fgHover
            case bgDisabled
            case fgDisabled
        }

        public enum Quaternary: Colorable {
            case bg
            case bgHover
            case fg
            case fgHover
            case bgDisabled
            case fgDisabled
        }

        public enum Destructive1: Colorable {
            case bg
            case bgHover
            case fg
            case fgHover
            case border
            case borderHover
            case bgDisabled
            case fgDisabled
        }
        
        public enum Destructive2: Colorable {
            case bg
            case bgHover
            case fg
            case bgDisabled
            case fgDisabled
        }

        public enum Brand: Colorable {
            case bg
            case bgHover
            case fg
            case fgHover
            case bgDisabled
            case fgDisabled
        }

        public enum Ghost: Colorable {
            case bg
            case bgHover
            case fg
            case bgDisabled
            case fgDisabled
        }
    }

    public enum Inputs {
        public enum Default: Colorable {
            case bg
            case bgAlt
            case label
            case text
            case hint
            case required
            case icon
            case stroke
        }
        
        public enum Filled: Colorable {
            case bg
            case bgAlt
            case asideBg
            case stroke
            case label
            case text
            case hint
            case icon
            case iconMain
            case required
        }

        public enum ErrorFilled: Colorable {
            case bg
            case bgAlt
            case label
            case text
            case textAside
            case hint
            case icon
            case iconMain
            case stroke
            case strokeAlt
            case dropdown
        }
    }

    public enum Avatars: Colorable {
        case profileBorder
        case bg
        case bgSecondary
        case status
        case textFg
        case badgeBg
        case badgeFg
    }
    
    public enum Checkboxes: Colorable {
        case offBg
        case offStroke
        case offHoverBg
        case offHoverStroke
        case offDisabledBg
        case offDisabledStroke
        case onBg
        case onFg
        case onHoverBg
        case onDisabledBg
        case onDisabledStroke
        case onDisabledFb
    }
    
    public enum HintTooltips: Colorable {
        case surfacePrimary
        case defaultBg
        case defaultFg
        case hoverBg
        case hoverFg
        case focusedBg
        case focusedStroke
        case disabledBg
        case disabledFg
    }
    
    public enum Utility {
        public enum Gray: Colorable {
            case _50
            case _100
            case _200
            case _300
            case _400
            case _500
            case _600
            case _700
            case _800
            case _900
        }

        public enum SuccessGreen: Colorable {
            case _50
            case _100
            case _200
            case _300
            case _400
            case _500
            case _600
            case _700
            case _800
            case _900
        }

        public enum ErrorRed: Colorable {
            case _50
            case _100
            case _200
            case _300
            case _400
            case _500
            case _600
            case _700
            case _800
            case _900
        }

        public enum WarningYellow: Colorable {
            case _50
            case _100
            case _200
            case _300
            case _400
            case _500
            case _600
            case _700
            case _800
            case _900
        }

        public enum HyperBlue: Colorable {
            case _50
            case _100
            case _200
            case _300
            case _400
            case _500
            case _600
            case _700
            case _800
            case _900
        }

        public enum Indigo: Colorable {
            case _50
            case _100
            case _200
            case _300
            case _400
            case _500
            case _600
            case _700
            case _800
            case _900
        }

        public enum Purple: Colorable {
            case _50
            case _100
            case _200
            case _300
            case _400
            case _500
            case _600
            case _700
            case _800
            case _900
        }
    }
}

// MARK: Color Variable Values

public extension Design.Surfaces {
    var color: Color {
        switch self {
        case .bgPrimary: return Design.col(Asset.Colors.ZDesign.Base.bone.color, Asset.Colors.ZDesign.Base.obsidian.color)
        case .bgAdjust: return Design.col(Asset.Colors.ZDesign.Base.bone.color, Asset.Colors.ZDesign.shark900.color)
        case .bgSecondary: return Design.col(Asset.Colors.ZDesign.Base.concrete.color, Asset.Colors.ZDesign.sharkShades06dp.color)
        case .bgTertiary: return Design.col(Asset.Colors.ZDesign.gray100.color, Asset.Colors.ZDesign.shark800.color)
        case .bgQuaternary: return Design.col(Asset.Colors.ZDesign.gray200.color, Asset.Colors.ZDesign.shark700.color)
        case .strokePrimary: return Design.col(Asset.Colors.ZDesign.gray200.color, Asset.Colors.ZDesign.shark700.color)
        case .strokeSecondary: return Design.col(Asset.Colors.ZDesign.gray100.color, Asset.Colors.ZDesign.shark800.color)
        case .bgAlt: return Design.col(Asset.Colors.ZDesign.Base.obsidian.color, Asset.Colors.ZDesign.Base.bone.color)
        case .bgHide: return Design.col(Asset.Colors.ZDesign.Base.obsidian.color, Asset.Colors.ZDesign.Base.obsidian.color)
        case .brandBg: return Design.col(Asset.Colors.ZDesign.Base.brand.color, Asset.Colors.ZDesign.Base.brand.color)
        case .brandFg: return Design.col(Asset.Colors.ZDesign.Base.obsidian.color, Asset.Colors.ZDesign.Base.obsidian.color)
        case .divider: return Design.col(Asset.Colors.ZDesign.gray50.color, Asset.Colors.ZDesign.shark900.color)
        }
    }
}

public extension Design.Text {
    var color: Color {
        switch self {
        case .primary: return Design.col(Asset.Colors.ZDesign.Base.obsidian.color, Asset.Colors.ZDesign.shark50.color)
        case .secondary: return Design.col(Asset.Colors.ZDesign.gray800.color, Asset.Colors.ZDesign.shark200.color)
        case .tertiary: return Design.col(Asset.Colors.ZDesign.gray700.color, Asset.Colors.ZDesign.shark200.color)
        case .quaternary: return Design.col(Asset.Colors.ZDesign.gray600.color, Asset.Colors.ZDesign.shark300.color)
        case .support: return Design.col(Asset.Colors.ZDesign.gray500.color, Asset.Colors.ZDesign.shark400.color)
        case .disabled: return Design.col(Asset.Colors.ZDesign.gray300.color, Asset.Colors.ZDesign.shark600.color)
        case .error: return Design.col(Asset.Colors.ZDesign.errorRed500.color, Asset.Colors.ZDesign.errorRed300.color)
        case .link: return Design.col(Asset.Colors.ZDesign.hyperBlue500.color, Asset.Colors.ZDesign.hyperBlue300.color)
        case .light: return Design.col(Asset.Colors.ZDesign.gray25.color, Asset.Colors.ZDesign.shark50.color)
        case .lightSupport: return Design.col(Asset.Colors.ZDesign.gray200.color, Asset.Colors.ZDesign.shark200.color)
        }
    }
}

public extension Design.Btns.Primary {
    var color: Color {
        switch self {
        case .bg: return Design.col(Asset.Colors.ZDesign.Base.obsidian.color, Asset.Colors.ZDesign.Base.bone.color)
        case .bgHover: return Design.col(Asset.Colors.ZDesign.gray900.color, Asset.Colors.ZDesign.gray100.color)
        case .fg: return Design.col(Asset.Colors.ZDesign.Base.bone.color, Asset.Colors.ZDesign.Base.obsidian.color)
        case .bgDisabled: return Design.col(Asset.Colors.ZDesign.gray100.color, Asset.Colors.ZDesign.shark900.color)
        case .fgDisabled: return Design.col(Asset.Colors.ZDesign.gray500.color, Asset.Colors.ZDesign.shark500.color)
        }
    }
}

public extension Design.Btns.Secondary {
    var color: Color {
        switch self {
        case .bg: return Design.col(Asset.Colors.ZDesign.Base.bone.color, Asset.Colors.ZDesign.Base.obsidian.color)
        case .bgHover: return Design.col(Asset.Colors.ZDesign.gray50.color, Asset.Colors.ZDesign.shark950.color)
        case .fg: return Design.col(Asset.Colors.ZDesign.Base.obsidian.color, Asset.Colors.ZDesign.shark50.color)
        case .fgHover: return Design.col(Asset.Colors.ZDesign.Base.obsidian.color, Asset.Colors.ZDesign.shark50.color)
        case .border: return Design.col(Asset.Colors.ZDesign.gray200.color, Asset.Colors.ZDesign.shark700.color)
        case .borderHover: return Design.col(Asset.Colors.ZDesign.gray200.color, Asset.Colors.ZDesign.shark600.color)
        case .bgDisabled: return Design.col(Asset.Colors.ZDesign.gray100.color, Asset.Colors.ZDesign.shark900.color)
        case .fgDisabled: return Design.col(Asset.Colors.ZDesign.gray500.color, Asset.Colors.ZDesign.shark500.color)
        }
    }
}

public extension Design.Btns.Tertiary {
    var color: Color {
        switch self {
        case .bg: return Design.col(Asset.Colors.ZDesign.gray200.color, Asset.Colors.ZDesign.shark700.color)
        case .bgHover: return Design.col(Asset.Colors.ZDesign.gray300.color, Asset.Colors.ZDesign.shark600.color)
        case .fg: return Design.col(Asset.Colors.ZDesign.gray900.color, Asset.Colors.ZDesign.shark50.color)
        case .fgHover: return Design.col(Asset.Colors.ZDesign.gray900.color, Asset.Colors.ZDesign.shark50.color)
        case .bgDisabled: return Design.col(Asset.Colors.ZDesign.gray200.color, Asset.Colors.ZDesign.shark900.color)
        case .fgDisabled: return Design.col(Asset.Colors.ZDesign.gray500.color, Asset.Colors.ZDesign.shark500.color)
        }
    }
}

public extension Design.Btns.Quaternary {
    var color: Color {
        switch self {
        case .bg: return Design.col(Asset.Colors.ZDesign.gray100.color, Asset.Colors.ZDesign.shark900.color)
        case .bgHover: return Design.col(Asset.Colors.ZDesign.gray200.color, Asset.Colors.ZDesign.shark800.color)
        case .fg: return Design.col(Asset.Colors.ZDesign.gray900.color, Asset.Colors.ZDesign.shark100.color)
        case .fgHover: return Design.col(Asset.Colors.ZDesign.gray900.color, Asset.Colors.ZDesign.shark100.color)
        case .bgDisabled: return Design.col(Asset.Colors.ZDesign.gray100.color, Asset.Colors.ZDesign.shark900.color)
        case .fgDisabled: return Design.col(Asset.Colors.ZDesign.gray500.color, Asset.Colors.ZDesign.shark500.color)
        }
    }
}

public extension Design.Btns.Destructive1 {
    var color: Color {
        switch self {
        case .bg: return Design.col(Asset.Colors.ZDesign.Base.bone.color, Asset.Colors.ZDesign.errorRed950.color)
        case .bgHover: return Design.col(Asset.Colors.ZDesign.errorRed50.color, Asset.Colors.ZDesign.espresso900.color)
        case .fg: return Design.col(Asset.Colors.ZDesign.errorRed600.color, Asset.Colors.ZDesign.errorRed100.color)
        case .fgHover: return Design.col(Asset.Colors.ZDesign.errorRed700.color, Asset.Colors.ZDesign.errorRed50.color)
        case .border: return Design.col(Asset.Colors.ZDesign.errorRed300.color, Asset.Colors.ZDesign.errorRed800.color)
        case .borderHover: return Design.col(Asset.Colors.ZDesign.errorRed300.color, Asset.Colors.ZDesign.errorRed700.color)
        case .bgDisabled: return Design.col(Asset.Colors.ZDesign.gray100.color, Asset.Colors.ZDesign.shark900.color)
        case .fgDisabled: return Design.col(Asset.Colors.ZDesign.gray500.color, Asset.Colors.ZDesign.shark500.color)
        }
    }
}

public extension Design.Btns.Destructive2 {
    var color: Color {
        switch self {
        case .bg: return Design.col(Asset.Colors.ZDesign.errorRed600.color, Asset.Colors.ZDesign.errorRed600.color)
        case .bgHover: return Design.col(Asset.Colors.ZDesign.errorRed700.color, Asset.Colors.ZDesign.errorRed700.color)
        case .fg: return Design.col(Asset.Colors.ZDesign.Base.bone.color, Asset.Colors.ZDesign.errorRed50.color)
        case .bgDisabled: return Design.col(Asset.Colors.ZDesign.gray100.color, Asset.Colors.ZDesign.shark900.color)
        case .fgDisabled: return Design.col(Asset.Colors.ZDesign.gray500.color, Asset.Colors.ZDesign.shark500.color)
        }
    }
}

public extension Design.Btns.Brand {
    var color: Color {
        switch self {
        case .bg: return Design.col(Asset.Colors.ZDesign.brand400.color, Asset.Colors.ZDesign.brand400.color)
        case .bgHover: return Design.col(Asset.Colors.ZDesign.brand300.color, Asset.Colors.ZDesign.brand300.color)
        case .fg: return Design.col(Asset.Colors.ZDesign.Base.obsidian.color, Asset.Colors.ZDesign.Base.obsidian.color)
        case .fgHover: return Design.col(Asset.Colors.ZDesign.Base.obsidian.color, Asset.Colors.ZDesign.Base.obsidian.color)
        case .bgDisabled: return Design.col(Asset.Colors.ZDesign.gray100.color, Asset.Colors.ZDesign.shark900.color)
        case .fgDisabled: return Design.col(Asset.Colors.ZDesign.gray500.color, Asset.Colors.ZDesign.shark500.color)
        }
    }
}

public extension Design.Btns.Ghost {
    var color: Color {
        switch self {
        case .bg: return Design.col(Asset.Colors.ZDesign.Base.bone.color, Asset.Colors.ZDesign.Base.obsidian.color)
        case .bgHover: return Design.col(Asset.Colors.ZDesign.gray50.color, Asset.Colors.ZDesign.gray900.color)
        case .fg: return Design.col(Asset.Colors.ZDesign.Base.obsidian.color, Asset.Colors.ZDesign.shark50.color)
        case .bgDisabled: return Design.col(Asset.Colors.ZDesign.gray100.color, Asset.Colors.ZDesign.shark900.color)
        case .fgDisabled: return Design.col(Asset.Colors.ZDesign.gray500.color, Asset.Colors.ZDesign.shark500.color)
        }
    }
}

public extension Design.Inputs.Default {
    var color: Color {
        switch self {
        case .bg: return Design.col(Asset.Colors.ZDesign.gray50.color, Asset.Colors.ZDesign.shark900.color)
        case .bgAlt: return Design.col(Asset.Colors.ZDesign.Base.bone.color, Asset.Colors.ZDesign.shark950.color)
        case .label: return Design.col(Asset.Colors.ZDesign.Base.obsidian.color, Asset.Colors.ZDesign.shark50.color)
        case .text: return Design.col(Asset.Colors.ZDesign.gray600.color, Asset.Colors.ZDesign.shark400.color)
        case .hint: return Design.col(Asset.Colors.ZDesign.gray700.color, Asset.Colors.ZDesign.shark300.color)
        case .required: return Design.col(Asset.Colors.ZDesign.errorRed600.color, Asset.Colors.ZDesign.errorRed400.color)
        case .icon: return Design.col(Asset.Colors.ZDesign.gray400.color, Asset.Colors.ZDesign.shark400.color)
        case .stroke: return Design.col(Asset.Colors.ZDesign.gray200.color, Asset.Colors.ZDesign.shark800.color)
        }
    }
}

public extension Design.Inputs.Filled {
    var color: Color {
        switch self {
        case .bg: return Design.col(Asset.Colors.ZDesign.gray50.color, Asset.Colors.ZDesign.shark900.color)
        case .bgAlt: return Design.col(Asset.Colors.ZDesign.Base.bone.color, Asset.Colors.ZDesign.shark950.color)
        case .asideBg: return Design.col(Asset.Colors.ZDesign.gray50.color, Asset.Colors.ZDesign.shark900.color)
        case .stroke: return Design.col(Asset.Colors.ZDesign.gray300.color, Asset.Colors.ZDesign.shark700.color)
        case .label: return Design.col(Asset.Colors.ZDesign.Base.obsidian.color, Asset.Colors.ZDesign.shark50.color)
        case .text: return Design.col(Asset.Colors.ZDesign.gray900.color, Asset.Colors.ZDesign.shark100.color)
        case .hint: return Design.col(Asset.Colors.ZDesign.gray700.color, Asset.Colors.ZDesign.shark300.color)
        case .icon: return Design.col(Asset.Colors.ZDesign.gray400.color, Asset.Colors.ZDesign.shark400.color)
        case .iconMain: return Design.col(Asset.Colors.ZDesign.gray500.color, Asset.Colors.ZDesign.shark500.color)
        case .required: return Design.col(Asset.Colors.ZDesign.errorRed600.color, Asset.Colors.ZDesign.errorRed400.color)
        }
    }
}

public extension Design.Inputs.ErrorFilled {
    var color: Color {
        switch self {
        case .bg: return Design.col(Asset.Colors.ZDesign.Base.bone.color, Asset.Colors.ZDesign.shark950.color)
        case .bgAlt: return Design.col(Asset.Colors.ZDesign.gray50.color, Asset.Colors.ZDesign.shark900.color)
        case .label: return Design.col(Asset.Colors.ZDesign.Base.obsidian.color, Asset.Colors.ZDesign.shark50.color)
        case .text: return Design.col(Asset.Colors.ZDesign.gray900.color, Asset.Colors.ZDesign.shark100.color)
        case .textAside: return Design.col(Asset.Colors.ZDesign.gray600.color, Asset.Colors.ZDesign.shark400.color)
        case .hint: return Design.col(Asset.Colors.ZDesign.errorRed600.color, Asset.Colors.ZDesign.errorRed400.color)
        case .icon: return Design.col(Asset.Colors.ZDesign.errorRed500.color, Asset.Colors.ZDesign.errorRed400.color)
        case .iconMain: return Design.col(Asset.Colors.ZDesign.gray500.color, Asset.Colors.ZDesign.shark500.color)
        case .stroke: return Design.col(Asset.Colors.ZDesign.errorRed400.color, Asset.Colors.ZDesign.errorRed500.color)
        case .strokeAlt: return Design.col(Asset.Colors.ZDesign.gray300.color, Asset.Colors.ZDesign.shark700.color)
        case .dropdown: return Design.col(Asset.Colors.ZDesign.gray400.color, Asset.Colors.ZDesign.shark600.color)
        }
    }
}

public extension Design.Avatars {
    var color: Color {
        switch self {
        case .profileBorder: return Design.col(Asset.Colors.ZDesign.Base.bone.color, Asset.Colors.ZDesign.Base.obsidian.color)
        case .bg: return Design.col(Asset.Colors.ZDesign.gray600.color, Asset.Colors.ZDesign.shark600.color)
        case .bgSecondary: return Design.col(Asset.Colors.ZDesign.gray500.color, Asset.Colors.ZDesign.shark500.color)
        case .status: return Design.col(Asset.Colors.ZDesign.successGreen500.color, Asset.Colors.ZDesign.successGreen400.color)
        case .textFg: return Design.col(Asset.Colors.ZDesign.Base.bone.color, Asset.Colors.ZDesign.shark100.color)
        case .badgeBg: return Design.col(Asset.Colors.ZDesign.hyperBlue400.color, Asset.Colors.ZDesign.hyperBlue400.color)
        case .badgeFg: return Design.col(Asset.Colors.ZDesign.Base.bone.color, Asset.Colors.ZDesign.Base.obsidian.color)
        }
    }
}
            
public extension Design.Checkboxes {
    var color: Color {
        switch self {
        case .offBg: return Design.col(Asset.Colors.ZDesign.Base.bone.color, Asset.Colors.ZDesign.shark900.color)
        case .offStroke: return Design.col(Asset.Colors.ZDesign.gray300.color, Asset.Colors.ZDesign.shark400.color)
        case .offHoverBg: return Design.col(Asset.Colors.ZDesign.Base.bone.color, Asset.Colors.ZDesign.shark500.color)
        case .offHoverStroke: return Design.col(Asset.Colors.ZDesign.gray400.color, Asset.Colors.ZDesign.shark400.color)
        case .offDisabledBg: return Design.col(Asset.Colors.ZDesign.gray100.color, Asset.Colors.ZDesign.shark700.color)
        case .offDisabledStroke: return Design.col(Asset.Colors.ZDesign.gray300.color, Asset.Colors.ZDesign.shark600.color)
        case .onBg: return Design.col(Asset.Colors.ZDesign.Base.obsidian.color, Asset.Colors.ZDesign.shark50.color)
        case .onFg: return Design.col(Asset.Colors.ZDesign.Base.bone.color, Asset.Colors.ZDesign.shark900.color)
        case .onHoverBg: return Design.col(Asset.Colors.ZDesign.gray800.color, Asset.Colors.ZDesign.shark300.color)
        case .onDisabledBg: return Design.col(Asset.Colors.ZDesign.gray100.color, Asset.Colors.ZDesign.shark700.color)
        case .onDisabledStroke: return Design.col(Asset.Colors.ZDesign.gray300.color, Asset.Colors.ZDesign.shark600.color)
        case .onDisabledFb: return Design.col(Asset.Colors.ZDesign.gray300.color, Asset.Colors.ZDesign.shark400.color)
        }
    }
}

public extension Design.HintTooltips {
    var color: Color {
        switch self {
        case .surfacePrimary: return Design.col(Asset.Colors.ZDesign.gray950.color, Asset.Colors.ZDesign.shark800.color)
        case .defaultBg: return Design.col(Asset.Colors.ZDesign.gray950.color, Asset.Colors.ZDesign.shark800.color)
        case .defaultFg: return Design.col(Asset.Colors.ZDesign.gray200.color, Asset.Colors.ZDesign.shark200.color)
        case .hoverBg: return Design.col(Asset.Colors.ZDesign.gray900.color, Asset.Colors.ZDesign.shark700.color)
        case .hoverFg: return Design.col(Asset.Colors.ZDesign.gray200.color, Asset.Colors.ZDesign.shark200.color)
        case .focusedBg: return Design.col(Asset.Colors.ZDesign.gray900.color, Asset.Colors.ZDesign.shark700.color)
        case .focusedStroke: return Design.col(Asset.Colors.ZDesign.gray500.color, Asset.Colors.ZDesign.shark500.color)
        case .disabledBg: return Design.col(Asset.Colors.ZDesign.gray900.color, Asset.Colors.ZDesign.shark800.color)
        case .disabledFg: return Design.col(Asset.Colors.ZDesign.gray400.color, Asset.Colors.ZDesign.shark600.color)
        }
    }
}

public extension Design.Utility.Gray {
    var color: Color {
        switch self {
        case ._50: return Design.col(Asset.Colors.ZDesign.gray50.color, Asset.Colors.ZDesign.shark900.color)
        case ._100: return Design.col(Asset.Colors.ZDesign.gray100.color, Asset.Colors.ZDesign.shark800.color)
        case ._200: return Design.col(Asset.Colors.ZDesign.gray200.color, Asset.Colors.ZDesign.shark700.color)
        case ._300: return Design.col(Asset.Colors.ZDesign.gray300.color, Asset.Colors.ZDesign.shark600.color)
        case ._400: return Design.col(Asset.Colors.ZDesign.gray400.color, Asset.Colors.ZDesign.shark500.color)
        case ._500: return Design.col(Asset.Colors.ZDesign.gray500.color, Asset.Colors.ZDesign.shark400.color)
        case ._600: return Design.col(Asset.Colors.ZDesign.gray600.color, Asset.Colors.ZDesign.shark300.color)
        case ._700: return Design.col(Asset.Colors.ZDesign.gray700.color, Asset.Colors.ZDesign.shark200.color)
        case ._800: return Design.col(Asset.Colors.ZDesign.gray800.color, Asset.Colors.ZDesign.shark100.color)
        case ._900: return Design.col(Asset.Colors.ZDesign.gray900.color, Asset.Colors.ZDesign.shark50.color)
        }
    }
}

public extension Design.Utility.SuccessGreen {
    var color: Color {
        switch self {
        case ._50: return Design.col(Asset.Colors.ZDesign.successGreen50.color, Asset.Colors.ZDesign.successGreen950.color)
        case ._100: return Design.col(Asset.Colors.ZDesign.successGreen100.color, Asset.Colors.ZDesign.successGreen900.color)
        case ._200: return Design.col(Asset.Colors.ZDesign.successGreen200.color, Asset.Colors.ZDesign.successGreen800.color)
        case ._300: return Design.col(Asset.Colors.ZDesign.successGreen300.color, Asset.Colors.ZDesign.successGreen700.color)
        case ._400: return Design.col(Asset.Colors.ZDesign.successGreen400.color, Asset.Colors.ZDesign.successGreen600.color)
        case ._500: return Design.col(Asset.Colors.ZDesign.successGreen500.color, Asset.Colors.ZDesign.successGreen500.color)
        case ._600: return Design.col(Asset.Colors.ZDesign.successGreen600.color, Asset.Colors.ZDesign.successGreen400.color)
        case ._700: return Design.col(Asset.Colors.ZDesign.successGreen700.color, Asset.Colors.ZDesign.successGreen300.color)
        case ._800: return Design.col(Asset.Colors.ZDesign.successGreen800.color, Asset.Colors.ZDesign.successGreen200.color)
        case ._900: return Design.col(Asset.Colors.ZDesign.successGreen900.color, Asset.Colors.ZDesign.successGreen100.color)
        }
    }
}

public extension Design.Utility.ErrorRed {
    var color: Color {
        switch self {
        case ._50: return Design.col(Asset.Colors.ZDesign.errorRed50.color, Asset.Colors.ZDesign.errorRed950.color)
        case ._100: return Design.col(Asset.Colors.ZDesign.errorRed100.color, Asset.Colors.ZDesign.errorRed900.color)
        case ._200: return Design.col(Asset.Colors.ZDesign.errorRed200.color, Asset.Colors.ZDesign.errorRed800.color)
        case ._300: return Design.col(Asset.Colors.ZDesign.errorRed300.color, Asset.Colors.ZDesign.errorRed700.color)
        case ._400: return Design.col(Asset.Colors.ZDesign.errorRed400.color, Asset.Colors.ZDesign.errorRed600.color)
        case ._500: return Design.col(Asset.Colors.ZDesign.errorRed500.color, Asset.Colors.ZDesign.errorRed500.color)
        case ._600: return Design.col(Asset.Colors.ZDesign.errorRed600.color, Asset.Colors.ZDesign.errorRed400.color)
        case ._700: return Design.col(Asset.Colors.ZDesign.errorRed700.color, Asset.Colors.ZDesign.errorRed300.color)
        case ._800: return Design.col(Asset.Colors.ZDesign.errorRed800.color, Asset.Colors.ZDesign.errorRed200.color)
        case ._900: return Design.col(Asset.Colors.ZDesign.errorRed900.color, Asset.Colors.ZDesign.errorRed100.color)
        }
    }
}

public extension Design.Utility.WarningYellow {
    var color: Color {
        switch self {
        case ._50: return Design.col(Asset.Colors.ZDesign.warningYellow50.color, Asset.Colors.ZDesign.warningYellow950.color)
        case ._100: return Design.col(Asset.Colors.ZDesign.warningYellow100.color, Asset.Colors.ZDesign.warningYellow900.color)
        case ._200: return Design.col(Asset.Colors.ZDesign.warningYellow200.color, Asset.Colors.ZDesign.warningYellow800.color)
        case ._300: return Design.col(Asset.Colors.ZDesign.warningYellow300.color, Asset.Colors.ZDesign.warningYellow700.color)
        case ._400: return Design.col(Asset.Colors.ZDesign.warningYellow400.color, Asset.Colors.ZDesign.warningYellow600.color)
        case ._500: return Design.col(Asset.Colors.ZDesign.warningYellow500.color, Asset.Colors.ZDesign.warningYellow500.color)
        case ._600: return Design.col(Asset.Colors.ZDesign.warningYellow600.color, Asset.Colors.ZDesign.warningYellow400.color)
        case ._700: return Design.col(Asset.Colors.ZDesign.warningYellow700.color, Asset.Colors.ZDesign.warningYellow300.color)
        case ._800: return Design.col(Asset.Colors.ZDesign.warningYellow800.color, Asset.Colors.ZDesign.warningYellow200.color)
        case ._900: return Design.col(Asset.Colors.ZDesign.warningYellow900.color, Asset.Colors.ZDesign.warningYellow100.color)
        }
    }
}

public extension Design.Utility.HyperBlue {
    var color: Color {
        switch self {
        case ._50: return Design.col(Asset.Colors.ZDesign.hyperBlue50.color, Asset.Colors.ZDesign.hyperBlue950.color)
        case ._100: return Design.col(Asset.Colors.ZDesign.hyperBlue100.color, Asset.Colors.ZDesign.hyperBlue900.color)
        case ._200: return Design.col(Asset.Colors.ZDesign.hyperBlue200.color, Asset.Colors.ZDesign.hyperBlue800.color)
        case ._300: return Design.col(Asset.Colors.ZDesign.hyperBlue300.color, Asset.Colors.ZDesign.hyperBlue700.color)
        case ._400: return Design.col(Asset.Colors.ZDesign.hyperBlue400.color, Asset.Colors.ZDesign.hyperBlue600.color)
        case ._500: return Design.col(Asset.Colors.ZDesign.hyperBlue500.color, Asset.Colors.ZDesign.hyperBlue500.color)
        case ._600: return Design.col(Asset.Colors.ZDesign.hyperBlue600.color, Asset.Colors.ZDesign.hyperBlue400.color)
        case ._700: return Design.col(Asset.Colors.ZDesign.hyperBlue700.color, Asset.Colors.ZDesign.hyperBlue300.color)
        case ._800: return Design.col(Asset.Colors.ZDesign.hyperBlue800.color, Asset.Colors.ZDesign.hyperBlue200.color)
        case ._900: return Design.col(Asset.Colors.ZDesign.hyperBlue900.color, Asset.Colors.ZDesign.hyperBlue100.color)
        }
    }
}

public extension Design.Utility.Indigo {
    var color: Color {
        switch self {
        case ._50: return Design.col(Asset.Colors.ZDesign.indigo50.color, Asset.Colors.ZDesign.indigo950.color)
        case ._100: return Design.col(Asset.Colors.ZDesign.indigo100.color, Asset.Colors.ZDesign.indigo900.color)
        case ._200: return Design.col(Asset.Colors.ZDesign.indigo200.color, Asset.Colors.ZDesign.indigo800.color)
        case ._300: return Design.col(Asset.Colors.ZDesign.indigo300.color, Asset.Colors.ZDesign.indigo700.color)
        case ._400: return Design.col(Asset.Colors.ZDesign.indigo400.color, Asset.Colors.ZDesign.indigo600.color)
        case ._500: return Design.col(Asset.Colors.ZDesign.indigo500.color, Asset.Colors.ZDesign.indigo500.color)
        case ._600: return Design.col(Asset.Colors.ZDesign.indigo600.color, Asset.Colors.ZDesign.indigo400.color)
        case ._700: return Design.col(Asset.Colors.ZDesign.indigo700.color, Asset.Colors.ZDesign.indigo300.color)
        case ._800: return Design.col(Asset.Colors.ZDesign.indigo800.color, Asset.Colors.ZDesign.indigo200.color)
        case ._900: return Design.col(Asset.Colors.ZDesign.indigo900.color, Asset.Colors.ZDesign.indigo100.color)
        }
    }
}

public extension Design.Utility.Purple {
    var color: Color {
        switch self {
        case ._50: return Design.col(Asset.Colors.ZDesign.purple50.color, Asset.Colors.ZDesign.purple950.color)
        case ._100: return Design.col(Asset.Colors.ZDesign.purple100.color, Asset.Colors.ZDesign.purple900.color)
        case ._200: return Design.col(Asset.Colors.ZDesign.purple200.color, Asset.Colors.ZDesign.purple800.color)
        case ._300: return Design.col(Asset.Colors.ZDesign.purple300.color, Asset.Colors.ZDesign.purple700.color)
        case ._400: return Design.col(Asset.Colors.ZDesign.purple400.color, Asset.Colors.ZDesign.purple600.color)
        case ._500: return Design.col(Asset.Colors.ZDesign.purple500.color, Asset.Colors.ZDesign.purple500.color)
        case ._600: return Design.col(Asset.Colors.ZDesign.purple600.color, Asset.Colors.ZDesign.purple400.color)
        case ._700: return Design.col(Asset.Colors.ZDesign.purple700.color, Asset.Colors.ZDesign.purple300.color)
        case ._800: return Design.col(Asset.Colors.ZDesign.purple800.color, Asset.Colors.ZDesign.purple200.color)
        case ._900: return Design.col(Asset.Colors.ZDesign.purple900.color, Asset.Colors.ZDesign.purple100.color)
        }
    }
}

// MARK: Helpers

private extension Design {
     static func col(_ light: Color, _ dark: Color) -> Color {
        UITraitCollection.current.userInterfaceStyle == .light ? light : dark
    }
}
