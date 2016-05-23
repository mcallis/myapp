//
//  MyPlaces.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 21/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation

class MyPlaces: UITableViewControllerOwn {
    
    let mAppManager = AppManager.sharedInstance
    let mPlaceManager = PlaceManager()
    var listPlaces: NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        // Get All Places
        startIndicator()
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
        getData()
    }
    
    func configureTableView(){
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 250.0;
    }
    
    func getData(){
        mPlaceManager.findAllElements({ (result) in
            self.stopIndicator()
            self.listPlaces = result
            self.tableView.reloadData()
        }) { (error) in
            self.stopIndicator()
            self.alertError(error.message)
        }
    }
    
    
    // TABLEVIEW METHODS
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listPlaces.count
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        let currentPlace: Place = listPlaces[indexPath.row] as! Place
        detailVC.currentPlace = currentPlace
                
        self.navigationController?.pushViewController(detailVC, animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LabelCell", forIndexPath: indexPath) as! PlaceCell

        // Configure cell...
        setImageForCell(cell, indexPath: indexPath)
        setTitleForCell(cell, indexPath: indexPath)
        setDescForCell(cell, indexPath: indexPath)
        return cell
    }
    
    
    func setImageForCell(cell: PlaceCell, indexPath: NSIndexPath){
        let place = listPlaces[indexPath.row] as! Place
        let image = UIImage(named: "no_image")
        
        if place.urlImage == nil {
            cell.customImage.image = image
        } else {
            downloadImage(NSURL(string: place.urlImage)!, imageView: cell.customImage)
        }
    }
    
    func downloadImage(url: NSURL, imageView: UIImageView!){
        print("Download Started")
        print("lastPathComponent: " + (url.lastPathComponent ?? ""))
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                print(response?.suggestedFilename ?? "")
                print("Download Finished")
                imageView.image = UIImage(data: data)
            }
        }
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func setTitleForCell(cell: PlaceCell, indexPath: NSIndexPath){
        let place = listPlaces[indexPath.row] as! Place
        cell.name.text = place.name
    }
    
    func setDescForCell(cell: PlaceCell, indexPath: NSIndexPath){
        let place = listPlaces[indexPath.row] as! Place
        cell.desc.text = place.desc

    }
    
    @IBAction func returnFromAddPlace(segue: UIStoryboardSegue) {
       
    }
    
    func alertError(message: String){
        let alertController = UIAlertOwn(title: "Error", message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}