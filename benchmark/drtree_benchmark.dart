import 'dart:convert';
import 'dart:io';

import 'package:drtree/drtree.dart';

import 'util/benchmark_points.dart';

Future<BenchmarkPoints> getPoints(String path) async {
  final file = File.fromUri(Uri.file(path));

  final json = BenchmarkPoints.fromJson(jsonDecode(await file.readAsString()));

  return json;
}

DRTree createTree(List<Point> points) {
  final tree = DRTree(
    minChildCount: 6,
    maxChildCount: 12,
  );

  for (var i = 0; i < points.length; i++) {
    tree.addPoint(points[i]);
  }

  return tree;
}

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    throw Exception('Must be specified arguments: path (String).');
  }

  final path = arguments[0];

  final benchmarkPoints = await getPoints(path);

  final rectangle = Rectangle.fromPoints(benchmarkPoints.rectanglePoints);

  final stopwatch = Stopwatch()..start();

  var startMemory = ProcessInfo.currentRss;

  final tree = createTree(benchmarkPoints.points);

  stopwatch.stop();

  var memory = ProcessInfo.currentRss - startMemory;

  print('Create tree time');
  print('Time (mc): ${stopwatch.elapsedMicroseconds}');
  print('Memory (byte): $memory');

  stdout.writeln();

  stopwatch.reset();
  stopwatch.start();

  startMemory = ProcessInfo.currentRss;

  final points = tree.getPointsInShape(rectangle);

  stopwatch.stop();

  memory = ProcessInfo.currentRss - startMemory;

  print('Find ${points.length} points');
  print('Time (mc): ${stopwatch.elapsedMicroseconds}');
  print('Memory (byte): $memory');
}
