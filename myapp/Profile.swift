//
//  Profile.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 14/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//


class Profile: UIViewControllerOwn, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    var mAppManager: AppManager!
    var properties: [String] = []
    var data: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // init table
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "ProfileCell")
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CellLogOut")
        
        // Init appmanager
        mAppManager = AppManager.sharedInstance
        let currentUser = mAppManager.currentUser
        properties = ["Username", "Name", "Email"]
        data = [currentUser.username, currentUser.name, currentUser.email]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Personal Details"
        } else {
            return nil
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return properties.count
        } else {
            return 1
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell!
        if indexPath.section == 0 {
            //cell = self.tableView.dequeueReusableCellWithIdentifier("ProfileCell")! as UITableViewCell
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "ProfileCell")
            cell.textLabel?.text = self.properties[indexPath.row]
            cell.detailTextLabel?.text = self.data[indexPath.row]
            cell.userInteractionEnabled = false
        }
        if indexPath.section == 1 {
            cell = self.tableView.dequeueReusableCellWithIdentifier("CellLogOut")! as UITableViewCell
            cell.textLabel?.textAlignment = .Center
            cell.textLabel?.textColor = UIColor.redColor()
            cell.textLabel?.text = "Log Out"
        }
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1{
            mAppManager.doLogOut()
            self.performSegueWithIdentifier(Constants.Segues.fromLogOut, sender: self)
            tabBarController?.selectedIndex = 0
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.Segues.fromLogOut {
            let loginVC = segue.destinationViewController as! Login
            loginVC.setFromLogOut()
        }
    }

    
    
}