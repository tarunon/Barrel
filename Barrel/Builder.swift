//
//  Builder.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/01.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation

protocol BuilderType {
    typealias Result
    func build() -> Result
}

struct Builder<T>: BuilderType {
    var builder: () -> T
    
    init(@autoclosure(escaping) _ result: () -> T) {
        builder = result
    }
    
    init(_ builder: () -> T) {
        self.builder = builder
    }
    
    init<B: BuilderType where B.Result == T>(_ builder: B) {
        self.builder = builder.build
    }
    
    func build() -> T {
        return builder()
    }
    
    func map<U>(transfer: T -> U) -> Builder<U> {
        return Builder<U>(transfer(self.build()))
    }
    
    func flatMap<U>(transfer: T -> Builder<U>) -> Builder<U> {
        return Builder<U>(transfer(self.build()))
    }
}

infix operator </> { associativity left precedence 170 }
infix operator <*> { associativity left precedence 150 }

func </> <T, U>(lhs: T -> U, rhs: Builder<T>) -> Builder<U> {
    return rhs.map(lhs)
}

func <*> <T, U>(lhs: Builder<T -> U>, rhs: Builder<T>) -> Builder<U> {
    return lhs.flatMap { (f: T -> U) -> Builder<U> in
        rhs.map { f($0) }
    }
}
