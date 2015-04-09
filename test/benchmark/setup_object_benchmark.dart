// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library observe.test.benchmark.setup_object_benchmark;

import 'setup_observation_benchmark_base.dart';
import 'test_observable.dart';

class SetupObjectBenchmark extends SetupObservationBenchmarkBase {
  SetupObjectBenchmark(int objectCount, String config)
      : super('SetupObjectBenchmark:$objectCount:$config', objectCount, config);

  @override
  TestObservable newObject() => new TestObservable();
}
