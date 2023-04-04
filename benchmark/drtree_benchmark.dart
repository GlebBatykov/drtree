import 'dart:convert';
import 'dart:io';

import 'package:drtree/drtree.dart';

import 'util/benchmark_points.dart';

Future<BenchmarkPoints> getPoints(String path) async {
  final file = File.fromUri(Uri.file(path));

  final json = BenchmarkPoints.fromJson(jsonDecode(await file.readAsString()));

  return json;
}

DRTree createTree({
  required List<Point> points,
  required int minChildCount,
  required int maxChildCount,
}) {
  final tree = DRTree(
    minChildCount: minChildCount,
    maxChildCount: maxChildCount,
  );

  for (var i = 0; i < points.length; i++) {
    tree.addPoint(points[i]);
  }

  return tree;
}

void main(List<String> arguments) async {
  if (arguments.length < 3) {
    throw Exception(
        'Must be specified arguments: path (String), minChildCount (int, default: 4), maxChildCount (int, default: 8).');
  }

  final path = arguments[0];

  final minChildCount = int.parse(arguments[1]);

  final maxChildCount = int.parse(arguments[2]);

  final benchmarkPoints = await getPoints(path);

  final rectangle = Rectangle.fromPoints(benchmarkPoints.rectanglePoints);

  final stopwatch = Stopwatch()..start();

  var startMemory = ProcessInfo.currentRss;

  final tree = createTree(
    points: benchmarkPoints.points,
    minChildCount: minChildCount,
    maxChildCount: maxChildCount,
  );

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
