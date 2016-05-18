//
//  Constants.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 13/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation

struct Constants {
    struct UserDefaults {
        static let usernameKeyConstant  = "currentUsername"
        static let passwordKeyConstant  = "currentPassword"
    }
    
    struct Segues {
        // Login.swift
        static let fromLoginToSignUp    = "fromLoginToSignUp"
        static let fromLoginToMain      = "fromLoginToMain"
        static let fromSignUpToMain     = "fromSignUpToMain"
        static let fromLogOut           = "UnwindLogOut"
    
    }
    
    struct ErrorMessage{
        static let userNameisRequired   = "Username is required"
        static let passwordisRequired   = "Password is required"
        static let nameisRequired       = "Name is required"
    }
    
    struct TitlesViews {
        static let signup               = "Sign Up"
    }
    
    struct Notifications {
        static let loginSuccess         = "loginSuccess"
        static let singupSuccess        = "singupSuccess"
        static let logOutSuccess        = "logoutSuccess"
    }
}
