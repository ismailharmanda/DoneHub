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
    @Persisted var title: String = ""
    @Persisted var done: Bool = false
    
    var parentCategory = LinkingObjects(fromType: RealmCategory.self , property: "items")
}
