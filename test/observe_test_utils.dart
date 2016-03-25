// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library observe.test.observe_test_utils;

import 'dart:async';
import 'package:observe/observe.dart';
import 'package:observe/mirrors_used.dart' as mu; // to make tests smaller
import 'package:observe/src/dirty_check.dart';
import 'package:test/test.dart' hide test, group, setUp, tearDown;
import 'package:test/test.dart' as original_test
    show test, group, setUp, tearDown;

export 'package:observe/src/dirty_check.dart' show dirtyCheckZone;
export 'package:test/test.dart' hide test, group, setUp, tearDown;

/// Custom implementations of the functions from `package:test`. These ensure
/// that the body of all test function are run in the dirty checking zone.
test(String description, body()) => original_test.test(
    description, () => dirtyCheckZone().bindCallback(body)());

group(String description, body()) => original_test.group(
    description, () => dirtyCheckZone().bindCallback(body)());

setUp(body()) =>
    original_test.setUp(() => dirtyCheckZone().bindCallback(body)());

tearDown(body()) =>
    original_test.tearDown(() => dirtyCheckZone().bindCallback(body)());

/// A small method to help readability. Used to cause the next "then" in a chain
/// to happen in the next microtask:
///
///     future.then(newMicrotask).then(...)
///
/// Uses [mu].
newMicrotask(_) => new Future.value();

// TODO(jmesserly): use matchers when we have a way to compare ChangeRecords.
// For now just use the toString.
expectChanges(actual, expected, {reason}) =>
    expect('$actual', '$expected', reason: reason);

List<ListChangeRecord> getListChangeRecords(List changes, int index) =>
    new List.from(changes.where((c) => c.indexChanged(index)));

List<PropertyChangeRecord> getPropertyChangeRecords(
        List changes, Symbol property) =>
    new List.from(
        changes.where((c) => c is PropertyChangeRecord && c.name == property));
