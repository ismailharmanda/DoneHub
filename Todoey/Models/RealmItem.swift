//
//  RealmItem.swift
//  DoneHub
//
//  Created by ismail harmanda on 24.08.2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class RealmItem: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    
    @objc dynamic var dateCreated = Date()
    
    
    var parentCategory = LinkingObjects(fromType: RealmCategory.self , property: "items")
}
