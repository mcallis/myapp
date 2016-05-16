//
//  AppFormViewController.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 15/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//


class AppFormViewController: UIViewControllerOwn {
    
    var mAppManager: AppManager!
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mAppManager = AppManager.sharedInstance
        
        // Get currentUser
        user = mAppManager.currentUser
        
        
        
    }
    
}