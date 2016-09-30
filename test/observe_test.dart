// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:logging/logging.dart';
import 'package:observable/observable.dart';
import 'package:observe/observe.dart';
import 'package:observe/src/dirty_check.dart' as dirty_check;
import 'observe_test_utils.dart';

import 'package:observe/mirrors_used.dart' as mu; // make test smaller.
import 'package:smoke/mirrors.dart';

/// Uses [mu].
main() {
  useMirrors();
  _tests();
}

void _tests() {
  // Note: to test the basic AutoObservable system, we use ObservableBox due to its
  // simplicity. We also test a variant that is based on dirty-checking.

  test('no observers at the start', () {
    expect(dirty_check.allObservablesCount, 0);
  });

  group('WatcherModel', () => _observeTests(true, (x) => new WatcherModel(x)));

  group(
      'ObservableBox', () => _observeTests(false, (x) => new ObservableBox(x)));

  group(
      'ModelSubclass', () => _observeTests(true, (x) => new ModelSubclass(x)));

  group('dirtyCheck loops can be debugged', () {
    var messages;
    var subscription;
    setUp(() {
      messages = [];
      subscription = Logger.root.onRecord.listen((record) {
        messages.add(record.message);
      });
    });

    tearDown(() {
      subscription.cancel();
    });

    test('logs debug information', () {
      var maxNumIterations = dirty_check.MAX_DIRTY_CHECK_CYCLES;

      var x = new WatcherModel(0);
      int called = 0;
      var sub = x.changes.listen((_) {
        called++;
        x.value++;
      });
      x.value = 1;
      AutoObservable.dirtyCheck();
      expect(called, maxNumIterations);
      expect(x.value, maxNumIterations + 1);
      expect(messages.length, 2);

      expect(messages[0], contains('Possible loop'));
      expect(messages[1], contains('index 0'));
      expect(messages[1], contains('object: $x'));

      sub.cancel();
    });
  });
}

void _observeTests(final bool watch, createModel(x)) {
  // Track the subscriptions so we can clean them up in tearDown.
  List subs;

  int initialObservers;
  setUp(() {
    initialObservers = dirty_check.allObservablesCount;
    subs = [];

    if (watch) scheduleMicrotask(AutoObservable.dirtyCheck);
  });

  tearDown(() {
    for (var sub in subs) sub.cancel();
    return new Future(() {
      expect(dirty_check.allObservablesCount, initialObservers,
          reason: 'AutoObservable object leaked');
    });
  });

  test('handle future result', () {
    var callback = expectAsync(() {});
    return new Future(callback);
  });

  test('no observers', () {
    var t = createModel(123);
    expect(t.value, 123);
    t.value = 42;
    expect(t.value, 42);
    expect(t.hasObservers, false);
  });

  test('listen adds an observer', () {
    var t = createModel(123);
    expect(t.hasObservers, false);

    subs.add(t.changes.listen((n) {}));
    expect(t.hasObservers, true);
  });

  test('changes delived async', () {
    var t = createModel(123);
    int called = 0;

    subs.add(t.changes.listen(expectAsync((records) {
      called++;
      expectPropertyChanges(records, watch ? 1 : 2);
    })));

    t.value = 41;
    t.value = 42;
    expect(called, 0);
  });

  test('cause changes in handler', () {
    var t = createModel(123);
    int called = 0;

    subs.add(t.changes.listen(expectAsync((records) {
      called++;
      expectPropertyChanges(records, 1);
      if (called == 1) {
        // Cause another change
        t.value = 777;
      }
    }, count: 2)));

    t.value = 42;
  });

  test('multiple observers', () {
    var t = createModel(123);

    verifyRecords(records) {
      expectPropertyChanges(records, watch ? 1 : 2);
    }

    subs.add(t.changes.listen(expectAsync(verifyRecords)));
    subs.add(t.changes.listen(expectAsync(verifyRecords)));

    t.value = 41;
    t.value = 42;
  });

  test('async processing model', () {
    var t = createModel(123);
    var records = [];
    subs.add(t.changes.listen((r) {
      records.addAll(r);
    }));
    t.value = 41;
    t.value = 42;
    expectChanges(records, [], reason: 'changes delived async');

    return new Future(() {
      expectPropertyChanges(records, watch ? 1 : 2);
      records.clear();

      t.value = 777;
      expectChanges(records, [], reason: 'changes delived async');
    }).then(newMicrotask).then((_) {
      expectPropertyChanges(records, 1);

      // Has no effect if there are no changes
      AutoObservable.dirtyCheck();
      expectPropertyChanges(records, 1);
    });
  });

  test('cancel listening', () {
    var t = createModel(123);
    var sub;
    sub = t.changes.listen(expectAsync((records) {
      expectPropertyChanges(records, 1);
      sub.cancel();
      t.value = 777;
      scheduleMicrotask(AutoObservable.dirtyCheck);
    }));
    t.value = 42;
  });

  test('cancel and reobserve', () {
    var t = createModel(123);
    var sub;
    sub = t.changes.listen(expectAsync((records) {
      expectPropertyChanges(records, 1);
      sub.cancel();

      scheduleMicrotask(() {
        subs.add(t.changes.listen(expectAsync((records) {
          expectPropertyChanges(records, 1);
        })));
        t.value = 777;
        scheduleMicrotask(AutoObservable.dirtyCheck);
      });
    }));
    t.value = 42;
  });

  test('cannot modify changes list', () {
    var t = createModel(123);
    var records = null;
    subs.add(t.changes.listen((r) {
      records = r;
    }));
    t.value = 42;

    return new Future(() {
      expectPropertyChanges(records, 1);

      // Verify that mutation operations on the list fail:

      expect(() {
        records[0] = new PropertyChangeRecord(t, #value, 0, 1);
      }, throwsUnsupportedError);

      expect(() {
        records.clear();
      }, throwsUnsupportedError);

      expect(() {
        records.length = 0;
      }, throwsUnsupportedError);
    });
  });

  test('notifyChange', () {
    var t = createModel(123);
    var records = [];
    subs.add(t.changes.listen((r) {
      records.addAll(r);
    }));
    t.notifyChange(new PropertyChangeRecord(t, #value, 123, 42));

    return new Future(() {
      expectPropertyChanges(records, 1);
      expect(t.value, 123, reason: 'value did not actually change.');
    });
  });

  test('notifyPropertyChange', () {
    var t = createModel(123);
    var records = null;
    subs.add(t.changes.listen((r) {
      records = r;
    }));
    expect(t.notifyPropertyChange(#value, t.value, 42), 42,
        reason: 'notifyPropertyChange returns newValue');

    return new Future(() {
      expectPropertyChanges(records, 1);
      expect(t.value, 123, reason: 'value did not actually change.');
    });
  });
}

expectPropertyChanges(records, int number) {
  expect(records.length, number, reason: 'expected $number change records');
  for (var record in records) {
    expect(record is PropertyChangeRecord, true,
        reason: 'record should be PropertyChangeRecord');
    expect((record as PropertyChangeRecord).name, #value,
        reason: 'record should indicate a change to the "value" property');
  }
}

// A test model based on dirty checking.
class WatcherModel<T> extends AutoObservable {
  @observable
  T value;

  WatcherModel([T initialValue]) : value = initialValue;

  String toString() => '#<$runtimeType value: $value>';
}

class ModelSubclass<T> extends WatcherModel<T> {
  ModelSubclass([T initialValue]) : super(initialValue);
}
