part of drtree;

class RectangleInfo {
  final double top;

  final double left;

  final double length;

  final double width;

  final double square;

  RectangleInfo._({
    required this.top,
    required this.left,
    required this.length,
    required this.width,
    required this.square,
  });

  factory RectangleInfo.fromAnalysis(PointsAnalysis analysis) {
    final left = analysis.minX;

    final width = analysis.maxX - left;

    final top = analysis.minY;

    final length = analysis.maxY - top;

    final square = length * width;

    return RectangleInfo._(
      top: top,
      left: left,
      length: length,
      width: width,
      square: square,
    );
  }
}
