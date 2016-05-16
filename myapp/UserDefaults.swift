//
//  UserDefaults.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 13/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation
import UIKit

class UserDefaults {
    
    static func add(value: NSObject, key: String){
        NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
    }
    
    static func remove(key: String){
        NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
    }
    
    static func clearAll(){
        for key in NSUserDefaults.standardUserDefaults().dictionaryRepresentation().keys {
            remove(key)
        }
    }
    
    static func get(key: String) -> AnyObject?{
        return NSUserDefaults.standardUserDefaults().objectForKey(key)
    }
    
}
