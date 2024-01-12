// ignore: unused_import
import 'package:flutter_application_1/pieces.dart';

class Killed {
  var isKilled;
  var pieces;

  Killed({this.isKilled = false, required this.pieces});

  Killed.none() {
    isKilled = false;
  }
}
