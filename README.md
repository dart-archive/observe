# observe

Support for marking objects as observable, and getting notifications when those
objects are mutated.

**Warning:** This library is experimental, and APIs are subject to change.

This library is used to observe changes to [Observable][] types. It also
has helpers to make implementing and using [Observable][] objects easy.

You can provide an observable object in two ways. The simplest way is to
use dirty checking to discover changes automatically:

```dart
import 'package:observe/standalone.dart';

class Monster extends Unit with Observable {
  @observable int health = 100;

  void damage(int amount) {
    print('$this takes $amount damage!');
    health -= amount;
  }

  toString() => 'Monster with $health hit points';
}

main() {
  var obj = new Monster();
  obj.changes.listen((records) {
    print('Changes to $obj were: $records');
  });
  // No changes are delivered until we check for them
  obj.damage(10);
  obj.damage(20);
  print('dirty checking!');
  Observable.dirtyCheck();
  print('done!');
}
```

A more sophisticated approach is to implement the change notification
manually. This avoids the potentially expensive [Observable.dirtyCheck][]
operation, but requires more work in the object:

```dart
import 'package:observe/standalone.dart';

class Monster extends Unit with ChangeNotifier {
  int _health = 100;
  @reflectable get health => _health;
  @reflectable set health(val) {
    _health = notifyPropertyChange("health", _health, val);
  }

  void damage(int amount) {
    print('$this takes $amount damage!');
    health -= amount;
  }

  toString() => 'Monster with $health hit points';
}

main() {
  var obj = new Monster();
  obj.changes.listen((records) {
    print('Changes to $obj were: $records');
  });
  // Schedules asynchronous delivery of these changes
  obj.damage(10);
  obj.damage(20);
  print('done!');
}
```

A transformer is provided by this package to pass from the first form to the second.

### on mirror systems

This package will use a mirror system implemented over [reflectable] to inspect object properties and read their values. 
A default mirror system can be obtained by importing `observable/standalone.dart`.

The default mirror system can be replaced by another one by exporting via use of `MetaScopeReflectable`.

For example to use `polymer-dart` mirror system and avoid duplication of metadata just put this lines on a separate file:
 ```dart

 library observe.polymer.bridge;
 
 import "package:polymer/src/common/js_proxy.dart" show jsProxyReflectable;
 import 'package:observe/src/metadata.dart';
 export "package:observe/observe.dart";
 import "package:polymer/src/common/reflectable.dart";
 
 
 Map<String, Iterable<Reflectable>> scopeMap = <String, Iterable<Reflectable>>{
   "observe": <Reflectable>[jsProxyReflectable]
 };
 
 @ScopeMetaReflector()
 Iterable<Reflectable> reflectablesOfScope(String scope) => scopeMap[scope];

 
 ```
then import this file instead of `observe/standalone.dart`.

**Note: properties still have to be annotated by `@reflectable` for `polymer-dart` mirror system and with `@observable` for the `observe` transformer
to implement the change notifier but only one mirror system will be used.

[Observable]: http://www.dartdocs.org/documentation/observe/latest/index.html#observe/observe.Observable
[Observable.dirtyCheck]: http://www.dartdocs.org/documentation/observe/latest/index.html#observe/observe.Observable@id_dirtyCheck
[reflectable]: http://github.com/dart-lang/reflectable