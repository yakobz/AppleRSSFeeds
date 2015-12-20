//
//  DataManager.swift
//  RSSFeed
//
//  Created by Yakov Shkolnikov on 12/19/15.
//  Copyright © 2015 junor. All rights reserved.
//

import UIKit
import CoreData

// This class work with core data

class DataManager: NSObject, NSXMLParserDelegate {
    
    static let sharedInstance = DataManager()
    
    let appDelegate: AppDelegate
    let url = NSURL(string: "http://developer.apple.com/news/rss/news.rss")!
    
    // In this item we will write downloaded info
    var item: Item?
    
    // Readed info for some teg
    var string: String
    
    var needCheckToExestingObject: Bool
    
    override init() {
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        self.needCheckToExestingObject = false
        self.string = ""

        super.init()
    }
    
    func updateFeeds() {
        let xmlParser = NSXMLParser(contentsOfURL: url)
        xmlParser?.delegate = self
        xmlParser?.parse()
    }
    

    // NSXMLParserDelegate
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "item" {
            self.item = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: self.appDelegate.managedObjectContext) as? Item
        }
        
        self.string = ""
    }

    func parser(parser: NSXMLParser, foundCharacters string: String) {
        self.string += string
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "item":
            self.item = nil
        case "title":
            // Check - if we read info not first time we must check - object with this title exist or no
            // If object exist - stop psrsing, if no - create one
            if self.needCheckToExestingObject && self.objectWithTitleExist(self.string) {
                self.appDelegate.managedObjectContext.deleteObject(self.item!)

                self.item = nil
                self.needCheckToExestingObject = false

                parser.abortParsing()
                
                // This method called for save new items
                // And for reload table view content
                self.parserDidEndDocument(parser)
            } else {
                self.item?.title = self.string
            }
        case "link":
            self.item?.getImageByStringUrl(self.string)
        case "description":
            self.item?.descr = self.string
        case "pubDate":
            self.item?.pubDate = self.dateFromString(self.string)
            self.item?.time = self.string
        case "lastBuildDate":
            // Every time when we will start parsing we will find entry like this: <lastBuildDate>Thu, 17 Dec 2015 16:45:00 PST</lastBuildDate>
            // This value we will store at user defaults. If we start parsing, second time, and news was not updated, we will not update info.
            // If we parsing second time, and our date from user defaults not equal to received - we will check - this entry was written in core
            // data, or no. When we find existing entry in core data - we stop parsing.
            if let lastBuildDate = NSUserDefaults.standardUserDefaults().objectForKey("LAST_BUILD_DATE") as? String {
                if lastBuildDate == self.string {
                    parser.abortParsing()
                    NSNotificationCenter.defaultCenter().postNotificationName("UPDATE", object: nil)
                } else {
                    NSUserDefaults.standardUserDefaults().setObject(self.string, forKey: "LAST_BUILD_DATE")
                    self.needCheckToExestingObject = true
                }
            } else {
                NSUserDefaults.standardUserDefaults().setObject(self.string, forKey: "LAST_BUILD_DATE")
            }
        default:
            break
        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        self.appDelegate.saveContext()
        
        NSNotificationCenter.defaultCenter().postNotificationName("UPDATE", object: nil)
    }

    
    
    
    
    
    func getAllItems() -> [Item]? {
        let fetchRequest = NSFetchRequest(entityName: "Item")
        
        do {
            let fetchedItems = try self.appDelegate.managedObjectContext.executeFetchRequest(fetchRequest) as? [Item]
            return fetchedItems
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    func objectWithTitleExist(title: String) -> Bool {
        let fetchRequest = NSFetchRequest(entityName: "Item")
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)

        do {
            let fetchedItems = try self.appDelegate.managedObjectContext.executeFetchRequest(fetchRequest) as? [Item]

            if fetchedItems?.count != 0 {
                return true
            } else {
                return false
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
            return false
        }
    }
    
    
    // Utils
    
    func dateFromString(dateString: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EE, d LLLL yyyy HH:mm:ss 'PST'"
        
        if let date = dateFormatter.dateFromString(dateString) {
            return date
        } else {
            dateFormatter.dateFormat = "EE, d LLLL yyyy HH:mm:ss 'PDT'"
            return dateFormatter.dateFromString(dateString)!
        }
    }
}












