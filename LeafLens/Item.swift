//
//  Item.swift
//  LeafLens
//
//  Created by Meranga Shyamika on 2026-10-13.
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
