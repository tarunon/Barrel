//
//  Builder.swift
//  BarrelCoreData
//
//  Created by Nobuo Saito on 2015/11/09.
//  Copyright © 2015年 tarunon. All rights reserved.
//

import Foundation

protocol BuilderType {
    associatedtype Result
    func build() -> Result
}

struct Builder<T>: BuilderType {
    var builder: () -> T
    
    init(_ result: @autoclosure @escaping () -> T) {
        builder = result
    }

    init(_ builder: @escaping () -> T) {
        self.builder = builder
    }

    init<B: BuilderType>(_ builder: B) where B.Result == T {
        self.builder = builder.build
    }

    func build() -> T {
        return builder()
    }

    func map<U>(_ f: @escaping (T) -> U) -> Builder<U> {
        return Builder<U>(f(self.build()))
    }
    
    func flatMap<B: BuilderType, U>(_ f: (T) -> B) -> Builder<U> where B.Result == U {
        return Builder<U>(f(self.build()))
    }
}

//infix operator </> { associativity left precedence 170 }
//infix operator <*> { associativity left precedence 150 }
//
//func </> <T, U>(lhs: (T) -> U, rhs: Builder<T>) -> Builder<U> {
//    return rhs.map(lhs)
//}
//
//func <*> <T, U>(lhs: Builder<(T) -> U>, rhs: Builder<T>) -> Builder<U> {
//    return lhs.flatMap { (f: (T) -> U) -> Builder<U> in
//        rhs.map { f($0) }
//    }
//}
