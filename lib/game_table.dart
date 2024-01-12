import 'package:flutter_application_1/block_table.dart';
import 'package:flutter_application_1/coordinate.dart';
import 'package:flutter_application_1/kiling.dart';
import 'package:flutter_application_1/pieces.dart';

// typedef OnWalkableAfterKilling = bool Function(
//     Coordinate newCoor, Killed killed);

bool isWalkableAfterKilling(Coordinate after_kiling, Killed killed) {
  if (killed.pieces.player == 1) {
    return after_kiling.row >= killed.pieces.coordinate.row;
  } else {
    return after_kiling.row <= killed.pieces.coordinate.row;
  }
}

typedef OnKingWalkable = void Function(Coordinate newCoor);
typedef OnKingWalkableAfterKilling = void Function(
    Coordinate newCoor, Killed killed);
typedef OnKingUnWalkable = void Function(Coordinate newCoor);

class GameTable {
  static const int MODE_WALK_NORMAL = 1; // walk to empty or walk to first kill.
  static const int MODE_WALK_AFTER_KILLING =
      2; // walk after kill to 2 3 4.. enemy.
  static const int MODE_AFTER_KILLING =
      3; // calculation to future that pieces can walk.

  int countRow = 8;
  int countCol = 8;
  var table;
  int currentPlayerTurn = 2;
  List<Coordinate> listTempForKingWalkCalculation = [];
  static List the_one = [];

  GameTable({this.countRow = 8, this.countCol = 8}) : table = [] {
    init();
    the_one.add(this);
  }

  init() {
    table = [];
    for (int row = 0; row < countRow; row++) {
      List<BlockTable> listBlockTable = [];
      for (int col = 0; col < countCol; col++) {
        listBlockTable.add(BlockTable(row: row, col: col));
      }

      table.add(listBlockTable);
    }
  }

  void initPiecesOnTable() {
    initPiecesOnTableRow(player: 1, row: 0);
    initPiecesOnTableRow(player: 1, row: 1);
    initPiecesOnTableRow(player: 2, row: countRow - 2);
    initPiecesOnTableRow(player: 2, row: countRow - 1);
  }

  void initPiecesOnTableRow({int player = 1, int row = 0}) {
    for (int col = 0; col < countCol; col++) {
      addPieces(Coordinate(row: row, col: col), player: player);
    }
  }

  clearHighlightWalkable() {
    for (int row = 0; row < countRow; row++) {
      for (int col = 0; col < countCol; col++) {
        table[row][col].isHighlight = false;
        table[row][col].isHighlightAfterKilling = false;
        table[row][col].killableMore = false;
        table[row][col].victim = Killed.none();
      }
    }
  }

  printer() {
    print("table:");
    for (var row in this.table) {
      var tmp = [];
      for (BlockTable block in row) {
        if (block.pieces != null) {
          tmp.add(block.pieces.player);
        } else {
          tmp.add("X");
        }
      }
      print(tmp);
    }
    var all_pieces = Pieces.get_all_pieces();
    List tmp = [];
    print("pieces");
    for (var p in all_pieces) {
      tmp = [];
      tmp.add(p.coordinate.row);
      tmp.add(p.coordinate.col);
      tmp.add(p.player);
      print(tmp);
    }
  }

  highlightWalkable(Pieces pieces, {int mode = MODE_WALK_NORMAL}) {
    if (!isBlockAvailable(pieces.coordinate)) {
      return;
    }

    if (pieces.player == 2) {
      if (pieces.isKing) {
        listTempForKingWalkCalculation.clear();
        checkWalkableKing(pieces, mode);
      } else {
        checkWalkablePlayer2(pieces, mode: mode);
      }
    } else if (pieces.player == 1) {
      if (pieces.isKing) {
        listTempForKingWalkCalculation.clear();
        checkWalkableKing(pieces, mode);
      } else {
        checkWalkablePlayer1(pieces, mode: mode);
      }
    }
  }

  bool checkWalkablePlayer1(Pieces pieces, {int mode = MODE_WALK_NORMAL}) {
    bool movableLeft = checkWalkablePlayer1Left(pieces.coordinate, mode: mode);
    bool movableRight = checkWalkablePlayer1Right(
      pieces.coordinate,
      mode: mode,
    );
    return movableLeft || movableRight;
  }

  bool checkWalkablePlayer2(Pieces pieces, {int mode = MODE_WALK_NORMAL}) {
    bool movableLeft = checkWalkablePlayer2Left(pieces.coordinate, mode: mode);

    bool movableRight =
        checkWalkablePlayer2Right(pieces.coordinate, mode: mode);

    return movableLeft || movableRight;
  }

