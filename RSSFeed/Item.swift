//
//  Item.swift
//  RSSFeed
//
//  Created by Yakov Shkolnikov on 12/20/15.
//  Copyright © 2015 junor. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class Item: NSManagedObject, NSURLSessionDelegate {

    func getImageByStringUrl(urlString: String) {
        // We don't have image url, but we have url web page where image stored
        let url = NSURL(string: urlString)!
        
        // Download this web page
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
        let getImageTask = session.downloadTaskWithURL(url) { (let url: NSURL?, let response: NSURLResponse?, let error: NSError?) -> Void in
            do {
                let fileContent = try NSString(contentsOfFile: (url?.path)!, encoding: NSUTF8StringEncoding)
                
                // After this tegs in dowloaded page stored image url
                let pathToImage = "<img class=\"article-image center\" src=\""
                var startIndex = fileContent.rangeOfString(pathToImage).location
                
                if startIndex != NSNotFound && startIndex != 0 {
                    startIndex += pathToImage.characters.count
                    
                    let lastStr = fileContent.substringFromIndex(startIndex)
                    let endIndex = lastStr.rangeOfString("\"")?.startIndex
                    
                    let imageUrl = lastStr.substringToIndex(endIndex!)
                    
                    NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: imageUrl)!, completionHandler: { (let data: NSData?, let response: NSURLResponse?, let error: NSError?) -> Void in
                        if data != nil {
                            let image = UIImage(data: data!)
                            self.image = image
                            
                            (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
                        }
                    }).resume()
                }
            } catch {
                
            }
        }
        getImageTask.resume()
    }

}
