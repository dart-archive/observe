// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library observe.test.benchmark.setup_observable_list_benchmark;

import 'package:observe/observe.dart';
import 'setup_observation_benchmark_base.dart';

class SetupObservableListBenchmark extends SetupObservationBenchmarkBase {
  final int elementCount = 100;

  SetupObservableListBenchmark(int objectCount, String config) : super(
          'SetupObservableListBenchmark:$objectCount:$config', objectCount,
          config);

  @override
  ObservableList newObject() {
    var list = new ObservableList();
    for (int i = 0; i < elementCount; i++) {
      list.add(i);
    }
    list.deliverChanges();
    list.deliverListChanges();
    return list;
  }
}
