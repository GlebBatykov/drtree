part of drtree;

///
class DRTree implements PointFinder {
  final Root _root;

  ///
  DRTree({
    int minChildCount = 2,
    int maxChildCount = 4,
  })  : assert(minChildCount >= 2, '123'),
        assert(minChildCount <= maxChildCount * 0.5, '123'),
        _root = Root(
          maxChildCount: maxChildCount,
          minChildCount: minChildCount,
        );

  void addPoint(Point point) {
    _root.addShape(point);
  }

  @override
  List<Point> getPointsInShape(ShapeContainer shape) {
    return _root.getPointsInShape(shape);
  }

  List<Point> getPoints() {
    return _root.getPoints();
  }
}
