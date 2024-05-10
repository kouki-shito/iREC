//
//  Item.swift
//  iREC
//
//  Created by 市東 on 2024/05/11.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
