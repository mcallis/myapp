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
        static let returnMyPlacesFromAddPlace = "returnMyPlacesFromAddPlace"
        static let returnFromAddLocation = "returnFromAddLocation"
    }
    
    struct ErrorMessage{
        static let userNameisRequired   = "Username is required"
        static let passwordisRequired   = "Password is required"
        static let nameisRequired       = "Full name is required"
        static let passwordsDontMatch   = "The passwords don't match"
        static let mustAcceptTerms      = "You must accept the terms to register"
        static let emailisRequired      = "Email is required"
        static let namePlaceRequired    = "Name is required"
        static let descPlaceRequired    = "Description is required"
        static let longPlaceRequired    = "Longitude is required"
        static let latPlaceRequired     = "Latitude is required"
    }
    
    struct TitlesViews {
        static let signup               = "Sign Up"
        static let addPlace             = "Add Place"
        static let addLocation          = "Add Location"
    }
    
    struct Notifications {
        static let loginSuccess         = "loginSuccess"
        static let singupSuccess        = "singupSuccess"
        static let logOutSuccess        = "logoutSuccess"
    }
}
