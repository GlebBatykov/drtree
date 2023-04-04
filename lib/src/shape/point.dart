part of drtree;

///
class Point extends Shape {
  ///
  final double x;

  ///
  final double y;

  Point({
    required this.x,
    required this.y,
  });

  @override
  bool enters(Shape shape) {
    if (shape is Point) {
      return this == shape;
    } else if (shape is Rectangle) {
      final analysis = shape.analysis;

      return analysis.maxX >= x &&
          analysis.maxY >= y &&
          analysis.minX <= x &&
          analysis.minY <= y;
    }

    return false;
  }

  @override
  bool operator ==(other) {
    if (other is! Point) {
      return false;
    }

    return x == other.x && y == other.y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}
