//
//  UIViewController + Stroryboard.swift
//  MusicApp
//
//  Created by Artyom Beldeiko on 13.03.22.
//

import Foundation
import UIKit

extension UIViewController {
    class func loadFromStoryBoard<T: UIViewController>() -> T {
        let name = String(describing: T.self)
        let storyboard = UIStoryboard(name: name, bundle: nil)
        if let viewController = storyboard.instantiateInitialViewController() as? T {
            return viewController
        } else {
            fatalError("No initial view controller in \(name) storyboard.")
        }
    }
}
