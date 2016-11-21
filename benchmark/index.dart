// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library observe.test.benchmark.index;

import 'dart:async';
import 'dart:html';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:chart/chart.dart';
import 'package:observe/mirrors_used.dart' as mu; // Makes output smaller.
import 'package:smoke/mirrors.dart';
import 'object_benchmark.dart';
import 'setup_object_benchmark.dart';
import 'observable_list_benchmark.dart';
import 'setup_observable_list_benchmark.dart';
import 'path_benchmark.dart';
import 'setup_path_benchmark.dart';

/// Benchmark names to factory functions.
/// Uses [mu].
typedef BenchmarkBase BenchmarkFactory(
    int objectCount, int mutationCount, String config);
final Map<String, BenchmarkFactory> benchmarkFactories = {
  'ObjectBenchmark': (int o, int m, String c) => new ObjectBenchmark(o, m, c),
  'SetupObjectBenchmark': (int o, int m, String c) =>
      new SetupObjectBenchmark(o, c),
  'ObservableListBenchmark': (int o, int m, String c) =>
      new ObservableListBenchmark(o, m, c),
  'SetupObservableListBenchmark': (int o, int m, String c) =>
      new SetupObservableListBenchmark(o, c),
  'PathBenchmark': (int o, int m, String c) => new PathBenchmark(o, m, c),
  'SetupPathBenchmark': (int o, int m, String c) =>
      new SetupPathBenchmark(o, c),
};

/// Benchmark names to possible configs.
final Map<String, List<String>> benchmarkConfigs = {
  'ObjectBenchmark': [],
  'SetupObjectBenchmark': [],
  'ObservableListBenchmark': ['splice', 'update', 'push/pop', 'shift/unshift'],
  'SetupObservableListBenchmark': [],
  'PathBenchmark': ['leaf', 'root'],
  'SetupPathBenchmark': [],
};

Iterable<int> objectCounts;
Iterable<int> mutationCounts;

final ButtonElement goButton = querySelector('#go');
final InputElement objectCountInput = querySelector('#objectCountInput');
final InputElement mutationCountInput = querySelector('#mutationCountInput');
final SpanElement mutationCountWrapper = querySelector('#mutationCountWrapper');
final SpanElement statusSpan = querySelector('#status');
final DivElement canvasWrapper = querySelector('#canvasWrapper');
final SelectElement benchmarkSelect = querySelector('#benchmarkSelect');
final SelectElement configSelect = querySelector('#configSelect');
final UListElement legendList = querySelector('#legendList');
final List<String> colors = [
  [0, 0, 255],
  [138, 43, 226],
  [165, 42, 42],
  [100, 149, 237],
  [220, 20, 60],
  [184, 134, 11]
].map((rgb) => 'rgba(' + rgb.join(',') + ',.7)').toList();

main() {
  // TODO(jakemac): Use a transformer to generate the smoke config so we can see
  // how that affects the benchmark.
  useMirrors();

  benchmarkSelect.onChange.listen((_) => changeBenchmark());
  changeBenchmark();

  goButton.onClick.listen((_) async {
    canvasWrapper.children.clear();
    goButton.disabled = true;
    goButton.text = 'Running...';
    legendList.text = '';
    objectCounts =
        objectCountInput.value.split(',').map((val) => int.parse(val));

    if (benchmarkSelect.value.startsWith('Setup')) {
      mutationCounts = [0];
    } else {
      mutationCounts =
          mutationCountInput.value.split(',').map((val) => int.parse(val));
    }

    var i = 0;
    mutationCounts.forEach((count) {
      var li = document.createElement('li');
      li.text = '$count mutations.';
      li.style.color = colors[i % colors.length];
      legendList.append(li);
      i++;
    });

    var results = <List<double>>[];
    for (int objectCount in objectCounts) {
      int x = 0;
      for (int mutationCount in mutationCounts) {
        statusSpan.text =
            'Testing: $objectCount objects with $mutationCount mutations';
        // Let the status text render before running the next benchmark.
        await new Future(() {});
        var factory = benchmarkFactories[benchmarkSelect.value];
        var benchmark = factory(objectCount, mutationCount, configSelect.value);
        // Divide by 10 because benchmark_harness returns the amount of time it
        // took to run 10 times, not once :(.
        var resultMicros = benchmark.measure() / 10;

        if (results.length <= x) results.add([]);
        results[x].add(resultMicros / 1000);
        x++;
      }
    }

    drawBenchmarks(results);
  });
}

void drawBenchmarks(List<List<double>> results) {
  var datasets = [];
  for (int i = 0; i < results.length; i++) {
    datasets.add({
      'fillColor': 'rgba(255, 255, 255, 0)',
      'strokeColor': colors[i % colors.length],
      'pointColor': colors[i % colors.length],
      'pointStrokeColor': "#fff",
      'data': results[i],
    });
  }
  var data = {
    'labels': objectCounts.map((c) => '$c').toList(),
    'datasets': datasets,
  };

  new Line(data, {
    'bezierCurve': false,
  }).show(canvasWrapper);
  goButton.disabled = false;
  goButton.text = 'Run Benchmarks';
  statusSpan.text = '';
}

void changeBenchmark() {
  var configs = benchmarkConfigs[benchmarkSelect.value];
  configSelect.text = '';
  configs.forEach((config) {
    var option = document.createElement('option');
    option.text = config;
    configSelect.append(option);
  });

  document.title = benchmarkSelect.value;

  // Don't show the configSelect if there are no configs.
  if (configs.isEmpty) {
    configSelect.style.display = 'none';
  } else {
    configSelect.style.display = 'inline';
  }

  // Don't show the mutation counts box if running a Setup* benchmark.
  if (benchmarkSelect.value.startsWith('Setup')) {
    mutationCountWrapper.style.display = 'none';
  } else {
    mutationCountWrapper.style.display = 'inline';
  }
}
