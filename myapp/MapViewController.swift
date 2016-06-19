//
//  MapViewController.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 20/6/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation

class MapViewController: UIViewControllerOwn, FilterManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var mapView: MKMapView!
  
    @IBOutlet weak var tableView: UITableView!
    
    var distance: Int!
    
    var listPlaces: [Place] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.hidden = false
        self.tableView.hidden = true
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //loadPlaces()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print("viewWillAppear")
        print("distance: \(self.distance) khkh")
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        
        switch (self.segmentedControl.selectedSegmentIndex)
        {
        case 0:
            self.mapView.hidden = false
            self.tableView.hidden = true
            break;
        case 1:
            self.mapView.hidden = false
            self.tableView.hidden = false
            break;
        default: 
            break; 
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToFilter" {
            let destinationVC = segue.destinationViewController as! FilterViewController
            destinationVC.delegate = self
            destinationVC.distance = self.distance
        }
    }
    
    func calculateWithNewDistance(distance: Int) {
        self.distance = distance
        print("distance: \(self.distance)")
    }
    
    
    // Methods to TableView Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listPlaces.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        return cell
    }
    
    
    
    
    
}
