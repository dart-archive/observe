// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library observe.src.metadata;

import "package:reflectable/reflectable.dart";

class ScopeMetaReflector extends Reflectable {
  const ScopeMetaReflector()
  : super(const TopLevelInvokeMetaCapability(ScopeMetaReflector),
  declarationsCapability, libraryCapability);

  Set<Reflectable> reflectablesOfScope(String scope) {
    Set<Reflectable> result = new Set<Reflectable>();
    for (LibraryMirror library in libraries.values) {
      for (DeclarationMirror declaration in library.declarations.values) {
        result.addAll(library.invoke(declaration.simpleName, [scope]));
      }
    }
    return result;
  }
}
/// Mirror system to be used.

final Reflectable observableObject =
  const ScopeMetaReflector().reflectablesOfScope("observe").first;




/// An annotation that is used to make a property observable.
/// Normally this is used via the [observable] constant, for example:
///
///     class Monster extends Observable {
///       @observable int health;
///     }
///
// TODO(sigmund): re-add this to the documentation when it's really true:
//     If needed, you can subclass this to create another annotation that will
//     also be treated as observable.
// Note: observable properties imply reflectable.
class ObservableProperty {
  const ObservableProperty();
}

const ObservableProperty observable = const ObservableProperty();



