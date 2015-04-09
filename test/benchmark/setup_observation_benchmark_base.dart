// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library observe.test.benchmark.setup_observation_benchmark_base;

import 'dart:async';
import 'dart:html';
import 'package:observe/observe.dart';
import 'package:benchmark_harness/benchmark_harness.dart';

abstract class SetupObservationBenchmarkBase extends BenchmarkBase {
  /// The number of objects to create and observe.
  final int objectCount;

  /// The current configuration.
  final String config;

  /// The objects we want to observe.
  List<Observable> objects;

  SetupObservationBenchmarkBase(String name, this.objectCount, this.config)
      : super(name);

  /// Subclasses should use this method to return an observable object to be
  /// benchmarked.
  Observable newObject();

  /// Subclasses should override this to do anything other than a default change
  /// listener. It must return either a StreamSubscription or a PathObserver.
  newObserver(obj) => obj.changes.listen((_) {});

  /// Set up each benchmark by creating all the objects.
  @override
  void setup() {
    objects = [];
    while (objects.length < objectCount) {
      objects.add(newObject());
    }
  }

  /// Tear down each the benchmark and remove all listeners.
  @override
  void teardown() {
    while (objects.isNotEmpty) {
      var obj = objects.removeLast();
      if (obj.hasObservers || (obj is ObservableList && obj.hasListObservers)) {
        window.alert('Observers leaked!');
      }
    }
    objects = null;
  }

  /// Run the benchmark by creating a listener on each object.
  @override
  void run() {
    for (var object in objects) {
      var observer = newObserver(object);

      // **Note:** This is different than the JS implementation. Since run can
      // be called an arbitrary number of times between [setup] and [teardown],
      // we clean up all observers as we go. This means we are measuring both
      // the setup and teardown of observers, versus the setup only in the
      // JS benchmark. Not cleaning these up ends up giving `oh snap` errors.
      if (observer is StreamSubscription) {
        observer.cancel();
      } else if (observer is PathObserver) {
        observer.close();
      } else {
        throw 'Unknown observer type ${observer.runtimeType}. Only '
            '[PathObserver] and [StreamSubscription] are supported.';
      }
    }
  }
}