  bool checkWalkable({
    required int mode,
    // required int node,
    required Coordinate next,
    required Coordinate nextIfKilling,
  }) {
    if (hasPieces(next)) {
      if (hasPiecesEnemy(next)) {
        if (isBlockAvailable(nextIfKilling) && !hasPieces(nextIfKilling)) {
          print("mode = $mode");
          if (mode == MODE_WALK_NORMAL || mode == MODE_WALK_AFTER_KILLING) {
            setHighlightWalkableAfterKilling(nextIfKilling);
          }

          Killed killed =
              Killed(isKilled: true, pieces: getBlockTable(next).pieces);
          getBlockTable(nextIfKilling).victim = killed;

          if (isWalkableAfterKilling(nextIfKilling, killed)) {
            bool isKillable = isWalkableAfterKilling(nextIfKilling, killed);
            getBlockTable(nextIfKilling).killableMore = isKillable;
          }
          return true;
        }
      }
    } else {
      print(next.row);
      print(next.col);
      if (mode == MODE_WALK_NORMAL) {
        setHighlightWalkable(next);
        return true;
      }
    }
    return false;
  }

  bool checkWalkablePlayer2Right(Coordinate coor, {required int mode}) {
    return checkWalkable(
        mode: mode,
        next: Coordinate(row: coor.row - 1, col: coor.col + 1),
        nextIfKilling: Coordinate(row: coor.row - 2, col: coor.col + 2));
  }

  bool checkWalkablePlayer2Left(Coordinate coor, {required int mode}) {
    return checkWalkable(
        mode: mode,
        next: Coordinate(row: coor.row - 1, col: coor.col - 1),
        nextIfKilling: Coordinate(row: coor.row - 2, col: coor.col - 2));
  }

  bool checkWalkablePlayer1Right(Coordinate coor, {required int mode}) {
    return checkWalkable(
        mode: mode,
        next: Coordinate(row: coor.row + 1, col: coor.col + 1),
        nextIfKilling: Coordinate(row: coor.row + 2, col: coor.col + 2));
  }

  bool checkWalkablePlayer1Left(
    Coordinate coor, {
    required int mode, //required OnWalkableAfterKilling onKilling}
  }) {
    return checkWalkable(
        mode: mode,
        next: Coordinate(row: coor.row + 1, col: coor.col - 1),
        nextIfKilling: Coordinate(row: coor.row + 2, col: coor.col - 2));
  }

  setHighlightWalkable(Coordinate coor) {
    if (isBlockAvailable(coor) && !hasPieces(coor)) {
      getBlockTable(coor).isHighlight = true;
    }
  }

  setHighlightWalkableAfterKilling(Coordinate coor) {
    if (isBlockAvailable(coor) && !hasPieces(coor)) {
      getBlockTable(coor).isHighlightAfterKilling = true;
    }
  }

  bool hasPieces(Coordinate coor) {
    if (isBlockAvailable(coor)) {
      return getBlockTable(coor).pieces != null;
    }
    return false;
  }

  bool hasPiecesEnemy(Coordinate coor) {
    if (hasPieces(coor)) {
      return getBlockTable(coor).pieces.player != currentPlayerTurn;
    }
    return false;
  }

  bool isBlockAvailable(Coordinate? coor) {
    if (coor == null) {
      return false;
    }
    // print("OR WHAT?");
    return coor.row >= 0 &&
        coor.row < countRow &&
        coor.col >= 0 &&
        coor.col < countCol;
  }

  movePieces(Pieces pieces, Coordinate newCoordinate) {
    getBlockTable(pieces.coordinate).pieces = null;
    getBlockTable(newCoordinate).pieces = pieces;
    pieces.coordinate = newCoordinate;
  }

  togglePlayerTurn() {
    if (currentPlayerTurn == 1) {
      currentPlayerTurn = 2;
    } else {
      currentPlayerTurn = 1;
    }
  }

  bool checkKilled(Coordinate coor) {
    Killed? killing = getBlockTable(coor).victim;
    print("RRRRRRRRRRRRRRRRRRRRRRRRRR");
    if (killing != null && killing.isKilled) {
      var all_pieces = Pieces.all_pieces;
      all_pieces.remove(killing.pieces);
      Pieces.set_all_pieces(all_pieces);
      getBlockTable(killing.pieces.coordinate).pieces = null;

      return true;
    }
    return false;
  }

  bool checkKillableMore(Pieces pieces, Coordinate coor) {
    if (pieces.isKing) {
      listTempForKingWalkCalculation.clear();
      return checkWalkableKing(pieces, MODE_AFTER_KILLING);
    } else {
      return getBlockTable(coor).killableMore;
    }
  }

