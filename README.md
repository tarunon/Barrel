Barrel
=================

A simple type-safe CoreData library for Swift.

##Pod
```ruby
pod 'Barrel', :git => 'https://github.com/tarunon/Barrel.git'
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
  return context.fetch().filter{ $0.age == age }.orderBy{ $0.name < $1.name }.execute().all()
}

func createPerson(name: String, age: Int) -> Person {
  return context.insert().setValues{
    $0.name = name
    $0.age = age
    }.insert()
}
```
