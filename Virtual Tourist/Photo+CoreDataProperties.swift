//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Ashutosh Kumar Sai on 31/12/16.
//  Copyright © 2016 Ashish Rajendra Kumar Sai. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var data: NSData?
    @NSManaged public var url: String?
    @NSManaged public var pin: Pin?

}
