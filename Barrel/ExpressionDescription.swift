//
//  ExpressionDescription.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/02.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation
import CoreData

private enum FunctionType {
    case Max
    case Min
    case Count
    case Sum
    case Average
    
    private func function() -> String {
        switch self {
        case .Max:
            return "max"
        case .Min:
            return "min"
        case .Count:
            return "count"
        case .Sum:
            return "sum"
        case .Average:
            return "average"
        }
    }
}

internal typealias ExpressionDescriptionBuilder = () -> NSExpressionDescription

public struct ExpressionDescription<T: NSManagedObject>: Builder {
    private let context: NSManagedObjectContext
    internal let builder: ExpressionDescriptionBuilder
    internal init(context: NSManagedObjectContext) {
        self.context = context
        builder = { () -> NSExpressionDescription in
            let expressionDescription = NSExpressionDescription()
            return expressionDescription
        }
    }
    private init(context: NSManagedObjectContext, description: ExpressionDescriptionBuilder) {
        self.context = context
        self.builder = description
    }
    
    public func expressionDescription() -> NSExpressionDescription {
        return builder()
    }
}

extension ExpressionDescription {
    private func _function<U>(type: FunctionType, argument: Expression<U>) -> ExpressionDescriptionBuilder {
        return builder >>> { (expressionDescription: NSExpressionDescription) -> NSExpressionDescription in
            let argument = argument.expression()
            let entityDescription = self.context.entityDescription(T)!
            expressionDescription.expression = NSExpression(forFunction: type.function() + ":", arguments: [argument])
            expressionDescription.name = type.function() + argument.keyPath.capitalizedString
            expressionDescription.expressionResultType = NSAttributeType(entityDescription: entityDescription, keyPath: argument.keyPath)
            return expressionDescription
        }
    }
    
    internal func keyPath<U>(argument: Expression<U>) -> ExpressionDescription {
        return ExpressionDescription(context: context, description: builder >>> { (expressionDescription: NSExpressionDescription) -> NSExpressionDescription in
            let argument = argument.expression()
            let entityDescription = self.context.entityDescription(T)!
            expressionDescription.expression = argument
            expressionDescription.name = argument.keyPath
            expressionDescription.expressionResultType = NSAttributeType(entityDescription: entityDescription, keyPath: argument.keyPath)
            return expressionDescription
            })
    }
    
    public func max<U>(argument: Expression<U>) -> ExpressionDescription {
        return ExpressionDescription(context: context, description: _function(.Max, argument: argument))
    }
    
    public func min<U>(argument: Expression<U>) -> ExpressionDescription {
        return ExpressionDescription(context: context, description: _function(.Min, argument: argument))
    }
    
    public func count<U>(argument: Expression<U>) -> ExpressionDescription {
        return ExpressionDescription(context: context, description: _function(.Count, argument: argument))
    }
    
    public func sum<U>(argument: Expression<U>) -> ExpressionDescription {
        return ExpressionDescription(context: context, description: _function(.Sum, argument: argument))
    }
    
    public func average<U>(argument: Expression<U>) -> ExpressionDescription {
        return ExpressionDescription(context: context, description: _function(.Average, argument: argument))
    }
    
    public func max<U>(keyPath: U) -> ExpressionDescription {
        return ExpressionDescription(context: context, description: _function(.Max, argument: Expression(value: keyPath)))
    }
    
    public func min<U>(keyPath: U) -> ExpressionDescription {
        return ExpressionDescription(context: context, description: _function(.Min, argument: Expression(value: keyPath)))
    }
    
    public func count<U>(keyPath: U) -> ExpressionDescription {
        return ExpressionDescription(context: context, description: _function(.Count, argument: Expression(value: keyPath)))
    }
    
    public func sum<U>(keyPath: U) -> ExpressionDescription {
        return ExpressionDescription(context: context, description: _function(.Sum, argument: Expression(value: keyPath)))
    }
    
    public func average<U>(keyPath: U) -> ExpressionDescription {
        return ExpressionDescription(context: context, description: _function(.Average, argument: Expression(value: keyPath)))
    }
}
