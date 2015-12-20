//
//  Item+CoreDataProperties.swift
//  RSSFeed
//
//  Created by Yakov Shkolnikov on 12/20/15.
//  Copyright © 2015 junor. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Item {

    @NSManaged var title: String?
    @NSManaged var descr: String?
    @NSManaged var image: NSObject?
    @NSManaged var pubDate: NSDate?
    @NSManaged var time: String?

}
