part of drtree;

abstract class PointsAnalyzer {
  ///
  static PointsAnalysis analyzeTwo(Point first, Point second) => PointsAnalysis(
        minX: min(first.x, second.x),
        minY: min(first.y, second.y),
        maxX: max(first.x, second.x),
        maxY: max(first.y, second.y),
      );

  ///
  static PointsAnalysis analyzeMany(List<Point> points) {
    var minX = points.first.x,
        minY = points.first.y,
        maxX = points.first.x,
        maxY = points.first.y;

    for (var i = 0; i < points.length; i++) {
      if (minX > points[i].x) {
        minX = points[i].x;
      }

      if (maxX < points[i].x) {
        maxX = points[i].x;
      }

      if (minY > points[i].y) {
        minY = points[i].y;
      }

      if (maxY < points[i].y) {
        maxY = points[i].y;
      }
    }

    return PointsAnalysis(
      minX: minX,
      minY: minY,
      maxX: maxX,
      maxY: maxY,
    );
  }

  /// It works correctly if [buffer] does not contain any [null] values.
  static PointsAnalysis analyzeBuffer(List<Point?> buffer) {
    var minX = buffer.first!.x,
        minY = buffer.first!.y,
        maxX = buffer.first!.x,
        maxY = buffer.first!.y;

    for (var i = 0; i < buffer.length; i++) {
      if (minX > buffer[i]!.x) {
        minX = buffer[i]!.x;
      }

      if (maxX < buffer[i]!.x) {
        maxX = buffer[i]!.x;
      }

      if (minY > buffer[i]!.y) {
        minY = buffer[i]!.y;
      }

      if (maxY < buffer[i]!.y) {
        maxY = buffer[i]!.y;
      }
    }

    return PointsAnalysis(
      minX: minX,
      minY: minY,
      maxX: maxX,
      maxY: maxY,
    );
  }
}
