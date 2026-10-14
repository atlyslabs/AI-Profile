import UIKit

@MainActor
public protocol ProfileV3CouponsHost: AnyObject, Sendable {
    func presentCoupons(from presenter: UIViewController)
}
