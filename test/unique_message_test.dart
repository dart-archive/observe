// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Tests for some of the utility helper functions used by the compiler.
library polymer.test.build.messages_test;

import 'dart:mirrors';

import 'package:unittest/unittest.dart';
import 'package:code_transformers/messages/messages.dart' show Message;

import 'package:observe/src/messages.dart' as p1;

/// [p1] is accessed via mirrors, this comment prevents the analyzer from
/// complaining about it.
main() {
  test('each message id is unique', () {
    var seen = {};
    int total = 0;
    var mirrors = currentMirrorSystem();
    var lib = mirrors.findLibrary(#observe.src.messages);
    expect(lib, isNotNull);
    lib.declarations.forEach((symbol, decl) {
      if (decl is! VariableMirror) return;
      var field = lib.getField(symbol).reflectee;
      var name = MirrorSystem.getName(symbol);
      if (field is! Message) return;
      var id = field.id;
      expect(seen.containsKey(id), isFalse, reason: 'Duplicate id `$id`. '
          'Currently set for both `$name` and `${seen[id]}`.');
      seen[id] = name;
      total++;
    });
    expect(seen.length, total);
  });
}
