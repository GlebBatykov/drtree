import 'dart:convert';
import 'dart:io';
import 'dart:math' hide Point;

import 'package:drtree/drtree.dart';

import 'benchmark_points.dart';

BenchmarkPoints generatePoints(int count, int range) {
  final points = <Point>[];

  final random = Random();

  for (var i = 0; i < count; i++) {
    late Point point;

    do {
      point = Point(
        x: random.nextInt(range).toDouble(),
        y: random.nextInt(range).toDouble(),
      );
    } while (points.contains(point));

    points.add(point);
  }

  final rectanglePoints = getRectanglePoints(points);

  return BenchmarkPoints(points, rectanglePoints);
}

List<Point> getRectanglePoints(List<Point> points) {
  final random = Random();

  final first = points[random.nextInt(points.length)];

  late Point second;

  do {
    second = points[random.nextInt(points.length)];
  } while (first == second);

  return [first, second];
}

Future<void> writeToFile(String path, BenchmarkPoints points) async {
  final file = File.fromUri(Uri.parse(path));

  if (!await file.exists()) {
    await file.create(recursive: true);
  }

  final json = points.toJson();

  final jsonString = jsonEncode(json);

  await file.writeAsString(jsonString);
}

void main(List<String> arguments) async {
  if (arguments.length < 3) {
    throw Exception(
        'Must be specified arguments: path (String), count (int), range (int).');
  }

  final path = arguments[0];

  final count = int.parse(arguments[1]);

  final range = int.parse(arguments[2]);

  final benchmarkPoints = generatePoints(count, range);

  await writeToFile(path, benchmarkPoints);
}
