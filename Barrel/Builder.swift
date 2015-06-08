//
//  Builder.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/01.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData

internal protocol Builder {
    typealias Result
    func build() -> Result
}

infix operator >>> {
    
}

internal func >>><T, U, V>(lhs: (T)->U, rhs: (U)->(V)) -> (T)->V {
    return { rhs(lhs($0)) }
}
