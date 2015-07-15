//
//  Builder.swift
//  Barrel
//
//  Created by Nobuo Saito on 2015/06/01.
//  Copyright (c) 2015 tarunon. All rights reserved.
//

import Foundation

struct Builder<T> {
    var builder: () -> T
    
    init(_ result: T) {
        builder = { result }
    }
    
    init(_ builder: () -> T) {
        self.builder = builder
    }
    
    func build() -> T {
        return builder()
    }
    
    func map<U>(transfer: T -> U) -> Builder<U> {
        return Builder<U> { transfer(self.build()) }
    }
    
    func flatMap<U>(transfer: T -> Builder<U>) -> Builder<U> {
        return Builder<U> { transfer(self.build()).build() }
    }
}
