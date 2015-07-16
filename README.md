Barrel
=================

A simple type-safe CoreData library for Swift.

##Installation

### CocoaPods

```ruby
platform :ios, "8.0"
use_frameworks!

pod 'Barrel', :git => 'https://github.com/tarunon/Barrel.git', :branch => 'swift2.0'
```

### Carthage

You can use Carthage to install Barrel by adding it to your Cartfile:

```ogdl
github "tarunon/Barrel"
```

##Summary

Swift is a type-safe programing language and supported type-inference.

Before
```swift
func findPerson(age: Int) -> [Person] {
  let fetchRequest = NSFetchRequest(entityName: "Person")
  fetchRequest.predicate = NSPredicate(format: "age == %i", age)
  fetchRequest.sortDescriptor = [NSSortDescriptor(key: "name", ascending: true)]
  return try! context.executeFetchRequest(fetchRequest) as? [Person] ?? []
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

##Operations

In closure, can use operation evaluation.
###In filter

|Operation|Supported Type|Description|
|---|---|---|
|A == B|AnyObject|A equal to B.<br>If evaluate String, == mean case and diacritic insensitive.<br>Need to rigorous evaluating, use === instead of ==.|
|A != B|AnyObject|A not equal to B.<br>If evaluate String, != mean case and diacritic insensitive.<br>Need to rigorous evaluating, use !== instead of !=.|
|A ~= B|String|A matches B where case and diacritic insensitive.<br>Need to rigorous evaluating, use ~== instead of ~=.|
|A &gt; B|AnyObject|A grater than B.|
|A &gt;= B|AnyObject|A grater than or equal to B.|
|A &lt; B|AnyObject|A less than B.|
|A &lt;= B|AnyObject|A less than or equal to B.|
|A &lt;&lt; [B]|AnyObject|A in array [B].|
|Set&lt;A&gt; &gt;&gt; B|NSManagedObject|Relationship A contains B.|

####Arithmetic operations.
If evaluate NSNumber, can use arithmetic operation.

|Operation|Supported Type|Description|
|---|---|---|
|A + B|NSNumber|Number of add A to B.|
|A - B|NSNumber|Number of subtract B from A.|
|A * B|NSNumber|Number of multiply A by B.|
|A / B|NSNumber|Number of divide A by B.|

###In orderBy

|Operation|Supported Type|Description|
|---|---|---|
|$0.A &lt; $1.A|AnyObject|Order by A ascending.|
|$0.A &gt; $1.A|AnyObject|Order by A descending.|

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
let maxAge = context.fetch(Person)
  .aggregate{ max($0.age) }
  .execute().get()!
// maxAge => ["max_age": XX]
```

and grouping.
```swift
let maxAgePerName = context.fetch(Person)
  .aggregate{ max($0.age) }
  .aggregate{ $0.name }
  .groupBy{ $0.name }
  .execute().all()
// maxAgePerName => [["max_age" : XX, "name": "YY"], ...]
```

In aggregate can use arithmetic operations, and in groupBy can use filter operations.

###Aggregate functions.
|Operation|Supported Type|Description|
|---|---|---|
|A.max()|NSNumber|Number of maximum A.|
|A.min()|NSNumber|Number of minimum A.|
|A.sum()|NSNumber|Number of sum A.|
|A.average()|NSNumber|Number of average A.|
|A.count()|AnyObject|Number of count A.|


###ResultsController
NSFetchResultsController is not also type-safe.
Barrel supports Type-safe ResultsController object.
```swift
let resultsController: ResultsController<Person> = context.fetch(Person)
  .orderBy{ $0.age < $1.age }
  .resultsController(sectionKeyPath: nil, cacheName: nil)
let person = resultsController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
```
