import 'package:drtree/drtree.dart';

import 'point_json_convert.dart';

class BenchmarkPoints {
  final List<Point> points;

  final List<Point> rectanglePoints;

  BenchmarkPoints(this.points, this.rectanglePoints);

  BenchmarkPoints.fromJson(Map<String, Object?> json)
      : points = (json['points'] as List)
            .map((e) => PointJsonConvert.fromJson(e))
            .toList(),
        rectanglePoints = (json['rectanglePoints'] as List)
            .map((e) => PointJsonConvert.fromJson(e))
            .toList();

  Map<String, Object?> toJson() => {
        'points': points.map((e) => PointJsonConvert.toJson(e)).toList(),
        'rectanglePoints':
            rectanglePoints.map((e) => PointJsonConvert.toJson(e)).toList(),
      };
}
