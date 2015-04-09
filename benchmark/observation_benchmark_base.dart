// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library observe.test.benchmark.observation_benchmark_base;

import 'dart:async';
import 'dart:html';
import 'package:observe/observe.dart';
import 'package:benchmark_harness/benchmark_harness.dart';

abstract class ObservationBenchmarkBase extends BenchmarkBase {
  /// The number of objects to create and observe.
  final int objectCount;

  /// The number of mutations to perform.
  final int mutationCount;

  /// The current configuration.
  final String config;

  /// The number of pending mutations left to observe.
  int mutations;

  /// The objects we want to observe.
  List<Observable> objects;

  /// The change listeners on all of our objects.
  List observers;

  /// The current object being mutated.
  int objectIndex;

  ObservationBenchmarkBase(
      String name, this.objectCount, this.mutationCount, this.config)
      : super(name);

  /// Subclasses should use this method to perform mutations on an object. The
  /// return value indicates how many mutations were performed on the object.
  int mutateObject(obj);

  /// Subclasses should use this method to return an observable object to be
  /// benchmarked.
  Observable newObject();

  /// Subclasses should override this to do anything other than a default change
  /// listener. It must return either a StreamSubscription or a PathObserver.
  /// If overridden this observer should decrement [mutations] each time a
  /// change is observed.
  newObserver(obj) {
    decrement(_) => mutations--;
    if (obj is ObservableList) return obj.listChanges.listen(decrement);
    return obj.changes.listen(decrement);
  }

  /// Set up each benchmark by creating all the objects and listeners.
  @override
  void setup() {
    mutations = 0;

    objects = [];
    observers = [];
    objectIndex = 0;

    while (objects.length < objectCount) {
      var obj = newObject();
      objects.add(obj);
      observers.add(newObserver(obj));
    }
  }

  /// Tear down each benchmark and make sure that [mutations] is 0.
  @override
  void teardown() {
    if (mutations != 0) {
      window.alert('$mutations mutation sets were not observed!');
    }
    mutations = 0;

    while (observers.isNotEmpty) {
      var observer = observers.removeLast();
      if (observer is StreamSubscription) {
        observer.cancel();
      } else if (observer is PathObserver) {
        observer.close();
      } else {
        throw 'Unknown observer type ${observer.runtimeType}. Only '
            '[PathObserver] and [StreamSubscription] are supported.';
      }
    }
    observers = null;

    bool leakedObservers = false;
    while (objects.isNotEmpty) {
      leakedObservers = objects.removeLast().hasObservers || leakedObservers;
    }
    if (leakedObservers) window.alert('Observers leaked!');
    objects = null;
  }

  /// Run the benchmark
  @override
  void run() {
    var mutationsLeft = mutationCount;
    while (mutationsLeft > 0) {
      var obj = objects[objectIndex];
      mutationsLeft -= mutateObject(obj);
      this.mutations++;
      this.objectIndex++;
      if (this.objectIndex == this.objects.length) {
        this.objectIndex = 0;
      }
      obj.deliverChanges();
      if (obj is ObservableList) obj.deliverListChanges();
    }
    Observable.dirtyCheck();
  }
}
