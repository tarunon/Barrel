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
extension AttributeType where FieldType == Person {
    var name: Attribute<String> { return storedAttribute(__FUNCTION__, self) }
    var age: Attribute<Int> { return storedAttribute(__FUNCTION__, self) }
}
```

## Extension of RealmCollectionType

If you use Barrel's function, use brl_* methods instead of common methods.
```swfit
var searchPersons = Person.objects(self.context)
                        .brl_filter { $0.name.beginsWith("A") }
                        .brl_sorted { $0.age < $1.age }
```