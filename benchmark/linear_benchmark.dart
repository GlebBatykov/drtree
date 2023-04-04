import "dart:convert";
import "dart:io";

import "package:drtree/drtree.dart";

import "util/benchmark_points.dart";

Future<BenchmarkPoints> getPoints(String path) async {
  final file = File.fromUri(Uri.file(path));

  final json = BenchmarkPoints.fromJson(jsonDecode(await file.readAsString()));

  return json;
}

List<Point> benchmark(List<Point> points, Rectangle rectangle) {
  final part = <Point>[];

  for (final point in points) {
    if (point.enters(rectangle)) {
      part.add(point);
    }
  }

  return part;
}

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    throw Exception('Must be specified arguments: path (String).');
  }

  final path = arguments[0];

  final benchmarkPoints = await getPoints(path);

  final rectangle = Rectangle.fromPoints(benchmarkPoints.rectanglePoints);

  final stopwatch = Stopwatch()..start();

  final startMemory = ProcessInfo.currentRss;

  final points = benchmark(benchmarkPoints.points, rectangle);

  stopwatch.stop();

  final memory = ProcessInfo.currentRss - startMemory;

  print('Find ${points.length} points');
  print('Time (mc): ${stopwatch.elapsedMicroseconds}');
  print('Memory (byte): $memory');
}
