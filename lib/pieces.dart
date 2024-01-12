import 'package:flutter_application_1/coordinate.dart';

class Pieces {
  static List<Pieces> all_pieces = [];
  var player;
  bool isKing = false;
  var coordinate;
  var flag;

  Pieces(
      {this.player = 1,
      this.isKing = false,
      required this.coordinate,
      this.flag = true}) {
    if (flag) {
      all_pieces.add(this);
    }
  }

  Pieces.of(Pieces pieces, {required Coordinate newCoor}) {
    player = pieces.player;
    isKing = pieces.isKing;
    coordinate = pieces.coordinate;
  }

  void upgradeToKing() {
    isKing = true;
  }

  static get_all_pieces() {
    return all_pieces;
  }

  static set_all_pieces(List<Pieces> pieces) {
    all_pieces = pieces;
  }

  static get_copy_of_pieces() {
    List<Pieces> copy_pieces = [];
    for (Pieces piece in all_pieces) {
      copy_pieces.add(Pieces.of(piece, newCoor: piece.coordinate!));
    }
    return copy_pieces;
  }

  static isGameOver() {
    return all_pieces.isEmpty;
  }

  static white_left() {
    int counter = 0;
    for (final p in all_pieces) {
      if (p.player == 2 && !p.isKing) {
        counter += 1;
      }
    }
    return counter;
  }

  static black_left() {
    int counter = 0;
    for (final p in all_pieces) {
      if (p.player == 1 && !p.isKing) {
        counter += 1;
      }
    }
    return counter;
  }

  static white_king_left() {
    int counter = 0;
    for (final p in all_pieces) {
      if (p.player == 2 && p.isKing) {
        counter += 1;
      }
    }
    return counter;
  }

  static black_king_left() {
    int counter = 0;
    for (final p in all_pieces) {
      if (p.player == 1 && p.isKing) {
        counter += 1;
      }
    }
    return counter;
  }
}
