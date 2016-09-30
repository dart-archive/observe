// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library observe.test.benchmark.test_observable;

import 'package:observe/observe.dart';

class Bar extends AutoObservable {
  @observable
  int baz;

  Bar(this.baz);
}

class Foo extends AutoObservable {
  @observable
  Bar bar;

  Foo(int value) : bar = new Bar(value);
}

class TestPathObservable extends AutoObservable {
  @observable
  Foo foo;

  TestPathObservable(int value) : foo = new Foo(value);
}
