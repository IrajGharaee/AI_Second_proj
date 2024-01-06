import 'package:flutter_application_1/coordinate.dart';

class Men {
  static List<Men> all_men = [];
  var player;
  bool isKing = false;
  var coordinate;

  Men({this.player = 1, this.isKing = false, required this.coordinate});

  Men.of(Men men, {required Coordinate newCoor}) {
    player = men.player;
    isKing = men.isKing;
    coordinate = men.coordinate;
  }

  void upgradeToKing() {
    isKing = true;
  }
}
