//
//  TableViewController.swift
//  RSSFeed
//
//  Created by Yakov Shkolnikov on 12/16/15.
//  Copyright © 2015 junor. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var items = [Item]()
    var selectedItem: Item?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView!.registerNib(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        
        self.navigationItem.title = "Apple News"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector(updateTable()), name: "UPDATE", object: nil)
        
        
    }
    
    func updateTable() {
        if let tempItems = DataManager.sharedInstance.getAllItems() {
            self.items = tempItems
            self.sortItemsByDate()
        } else {
            print("Error in TableViewController:updateTable()")
        }
        
        self.tableView.reloadData()
    }
    

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableViewCell", forIndexPath: indexPath) as! TableViewCell
        
        cell.selectionStyle = .None
        
        cell.titleTextView.text = self.items[indexPath.row].title
        cell.timeLabel.text = self.items[indexPath.row].time
        cell.detailTextView.text = self.getAppropriateStringForDetailtTextView(self.items[indexPath.row].descr!)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedItem = self.items[indexPath.row]
        self.performSegueWithIdentifier("ShowDetailViewControllerSegue", sender: self)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let detailViewController = segue.destinationViewController as! DetailViewController
        
        detailViewController.item = self.selectedItem
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil)
    }
    
    
    // Utils
    
    func sortItemsByDate() {
        self.items.sortInPlace({ $0.pubDate!.compare($1.pubDate!) == .OrderedDescending })
    }
    
    // This method used for get short version of detail description
    func getAppropriateStringForDetailtTextView(string: String) -> String {
        let stringsArray = string.componentsSeparatedByString(" ")
        var returnString = ""
        
        var maxValue = stringsArray.count
        if maxValue > 13 {
            maxValue = 13
        }
        
        for var i = 0; i < maxValue; i++ {
            returnString += stringsArray[i] + " "
        }
        
        returnString += "..."
        
        return returnString
    }
}











