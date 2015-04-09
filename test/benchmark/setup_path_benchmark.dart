// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library observe.test.benchmark.setup_path_benchmark;

import 'package:observe/observe.dart';
import 'setup_observation_benchmark_base.dart';
import 'test_path_observable.dart';

class SetupPathBenchmark extends SetupObservationBenchmarkBase {
  final PropertyPath path = new PropertyPath('foo.bar.baz');

  SetupPathBenchmark(int objectCount, String config)
      : super('SetupPathBenchmark:$objectCount:$config', objectCount, config);

  @override
  TestPathObservable newObject() => new TestPathObservable(1);

  @override
  PathObserver newObserver(TestPathObservable obj) =>
      new PathObserver(obj, path)..open(() {});
}
