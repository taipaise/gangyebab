//
//  NSObject+extenstions.swift
//  Gangyebab
//
//  Created by 이동현 on 3/11/24.
//

import Foundation

public extension NSObject {
    
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
    
    var bundle: Bundle {
        return Bundle(for: type(of: self))
    }
    
    class var bundle: Bundle {
        return Bundle(for: self)
    }
    
}
