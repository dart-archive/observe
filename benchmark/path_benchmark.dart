// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library observe.test.benchmark.path_benchmark;

import 'package:observe/observe.dart';
import 'observation_benchmark_base.dart';
import 'test_path_observable.dart';

class PathBenchmark extends ObservationBenchmarkBase<TestPathObservable> {
  final PropertyPath path = new PropertyPath('foo.bar.baz');

  PathBenchmark(int objectCount, int mutationCount, String config)
      : super('PathBenchmark:$objectCount:$mutationCount:$config', objectCount,
            mutationCount, config);

  @override
  int mutateObject(TestPathObservable obj) {
    switch (config) {
      case 'leaf':
        obj.foo.bar.baz += 1;
        // Make sure [obj.foo.bar] delivers its changes synchronously. The base
        // class already handles this for [obj].
        obj.foo.bar.deliverChanges();
        return 1;

      case 'root':
        obj.foo = new Foo(obj.foo.bar.baz + 1);
        return 1;

      default:
        throw new ArgumentError('Invalid config for PathBenchmark: $config');
    }
  }

  @override
  TestPathObservable newObject() => new TestPathObservable(1);

  @override
  PathObserver newObserver(TestPathObservable obj) =>
      new PathObserver(obj, path)..open((_) => mutations--);
}
