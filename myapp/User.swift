//
//  User.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 13/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation
import UIKit

class User {
    var username    = ""
    var password    = ""
    var name        = ""
    var email       = ""
    var logged      = false
    
    init(){}
    
       
    func get(loggedInUser: BackendlessUser){
        self.username = loggedInUser.getProperty("username") as! String
        self.password = loggedInUser.password
        self.name     = loggedInUser.name
        
    }

    
}