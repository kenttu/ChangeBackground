//
//  MostRecentArray.swift
//  ChangeBackground
//
//  Created by Kent Tu on 4/8/24.
//

import Foundation

// Keeps only the most recent max number of elements
struct MostRecentArray<T> {
    private(set) var storage: [T] = []
    public var maxSize: Int
    init(maxSize: Int = 10) {
        self.maxSize = maxSize
    }
    
    mutating func add(_ newElement: T) {
        if storage.count == maxSize {
            storage.removeFirst()
        }
        storage.append(newElement)
    }
    
    mutating func remove() {
        guard storage.isEmpty == false else {
            return
        }
        storage.removeLast()
    }
    
    func last() -> T? {
        return storage.last
    }
    
    func count() -> Int {
        return storage.count
    }
}
