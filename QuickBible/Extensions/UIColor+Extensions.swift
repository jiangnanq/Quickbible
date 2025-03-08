import UIKit

extension UIColor {
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a) else { return nil }
        return UIColor(hue: h,
                      saturation: s,
                      brightness: max(b - percentage/100, 0.0),
                      alpha: a)
    }
}
