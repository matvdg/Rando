//
//  Array.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 31/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import Surge

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

struct CircularBuffer {
    
    var size: Int
    var values = [Double]()
    var average: Double { mean(values) }
    
    init(size: Int) {
        self.size = size
    }
    
    mutating func append(_ value: Double) {
        values.append(value)
        if values.count > size {
            values.removeFirst()
        }
    }
}
