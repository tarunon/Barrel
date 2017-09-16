# Barrel
[![Build Status](https://travis-ci.org/tarunon/Illuso.svg?branch=master)](https://travis-ci.org/tarunon/Barrel)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

A simple type-safe library for NSPredicate and NSExpresion.

##Installation

You can use Carthage to install Barrel by adding it to your Cartfile:

```ogdl
github "tarunon/Barrel"
```

##Summary

Extend your class/struct A and AttributeType like.
```swift
struct A: SelfExpression {
    var text: String
    var number: Int
    var option: String?
}

extension AttributeType where ValueType: A {
    var text: Attribute<String> { return attribute() }
    var number: Attribute<Int> { return attribute() }
    var option: Attribute<Optional<String>> { return attribute() }
}
```

Make NSPredicate and NSExpression from Attribute<A>.
```swift
var attribute = Attribute<A>()
var predicate = attribute.text == "TEXT" // predicate.value is NSPredicate
var expression = attribute.number.max() // expression.value is NSExpression
```

## Attribute

Extend AttributeType using computed property one by one ValueType.
Computed properties are Attribute<T> and return "attribute()".

## Expression

Make Expression by AttributeType.
If AttributeType's ValueType like Number, you can use max, min, sum, average, or +, -, /, * with other Attribute or Number.
Make kyepath expression using unwrapExpression.
```swift
var maxExpression = attribute.number.max()
var plus1Expression = attribute.number + 1
var keyPathExpression = unwrapExpression(attribute.text)
```

## Predicate

Make Predicate by AttributeType
Support operand (==, !=, <, <=, >=, >, <<)
Operand "<<" means in array or between range.
If AttributeType's ValueType is String, you can use contains, beginsWith, endsWith, maches method.
If AttributeType's ValueType like many-relationships, you can use any, all method by make struct extend ManyType.
```swift
var equalToPredicate = attribute.text == "TEST"
var containsPredicate = attribute.text.contains("A")

struct Many<T: ExpressionType>: ManyType {
    typealias ValueType = [T]
    typealias ElementType = T
}

extension AttributeType where ValueType == A {
    var array: Attribute<Many<A>> { return attribute() }
}

var anyPredicate = attribute.array.any { $0.number > 0 }
```

## SortDescriptors

Make SortDescriptors by AttributeType
```swift
var ascending = attribute.number < attribute.number
```

## Support Types
Barrel Support types listed
String, Int, Double, Float, Bool, Int16, Int32, Int64, Array, Dictionary, Set, NSDate, NSData, NSNumber
If you needs support more type, plese implement SelfExpression.
```swift
extension Type: SelfExpression {}
```

## Class support
We cannot an associatedtype conform to Self in class after Swift 3.1.
ExpressionWrapper is workaround that instead of conform to Self.
Write `*` before use class value in query.
```swift
var predicate = attribute.someClassField == *classValue
```
And define attribute value surround ExpressionWrapper.
```swift
extension AttributeType where ValueType: SomeClass {
  var someClassField: Attribute<ExpressionWrapper<SomeFieldClass>> { return attribute() }
}
```

## for Swift3.x
[Version 4.0.1](https://github.com/tarunon/Barrel/releases/tag/4.0.1) supports Swift3.

## LISENSE
MIT
