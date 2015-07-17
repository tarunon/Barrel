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
        self.builder = { builder.build() }
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
