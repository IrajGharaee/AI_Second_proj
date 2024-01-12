import 'package:flutter_application_1/kiling.dart';
// ignore: unused_import
import 'package:flutter_application_1/pieces.dart';

class BlockTable {
  int row;
  int col;
  var pieces;
  bool isHighlight;
  bool isHighlightAfterKilling;
  Killed? victim;
  bool killableMore = false;

  BlockTable(
      {this.row = 0,
      this.col = 0,
      this.pieces,
      this.isHighlight = false,
      this.isHighlightAfterKilling = false,
      this.killableMore = false});
}
