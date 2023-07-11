//
//  Item.swift
//  DoneHub
//
//  Created by ismail harmanda on 12.07.2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation

class Item {
    var title : String
    var isDone : Bool
    
    init(title: String, isDone: Bool = false) {
        self.title = title
        self.isDone = isDone
    }
}
