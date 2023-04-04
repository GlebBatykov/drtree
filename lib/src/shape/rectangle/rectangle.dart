part of drtree;

///
class Rectangle extends ShapeContainer {
  final List<Point> _points;

  final double top;

  final double left;

  final double length;

  final double width;

  final double square;

  final PointsAnalysis analysis;

  @override
  List<Point> get points => List.unmodifiable(_points);

  Rectangle({
    required List<Point> points,
    required RectangleInfo info,
    required this.analysis,
  })  : _points = points,
        length = info.length,
        width = info.width,
        square = info.square,
        top = info.top,
        left = info.left;

  ///
  factory Rectangle.fromPoints(List<Point> points) {
    final analysis = PointsAnalyzer.analyzeMany(points);

    final info = RectangleInfo.fromAnalysis(analysis);

    return Rectangle(
      points: points,
      info: info,
      analysis: analysis,
    );
  }

  @override
  bool enters(Shape shape) {
    if (shape is Rectangle) {
      return shape.analysis.maxX >= analysis.maxX &&
          shape.analysis.maxY >= analysis.maxY &&
          shape.analysis.minX <= analysis.minX &&
          shape.analysis.minY <= analysis.minY;
    }

    return false;
  }

  @override
  bool intersects(ShapeContainer shape) {
    if (shape is Rectangle) {
      return (left <= shape.left + shape.width &&
          shape.left <= left + width &&
          top <= shape.top + shape.length &&
          shape.top <= top + length);
    }

    return false;
  }
}
