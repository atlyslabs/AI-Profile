import ATUIKit
import SwiftUI

extension ProfileV3Theme.Sizes {
    enum PersonaProcessing {
        static let labelWidth: CGFloat = 72
        static let messageTop: CGFloat = 26.8
        static let bottom: CGFloat = 25
        static let loader: CGFloat = 172
        static let loaderTop: CGFloat = 59.8
        static let rim: CGFloat = 7.8182
        static let ring: CGFloat = 2.5049
        static let knob: CGFloat = 65.1262
        static let knobStroke: CGFloat = 2.5049
        static let knobShadowInset: CGFloat = 6.6796
        static let knobShadowY: CGFloat = 16.699
        static let knobShadowBlur: CGFloat = 18.3689
        static let arc: CGFloat = 116.8932
        static let arcLineWidth: CGFloat = 50.0971
        static let arcOffset: CGFloat = -0.598
        static let arcTrimStart: CGFloat = 0.25
        static let arcGradientStart: Double = 29.84
        static let innerShadowY: CGFloat = 17.534
        static let innerShadowSpread: CGFloat = 15.8641
        static let innerShadowBlur: CGFloat = 14.1942
        static let dropShadowY: CGFloat = 8.3495
        static let dropShadowRadius: CGFloat = 5.0097
    }
}

extension ProfileV3Theme.Palette {
    static let personaLoaderRimTop = Color(hex: "F0EEEF")
    static let personaLoaderRimBottom = Color(hex: "989898")
    static let personaLoaderRingTop = Color(hex: "CCD9E3")
    static let personaLoaderRingBottom = Color(hex: "E1EAF1")
    static let personaKnobTop = Color(hex: "DAD8D8")
    static let personaKnobBottom = Color(hex: "9D9D9D")
    static let personaKnobEdgeBottom = Color(hex: "747373")
    static let personaKnobShadow = Color(hex: "0A0A0A")
    static let personaLoaderShadow = Color(hex: "B4B4B4")
    static let personaCaptionMid = Color(hex: "838383")
}

extension ProfileV3Theme.Opacity {
    static let personaLoader: Double = 0.8
    static let personaArc: Double = 0.7
    static let personaKnobShadow: Double = 0.85
    static let personaLoaderShadow: Double = 0.27
    static let personaInnerShadow: Double = 0.45
}

extension ProfileV3Theme.Motion {
    static let personaProcessingLoop: Double = 4
    static let personaWaveTickIntensity: Double = 0.5
}

extension ProfileV3Theme {
    static let personaArcGradient = AngularGradient(
        stops: [
            .init(color: Color(.sRGB, red: 229 / 255, green: 81 / 255, blue: 91 / 255, opacity: 0.587), location: 0),
            .init(color: Color(.sRGB, red: 250 / 255, green: 136 / 255, blue: 144 / 255, opacity: 0), location: 0.0542),
            .init(color: Color(.sRGB, red: 252 / 255, green: 206 / 255, blue: 126 / 255, opacity: 0), location: 0.1428),
            .init(color: Color(.sRGB, red: 252 / 255, green: 229 / 255, blue: 114 / 255, opacity: 1), location: 0.2964),
            .init(color: Color(.sRGB, red: 73 / 255, green: 46 / 255, blue: 238 / 255, opacity: 0.7587), location: 0.573),
            .init(color: Color(.sRGB, red: 189 / 255, green: 41 / 255, blue: 214 / 255, opacity: 1), location: 0.7353),
            .init(color: Color(.sRGB, red: 214 / 255, green: 41 / 255, blue: 155 / 255, opacity: 1), location: 0.822),
            .init(color: Color(.sRGB, red: 214 / 255, green: 42 / 255, blue: 54 / 255, opacity: 1), location: 0.9619),
            .init(color: Color(.sRGB, red: 229 / 255, green: 81 / 255, blue: 91 / 255, opacity: 0.587), location: 1),
        ],
        center: .center,
        startAngle: .degrees(Sizes.PersonaProcessing.arcGradientStart),
        endAngle: .degrees(Sizes.PersonaProcessing.arcGradientStart + 360)
    )

    static let personaLoaderRim = LinearGradient(
        colors: [Palette.personaLoaderRimTop, Palette.personaLoaderRimBottom],
        startPoint: .top,
        endPoint: .bottom
    )

    static let personaLoaderRing = LinearGradient(
        colors: [Palette.personaLoaderRingTop, Palette.personaLoaderRingBottom],
        startPoint: .top,
        endPoint: .bottom
    )

    static let personaKnobFill = LinearGradient(
        colors: [Palette.personaKnobTop, Palette.personaKnobBottom],
        startPoint: .top,
        endPoint: .bottom
    )

    static let personaKnobEdge = LinearGradient(
        colors: [Color(at: .pureWhite), Palette.personaKnobEdgeBottom],
        startPoint: .top,
        endPoint: .bottom
    )
}
