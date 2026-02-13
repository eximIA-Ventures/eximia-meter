import SwiftUI

// Logo exímIA — converted from Logos/SIMBOLO.svg
// ViewBox: 0 0 120.4 136.01
// Two paths: right (amber) + left (white)

struct ExLogoIcon: View {
    var size: CGFloat = 24

    var body: some View {
        ZStack {
            ExLogoRightPath()
                .fill(ExTokens.Colors.accentPrimary)
            ExLogoLeftPath()
                .fill(Color.white)
        }
        .frame(width: size, height: size * (136.01 / 120.4))
    }
}

// Right path: M58.88,132.06 ...
struct ExLogoRightPath: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 120.4
        let sy = rect.height / 136.01
        var p = Path()

        p.move(to: CGPoint(x: 58.88 * sx, y: 132.06 * sy))
        p.addCurve(
            to: CGPoint(x: 64.41 * sx, y: 135.56 * sy),
            control1: CGPoint(x: 58.88 * sx, y: 134.9 * sy),
            control2: CGPoint(x: 61.84 * sx, y: 136.78 * sy)
        )
        p.addLine(to: CGPoint(x: 115.41 * sx, y: 111.47 * sy))
        p.addCurve(
            to: CGPoint(x: 120.39 * sx, y: 103.58 * sy),
            control1: CGPoint(x: 118.45 * sx, y: 110.03 * sy),
            control2: CGPoint(x: 120.4 * sx, y: 106.96 * sy)
        )
        p.addLine(to: CGPoint(x: 120.37 * sx, y: 79.71 * sy))
        p.addLine(to: CGPoint(x: 120.37 * sx, y: 77.9 * sy))
        p.addLine(to: CGPoint(x: 120.31 * sx, y: 16.95 * sy))
        p.addCurve(
            to: CGPoint(x: 114.59 * sx, y: 9.14 * sy),
            control1: CGPoint(x: 120.31 * sx, y: 13.38 * sy),
            control2: CGPoint(x: 118.0 * sx, y: 10.22 * sy)
        )
        p.addLine(to: CGPoint(x: 87.3 * sx, y: 0.46 * sy))
        p.addCurve(
            to: CGPoint(x: 76.61 * sx, y: 8.29 * sy),
            control1: CGPoint(x: 82.01 * sx, y: -1.22 * sy),
            control2: CGPoint(x: 76.6 * sx, y: 2.73 * sy)
        )
        p.addLine(to: CGPoint(x: 76.65 * sx, y: 46.8 * sy))
        p.addCurve(
            to: CGPoint(x: 94.28 * sx, y: 71.12 * sy),
            control1: CGPoint(x: 76.66 * sx, y: 57.87 * sy),
            control2: CGPoint(x: 83.77 * sx, y: 67.68 * sy)
        )
        p.addLine(to: CGPoint(x: 117.89 * sx, y: 78.9 * sy))
        p.addLine(to: CGPoint(x: 64.61 * sx, y: 100.28 * sy))
        p.addCurve(
            to: CGPoint(x: 58.86 * sx, y: 108.79 * sy),
            control1: CGPoint(x: 61.13 * sx, y: 101.67 * sy),
            control2: CGPoint(x: 58.86 * sx, y: 105.05 * sy)
        )
        p.addLine(to: CGPoint(x: 58.88 * sx, y: 132.06 * sy))
        p.closeSubpath()

        return p
    }
}

// Left path: M61.33,3.85 ...
struct ExLogoLeftPath: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 120.4
        let sy = rect.height / 136.01
        var p = Path()

        p.move(to: CGPoint(x: 61.33 * sx, y: 3.85 * sy))
        p.addCurve(
            to: CGPoint(x: 55.77 * sx, y: 0.38 * sy),
            control1: CGPoint(x: 61.31 * sx, y: 1.01 * sy),
            control2: CGPoint(x: 58.34 * sx, y: -0.85 * sy)
        )
        p.addLine(to: CGPoint(x: 4.93 * sx, y: 24.8 * sy))
        p.addCurve(
            to: CGPoint(x: 0.0 * sx, y: 32.73 * sy),
            control1: CGPoint(x: 1.9 * sx, y: 26.27 * sy),
            control2: CGPoint(x: -0.02 * sx, y: 29.35 * sy)
        )
        p.addLine(to: CGPoint(x: 0.18 * sx, y: 56.6 * sy))
        p.addLine(to: CGPoint(x: 0.18 * sx, y: 58.41 * sy))
        p.addLine(to: CGPoint(x: 0.65 * sx, y: 119.35 * sy))
        p.addCurve(
            to: CGPoint(x: 6.42 * sx, y: 127.12 * sy),
            control1: CGPoint(x: 0.68 * sx, y: 122.92 * sy),
            control2: CGPoint(x: 3.01 * sx, y: 126.06 * sy)
        )
        p.addLine(to: CGPoint(x: 33.77 * sx, y: 135.63 * sy))
        p.addCurve(
            to: CGPoint(x: 44.41 * sx, y: 127.74 * sy),
            control1: CGPoint(x: 39.07 * sx, y: 137.28 * sy),
            control2: CGPoint(x: 44.45 * sx, y: 133.3 * sy)
        )
        p.addLine(to: CGPoint(x: 44.12 * sx, y: 89.23 * sy))
        p.addCurve(
            to: CGPoint(x: 26.33 * sx, y: 65.02 * sy),
            control1: CGPoint(x: 44.04 * sx, y: 78.16 * sy),
            control2: CGPoint(x: 36.86 * sx, y: 68.4 * sy)
        )
        p.addLine(to: CGPoint(x: 2.67 * sx, y: 57.4 * sy))
        p.addLine(to: CGPoint(x: 55.81 * sx, y: 35.67 * sy))
        p.addCurve(
            to: CGPoint(x: 61.5 * sx, y: 27.12 * sy),
            control1: CGPoint(x: 59.28 * sx, y: 34.25 * sy),
            control2: CGPoint(x: 61.53 * sx, y: 30.87 * sy)
        )
        p.addLine(to: CGPoint(x: 61.33 * sx, y: 3.85 * sy))
        p.closeSubpath()

        return p
    }
}
