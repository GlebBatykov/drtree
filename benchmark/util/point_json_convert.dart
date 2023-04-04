import 'package:drtree/drtree.dart';

abstract class PointJsonConvert {
  static Point fromJson(Map<String, Object?> json) {
    return Point(
      x: json['x'] as double,
      y: json['y'] as double,
    );
  }

  static Map<String, Object?> toJson(Point point) => {
        'x': point.x,
        'y': point.y,
      };
}
