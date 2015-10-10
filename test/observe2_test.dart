// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:logging/logging.dart';
import 'package:observe/observe.dart';
import 'package:observe/src/dirty_check.dart' as dirty_check;
import 'package:test/test.dart';
import 'observe_test_utils.dart';
import "package:reflectable/reflectable.dart";
main() {
  _tests();
}

class MyModel extends Observable {
  @observable String field1;

  MyModel(this.field1);
}

class FakeMixin {

}

class MyModel2 extends Object with Observable,FakeMixin {
  @observable String field1;

  MyModel2(this.field1);
}

void _tests() {
  // Note: to test the basic Observable system, we use ObservableBox due to its
  // simplicity. We also test a variant that is based on dirty-checking.

  group("basic tests",(){
    test("reflect works",() {
      MyModel m = new MyModel("uno");
      InstanceMirror im =observableObject.reflect(m);
      expect(im.type.simpleName,"MyModel");
      expect(im.type.declarations,contains("field1"));
      expect(im.invokeGetter("field1"),"uno");
    });


    test("reflect works again",() {
      MyModel2 m = new MyModel2("uno");
      InstanceMirror im =observableObject.reflect(m);
      expect(im.type.simpleName,"MyModel2");
      expect(im.type.declarations,contains("field1"));
      expect(im.invokeGetter("field1"),"uno");
    });
    
    test("change field",() async {
      MyModel m = new MyModel("ciao");

      Completer completer = new Completer();
      m.changes.listen((List<ChangeRecord> records) {
        completer.complete(true);
      });

      m.field1 = "pippo";
      expect(completer.future,completion(isTrue));
    });

    test("change field 2",() async {
      MyModel2 m = new MyModel2("ciao");

      Completer completer = new Completer();
      m.changes.listen((List<ChangeRecord> records) {
        completer.complete(true);
      });

      m.field1 = "pippo";
      expect(completer.future,completion(isTrue));
    });
  });

}

