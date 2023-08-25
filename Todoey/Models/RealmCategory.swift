//
//  RealmCategory.swift
//  DoneHub
//
//  Created by ismail harmanda on 24.08.2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class RealmCategory: Object {
    @objc dynamic var name: String = ""
    let items = List<RealmItem>()
    
}
