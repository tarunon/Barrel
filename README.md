Barrel
=================

A simple type-safe CoreData library for Swift.

##Installation
```ruby
platform :ios, "8.0"
use_frameworks!

pod 'Barrel', :git => 'https://github.com/tarunon/Barrel.git' :branch => 'swift2.0'
```

##Summary

Swift is a type-safe programing language and supported type-inference.

Before
```swift
func findPerson(age: Int) -> [Person] {
  let fetchRequest = NSFetchRequest(entityName: "Person")
  fetchRequest.predicate = NSPredicate(format: "age == %i", age)
  fetchRequest.sortDescriptor = [NSSortDescriptor(key: "name", ascending: true)]
  return context.executeFetchRequest(fetchRequest, error: nil) as? [Person] ?? []
}

func createPerson(name: String, age: Int) -> Person {
  let person = NSEntityDescription.insertNewObjectForEntityForName("Person", inManagedObjectContext: context) as! T
  person.name = name
  person.age = age
  return person
}
```

After
```swift
func findPerson(age: Int) -> [Person] {
  return try! context.fetch()
    .filter{ $0.age == age }
    .orderBy{ $0.name < $1.name }
    .all()
}

func createPerson(name: String, age: Int) -> Person {
  return context.insert().setValues{
    $0.name = name
    $0.age = age
    }.insert()
}
```

##Fetch

Barrel provides fetch methods.

###Type-safe
Barrel's fetch method is type-safe.
```swift
let persons = try! context.fetch(Person).all()
```
If the type is defined, fetch's argument can be omitted.
```swift
let persons: [Person] = try! context.fetch().all()
```

###Error handling
Handle error using do-catch syntax.
```swift
do {
  let personsResult = try context.fetch(Person).all()
  // write succeed case
} catch let error as NSError {
  // write failed case 
}

```

###Method chaining
Barrel is defined condition of fetch using method chaining.
```swift
let persons = try! context.fetch(Person)
  .filter(NSPredicate(format: "name == %@", "John"))
  .orderBy(NSSortDescriptor(key: "age", ascending: true))
  .all()
```

###Closure
Barrel can be defined condition of fetch using closure.
```swift
let persons = try! context.fetch(Person)
  .filter{ $0.name == "John" }
  .orderBy{ $0.age < $1.age }
  .all()
```


##Insert

Barrel provides insert methods.
Type-safe and Closure support.

```swift
let person = context.insert(Person).setValues{
  $0.name = "John"
  $0.age = 24
  }.insert()
```

And support getOrInsert method.

```swift
let person = context.insert(Person).setValues{
  $0.name = "John"
  $0.age = 24
  }.getOrInsert()
```


##Others

Barrel has more functions.

###Aggregate and Grouping

Support aggregate method,
```swift
let maxAge = try! context.fetch(Person)
  .aggregate{ $0.max($1.age) }
  .get()!
// maxAge => ["maxAge": XX]
```

and grouping.
```swift
let maxAgePerName = try! context.fetch(Person)
  .aggregate{ $0.max($1.age) }
  .aggregate{ $1.name }
  .groupBy{ $1.name }
  .all()
// maxAgePerName => [["maxAge" : XX, "name": "YY"], ...]
```

###ResultsController
NSFetchResultsController is not also type-safe.
Barrel supports Type-safe ResultsController object.
```swift
let resultsController: ResultsController<Person> = context.fetch(Person)
  .orderBy{ $0.age < $1.age }
  .resultsController(sectionKeyPath: nil, cacheName: nil)
let person = resultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
```
