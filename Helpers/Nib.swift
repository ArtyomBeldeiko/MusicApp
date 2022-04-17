//
//  Nib.swift
//  MusicApp
//
//  Created by Artyom Beldeiko on 21.03.22.
//

import Foundation
import UIKit

extension UIView {
    
    class func loadFromNib<T: UIView>() -> T {
        
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
        
    }
    
}