  void addPieces(Coordinate coor, {int player = 1, bool isKing = false}) {
    if (!isBlockTypeF(coor)) {
//      List<Pieces> listPieces = player == 1 ? listPiecesPlayer1 : listPiecesPlayer2;
      Pieces pieces = Pieces(
          player: player, coordinate: Coordinate.of(coor), isKing: isKing);
//      listPieces.add(pieces);
      getBlockTable(coor).pieces = pieces;
    }
  }

  bool isBlockTypeF(Coordinate coor) {
    return (coor.row % 2 == 0 && coor.col % 2 == 0) ||
        (coor.row % 2 == 1 && coor.col % 2 == 1);
  }

  BlockTable getBlockTable(Coordinate coor) {
    return table[coor.row][coor.col];
  }

  bool isKingArea({required int player, required Coordinate coor}) {
    if (player == 1) {
      return coor.row == countRow - 1;
    } else {
      return coor.row == 0;
    }
  }

  bool checkWalkableKing(Pieces pieces, int mode) {
    Killed killable1 =
        checkWalkableKingPath(pieces, mode, addRow: -1, addCol: -1);
    Killed killable2 =
        checkWalkableKingPath(pieces, mode, addRow: -1, addCol: 1);
    Killed killable3 =
        checkWalkableKingPath(pieces, mode, addRow: 1, addCol: -1);
    Killed killable4 =
        checkWalkableKingPath(pieces, mode, addRow: 1, addCol: 1);
    return killable1.isKilled ||
        killable2.isKilled ||
        killable3.isKilled ||
        killable4.isKilled;
  }

  Killed checkWalkableKingPath(Pieces pieces, int mode,
      {int addRow = 0, int addCol = 0}) {
    print("checkWalkableKingPath");
    Killed killable = Killed(pieces: pieces);
    int row = pieces.coordinate.row + addRow;
    int col = pieces.coordinate.col + addCol;

    if (row < 0 || row > countRow || col < 0 || col > countCol) {
      return killable;
    }

    for (int i = 0; i < countRow; i++) {
      Coordinate currentCoor = Coordinate(row: row, col: col);

      bool isWalked = listTempForKingWalkCalculation
          .where((coor) {
            return coor.row == row && coor.col == col;
          })
          .toList()
          .isNotEmpty;

      if (isWalked) {
        return killable;
      } else {
        listTempForKingWalkCalculation.add(currentCoor);
        // for (Coordinate c in listTempForKingWalkCalculation) {
        //   print("Temp = (${c.row},${c.col})");
        // }
      }

      bool walkable = checkWalkableKingInBlock(mode, currentCoor,
          addRow: addRow, addCol: addCol, onKingWalkable: (newCoor) {
        if (mode == MODE_WALK_NORMAL) {
          setHighlightWalkable(newCoor);
        }
      }, onKingWalkableAfterKilling: (newCoor, killed) {
        if (isBlockAvailable(newCoor)) {
          killable = killed;
          getBlockTable(newCoor).victim = killed;
          if (mode == MODE_WALK_NORMAL) {
            setHighlightWalkableAfterKilling(newCoor);
          }
          if (mode == MODE_WALK_AFTER_KILLING) {
            setHighlightWalkableAfterKilling(newCoor);
          }

          print("${newCoor.row},${newCoor.col}");
          bool killableMore = checkWalkableKing(
              Pieces.of(pieces, newCoor: newCoor), MODE_AFTER_KILLING);

          print("killableMore = $killableMore");
          getBlockTable(newCoor).killableMore = killableMore;
        }
      }, onKingUnwalkable: (newCoor) {});

      if (!walkable) {
        return killable;
      }

      row += addRow;
      col += addCol;

      if (row < 0 || row > countRow || col < 0 || col > countCol) {
        return killable;
      }
    }
    return killable;
  }

  bool checkWalkableKingInBlock(int mode, Coordinate coor,
      {int addRow = 0,
      int addCol = 0,
      OnKingWalkable? onKingWalkable,
      OnKingWalkableAfterKilling? onKingWalkableAfterKilling,
      OnKingUnWalkable? onKingUnwalkable}) {
    if (!hasPieces(coor)) {
      if (mode == MODE_WALK_NORMAL) {
        setHighlightWalkable(coor);
      }

      if (onKingWalkable != null) {
        onKingWalkable(coor);
      }
      return true;
    } else {
      if (hasPiecesEnemy(coor)) {
        Pieces enemyKilled = getBlockTable(coor).pieces;
        Coordinate nextCoorAfterKill =
            Coordinate.of(coor, addRow: addRow, addCol: addCol);
        if (!hasPieces(nextCoorAfterKill)) {
          if (onKingWalkableAfterKilling != null) {
            onKingWalkableAfterKilling(
                nextCoorAfterKill, Killed(isKilled: true, pieces: enemyKilled));
          }
          return false;
        }
      }
    }

    if (onKingUnwalkable != null) {
      onKingUnwalkable(coor);
    }
    return false;
  }
}
