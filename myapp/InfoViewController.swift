//
//  InfoViewController.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 24/6/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation


class InfoViewController: UIViewControllerOwn {
    
    
    @IBOutlet weak var fieldTotalUsers: UILabel!
    @IBOutlet weak var fieldTotalPlaces: UILabel!
    
    
    
    var backendless = Backendless.sharedInstance()
    
    // Datos que va a gestionar este controlador
    var listPlaces: [Place] = []

   
    
    // Numero de consulta a Backendless, se utiliza para cancelar las peticiones asíncronas que estuvieran
    // pendientes cuando consulta de sitios
    var currentQueryNumberTotalPlaces = 0
    var currentQueryNumberTotalUsers = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUsers()
        
        loadPlaces()
        
    }
    
    func loadPlaces(){
        // Durante todo el proceso de carga mostraremos el indicador de actividad de red en la aplicación
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        startIndicator()
        
        currentQueryNumberTotalPlaces += 1
        let queryNumber = currentQueryNumberTotalPlaces
        
        // Consultaremos los stios junto con sus relaciones images y location
        let query = BackendlessDataQuery()
        query.queryOptions.pageSize = 5
        
        backendless.data.of(Place.ofClass()).find(
            query,
            response: { ( places : BackendlessCollection!) -> () in
                if queryNumber == self.currentQueryNumberTotalPlaces {
                    print("Total places in the server: \(places.totalObjects)")
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    self.stopIndicator()

                    self.fieldTotalPlaces.text = "\(places.totalObjects)"
                }
            },
            error: { (fault : Fault!) -> () in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.stopIndicator()
                
                if queryNumber == self.currentQueryNumberTotalPlaces {
                    if self.listPlaces.count > 0{
                        let alertController = UIAlertController(title: "Error", message: "An error has ocurred while fetching your places", preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
                        alertController.addAction(OKAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    
                }
            }
        )
    }
    
    func loadUsers(){
        // Durante todo el proceso de carga mostraremos el indicador de actividad de red en la aplicación
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        startIndicator()
        
        currentQueryNumberTotalUsers += 1
        let queryNumber = currentQueryNumberTotalUsers
        
        // Consultaremos los stios junto con sus relaciones images y location
        let query = BackendlessDataQuery()
        query.queryOptions.pageSize = 1
        
        backendless.data.of(BackendlessUser.ofClass()).find(
            query,
            response: { ( users : BackendlessCollection!) -> () in
                if queryNumber == self.currentQueryNumberTotalUsers {
                    print("Total places in the server: \(users.totalObjects)")
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    self.stopIndicator()
                    
                    self.fieldTotalUsers.text = "\(users.totalObjects)"
                }
            },
            error: { (fault : Fault!) -> () in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.stopIndicator()
                
                if queryNumber == self.currentQueryNumberTotalUsers {
                    if self.listPlaces.count > 0{
                        let alertController = UIAlertController(title: "Error", message: "An error has ocurred while fetching your places", preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
                        alertController.addAction(OKAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    
                }
            }
        )

    }

}
