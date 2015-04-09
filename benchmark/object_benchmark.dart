// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library observe.test.benchmark.object_benchmark;

import 'observation_benchmark_base.dart';
import 'test_observable.dart';

class ObjectBenchmark extends ObservationBenchmarkBase {
  ObjectBenchmark(int objectCount, int mutationCount, String config) : super(
          'ObjectBenchmark:$objectCount:$mutationCount:$config', objectCount,
          mutationCount, config);

  @override
  int mutateObject(TestObservable obj) {
    // Modify the first 5 properties.
    obj.a++;
    obj.b++;
    obj.c++;
    obj.d++;
    obj.e++;
    // Return # of modifications.
    return 5;
  }

  @override
  TestObservable newObject() => new TestObservable();
}
