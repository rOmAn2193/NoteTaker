//
//  Note.swift
//  NoteTaker
//
//  Created by Roman on 12/15/15.
//  Copyright © 2015 Roman Puzey. All rights reserved.
//

import Foundation
import CoreData


class Note: NSManagedObject {

    @NSManaged var url: String
    @NSManaged var name: String

}
