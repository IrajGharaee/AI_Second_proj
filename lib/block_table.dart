import 'package:flutter_application_1/kiling.dart';
// ignore: unused_import
import 'package:flutter_application_1/men.dart';

class BlockTable {
  int row;
  int col;
  var men;
  bool isHighlight;
  bool isHighlightAfterKilling;
  Killed? victim;
  bool killableMore = false;

  BlockTable(
      {this.row = 0,
      this.col = 0,
      this.men,
      this.isHighlight = false,
      this.isHighlightAfterKilling = false,
      this.killableMore = false});
}
