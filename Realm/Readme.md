Barrel_Realm
=================

Barrel's Extension in Realm

## Feature
Type-safe fetch and insert.
```swift
var person = Person.insert(self.realm)
var results = Person.objects(self.realm)
```

Plese write AttributeType extensions.
```swift
extension AttributeType where ValueType: Person {
    var name: Attribute<String> { return storedAttribute(parent: self) }
    var age: Attribute<Int> { return storedAttribute(parent: self) }
}
```

## Extension of RealmCollectionType

If you use Barrel's function, use brl_* methods instead of common methods.
```swfit
var searchPersons = Person.objects(self.context)
                        .brl_filter { $0.name.beginsWith("A") }
                        .brl_sorted { $0.age < $1.age }
```

## Relationships
Your model has many-relationships, use Many type in Attribute like.
```swift
extension AttributeType where ValueType: Planet {
    var name: Attribute<String> { return storedAttribute(parent: self) }
    var children: Attribute<Many<Satellite>> { return storedAttribute(parent: self) }
}
