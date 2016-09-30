// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library observe.test.benchmark.observable_list_benchmark;

import 'package:observable/observable.dart';
import 'observation_benchmark_base.dart';

class ObservableListBenchmark extends ObservationBenchmarkBase<ObservableList> {
  final int elementCount = 100;

  ObservableListBenchmark(int objectCount, int mutationCount, String config)
      : super('ObservableListBenchmark:$objectCount:$mutationCount:$config',
            objectCount, mutationCount, config);

  @override
  int mutateObject(ObservableList obj) {
    switch (config) {
      case 'update':
        var size = (elementCount / 10).floor();
        for (var j = 0; j < size; j++) {
          obj[j * size]++;
        }
        return size;

      case 'splice':
        var size = (elementCount / 5).floor();
        // No splice equivalent in List, so we hardcode it.
        var removed = obj.sublist(size, size * 2);
        obj.removeRange(size, size * 2);
        obj.insertAll(size * 2, removed);
        return size * 2;

      case 'push/pop':
        var val = obj.removeLast();
        obj.add(val + 1);
        return 2;

      case 'shift/unshift':
        var val = obj.removeAt(0);
        obj.insert(0, val + 1);
        return 2;

      default:
        throw new ArgumentError(
            'Invalid config for ObservableListBenchmark: $config');
    }
  }

  @override
  ObservableList newObject() {
    var list = new ObservableList();
    for (int i = 0; i < elementCount; i++) {
      list.add(i);
    }
    return list;
  }
}
