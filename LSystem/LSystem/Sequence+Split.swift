//
//  Sequence+Split.swift
//  LSystem
//
//  Created by Paweł Wszeborowski on 12/03/2019.
//  Copyright © 2019 Paweł Wszeborowski. All rights reserved.
//

import Foundation

extension Sequence {
    func split(by predicate: @escaping (Element) throws -> Bool) rethrows -> (matching: [Element], notMatching: [Element]) {
        var matching: [Element] = []
        var notMatching: [Element] = []
        try forEach { element in
            if try predicate(element) {
                matching.append(element)
            } else {
                notMatching.append(element)
            }
        }
        return (matching, notMatching)
    }
}
