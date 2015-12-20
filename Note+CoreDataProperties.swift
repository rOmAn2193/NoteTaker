//
//  Note+CoreDataProperties.swift
//  NoteTaker
//
//  Created by Roman on 12/15/15.
//  Copyright © 2015 Roman Puzey. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Note {

    @NSManaged var url: String?
    @NSManaged var name: String?

}
