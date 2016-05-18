//
//  UITableViewControllerOwn.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 14/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation

class UITableViewControllerOwn: UITableViewController {
    
    private var indicador: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        self.prepareActivityIndicatorView()
    }
    
    func prepareActivityIndicatorView(){
        self.indicador.center = self.view.center
        self.indicador.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleWidth, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleHeight, .FlexibleBottomMargin]
        self.indicador.hidesWhenStopped = true
        self.indicador.activityIndicatorViewStyle = .WhiteLarge
        self.indicador.color = UIColor.grayColor()
        self.view.addSubview(self.indicador)
    }
    
    func startIndicator(){
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        self.indicador.startAnimating()
    }
    
    func stopIndicator(){
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        self.indicador.stopAnimating()
    }
    
    
}