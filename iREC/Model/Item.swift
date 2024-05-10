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
  //var title: String = ""

  init(timestamp: Date/*,title:String*/) {
    self.timestamp = timestamp
    //self.title = title
  }
}
