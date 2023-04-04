part of drtree;

abstract class ShapeContainer extends Shape {
  List<Point> get points;

  bool intersects(ShapeContainer shape);
}
