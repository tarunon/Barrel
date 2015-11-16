Barrel_CoreData
=================

Barrel's Extension in CoreData.

## Feature
Type-safe fetch and insert.
```swift
var person = Person.insert(self.context)
var fetches = Person.objects(self.context)
```

Plese write AttributeType extensions.
```swift
extension AttributeType where FieldType == Person {
    var name: Attribute<String> { return storedAttribute(__FUNCTION__, self) }
    var age: Attribute<Int> { return storedAttribute(__FUNCTION__, self) }
}
```

## Fetch
Fetch is contains NSManagedObjectContext and NSFetchRequest.
Fetch implemented SequenceType, you can use map, filter, and more.
Fetch has method that compiling NSFetchRequest, filter, sorted, limit, offset.
If you use Barrel's functions, use brl_filter, brl_sorted instead of.
```swift
var searchPersons = Person.objects(self.context)
                        .brl_filter { $0.name.beginsWith("A") }
                        .brl_sorted { $0.age < $1.age }
```

## Aggregate
Aggregate by NSExpression, using method aggregate.
If you use Barrel's functions, use brl_aggregate instead of.
Use method groupBy and having, after all field listed by agggregate.
You can use also brl_groupBy, brl_having.
```swift
var maxAge = Person.objects(self.context).brl_aggregate { $0.age.max() }[0]
var maxAgeGroupByName = Person.objects(self.context)
                            .brl_aggregate { $0.age.max() }
                            .brl_aggregate { $0.name }
                            .brl_groupBy { $0.name }
```

## Relationships
Your model has many-relationships, use Many type in Attribute like.
```swift
extension AttributeType where FieldType == Planet {
    var name: Attribute<String> { return storedAttribute(__FUNCTION__, self) }
    var children: Attribute<Many<Satellite>> { return storedAttribute(__FUNCTION__, self) }
}