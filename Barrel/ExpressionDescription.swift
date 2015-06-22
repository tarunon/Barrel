//
//  ExpressionDescription.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/02.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData

internal typealias ExpressionDescriptionBuilder = () -> NSExpressionDescription

internal struct ExpressionDescription<T: NSManagedObject>: Builder {
    internal let builder: ExpressionDescriptionBuilder
    
    internal init<V>(argument: Expression<V>) {
        builder = { () -> NSExpressionDescription in
            let expressionDescription = NSExpressionDescription()
            expressionDescription.expression = argument.expression()
            expressionDescription.name = argument.name()
            expressionDescription.expressionResultType = NSAttributeType(type: V.self)
            return expressionDescription
        }
    }

    internal func expressionDescription() -> NSExpressionDescription {
        return builder()
    }
}
