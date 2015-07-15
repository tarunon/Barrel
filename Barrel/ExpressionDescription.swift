//
//  ExpressionDescription.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/02.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData

internal struct ExpressionDescription<T: NSManagedObject> {
    internal let builder: Builder<NSExpressionDescription>
    
    internal init<V>(argument: Expression<V>) {
        builder = Builder { () -> NSExpressionDescription in
            let expressionDescription = NSExpressionDescription()
            expressionDescription.expression = argument.expression()
            expressionDescription.name = argument.name()
            expressionDescription.expressionResultType = NSAttributeType(type: V.self)
            return expressionDescription
        }
    }

    internal func expressionDescription() -> NSExpressionDescription {
        return builder.build()
    }
}
