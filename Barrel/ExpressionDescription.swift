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

private typealias ExpressionDescriptionBuilder = () -> NSExpressionDescription

public struct ExpressionDescription<T: NSManagedObject> {
    private let context: NSManagedObjectContext
    private let builder: ExpressionDescriptionBuilder
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
    
    private func _function<U>(type: FunctionType, argument: Expression<U>) -> ExpressionDescriptionBuilder {
        return builder >>> { (expressionDescription: NSExpressionDescription) -> NSExpressionDescription in
            let argument = argument.build()
            let entityDescription = self.context.entityDescription(T)!
            expressionDescription.expression = NSExpression(forFunction: type.function() + ":", arguments: [argument])
            expressionDescription.name = type.function() + argument.keyPath.capitalizedString
            expressionDescription.expressionResultType = NSAttributeType(entityDescription: entityDescription, keyPath: argument.keyPath)
            return expressionDescription
        }
    }
    
    internal func keyPath<U>(argument: Expression<U>) -> ExpressionDescription {
        return ExpressionDescription(context: context, description: builder >>> { (expressionDescription: NSExpressionDescription) -> NSExpressionDescription in
            let argument = argument.build()
            let entityDescription = self.context.entityDescription(T)!
            expressionDescription.expression = argument
            expressionDescription.name = argument.keyPath
            expressionDescription.expressionResultType = NSAttributeType(entityDescription: entityDescription, keyPath: argument.keyPath)
            return expressionDescription
            })
    }
    
    public func max<E: ExpressionType>(argument: E) -> ExpressionDescription {
        return ExpressionDescription(context: context, description: _function(.Max, argument: Expression.createExpression(argument)))
    }
    
    public func min<E: ExpressionType>(argument: E) -> ExpressionDescription {
        return ExpressionDescription(context: context, description: _function(.Min, argument: Expression.createExpression(argument)))
    }
    
    public func count<E: ExpressionType>(argument: E) -> ExpressionDescription {
        return ExpressionDescription(context: context, description: _function(.Count, argument: Expression.createExpression(argument)))
    }
    
    public func sum<E: ExpressionType>(argument: E) -> ExpressionDescription {
        return ExpressionDescription(context: context, description: _function(.Sum, argument: Expression.createExpression(argument)))
    }
    
    public func average<E: ExpressionType>(argument: E) -> ExpressionDescription {
        return ExpressionDescription(context: context, description: _function(.Average, argument: Expression.createExpression(argument)))
    }
}

extension ExpressionDescription: Builder {
    func build() -> NSExpressionDescription {
        return builder()
    }
    
    public func expressionDescription() -> NSExpressionDescription {
        return build()
    }
}