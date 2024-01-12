import 'dart:math';
import 'package:flutter_application_1/block_table.dart';
import 'package:flutter_application_1/coordinate.dart';
import 'package:flutter_application_1/pieces.dart';
import 'package:flutter_application_1/game_table.dart';

copyTable(var table) {
  List<List<BlockTable>> newTable = [];
  for (List<BlockTable> rows in table) {
    List<BlockTable> newRow = [];
    for (BlockTable block in rows) {
      BlockTable newBlock = BlockTable(
          row: block.row,
          col: block.col,
          pieces: copyPiece(block.pieces),
          isHighlight: block.isHighlight,
          isHighlightAfterKilling: block.isHighlightAfterKilling,
          killableMore: block.killableMore);
      newRow.add(newBlock);
    }
    newTable.add(newRow);
  }
  return newTable;
}

copyPiece(var piece) {
  if (piece != null) {
    return Pieces(
        coordinate:
            Coordinate(row: piece.coordinate.row, col: piece.coordinate.col),
        player: piece.player,
        isKing: piece.isKing,
        flag: false);
  }
  return null;
}

copyGameTable(GameTable primary_gameTable) {
  GameTable newGameTable = GameTable();
  newGameTable.table = copyTable(primary_gameTable.table);
  newGameTable.currentPlayerTurn = primary_gameTable.currentPlayerTurn;
  return newGameTable;
}

getPossibleMoves(GameTable prevGameTable, int player) {
  GameTable newGameTable = copyGameTable(prevGameTable);
  List moves = [];
  int mode = 0;
  List<Pieces> pieces = pieces_in_pervGameTable(prevGameTable);
  for (Pieces piece in pieces) {
    if (piece.player == player) {
      newGameTable.highlightWalkable(piece);
      for (List rows in newGameTable.table) {
        for (BlockTable block in rows) {
          if (block.isHighlight || block.isHighlightAfterKilling) {
            newGameTable = copyGameTable(prevGameTable);
            Coordinate coor = Coordinate(row: block.row, col: block.col);
            Coordinate piece_coor = Coordinate(
                row: piece.coordinate.row, col: piece.coordinate.col);
            print(
                "piece goes to ${coor.row},${coor.col} from ${piece_coor.row},${piece_coor.col}");
            newGameTable.movePieces(
                newGameTable.table[piece_coor.row][piece_coor.col].pieces,
                coor);
            newGameTable.checkKilled(coor);
            if (checkKiling(newGameTable, coor, piece_coor)) {
              printer(prevGameTable);
            }
            if (newGameTable.checkKillableMore(piece, coor)) {
              mode = GameTable.MODE_WALK_AFTER_KILLING;
            } else {
              // if (newGameTable.isKingArea(
              //     player: newGameTable.currentPlayerTurn, coor: coor)) {
              //   piece.upgradeToKing();
              // }
              mode = GameTable.MODE_WALK_NORMAL;
              newGameTable.togglePlayerTurn();
              // printer(newGameTable);
              // print("+++++++++++++++++++++++");
              newGameTable.clearHighlightWalkable();
            }
            moves.add([
              newGameTable,
              piece,
              {"MODE": mode}
            ]);
          }
        }
      }
      prevGameTable.clearHighlightWalkable();
    }
  }
  return moves;
}

bool checkKiling(
    GameTable newGameTable, Coordinate coor, Coordinate piece_coor) {
  int row_distance = coor.row - piece_coor.row;
  int col_distance = coor.col - piece_coor.col;
  if (row_distance == 2 || row_distance == -2) {
    if (row_distance == 2 && col_distance == 2) {
      newGameTable.table[coor.row - 1][coor.col - 1].pieces = null;
      print("first");
    } else if (row_distance == 2 && col_distance == -2) {
      newGameTable.table[coor.row - 1][coor.col + 1].pieces = null;
      print("second");
    } else if (row_distance == -2 && col_distance == 2) {
      newGameTable.table[coor.row + 1][coor.col - 1].pieces = null;
      print("third");
    } else if (row_distance == -2 && col_distance == -2) {
      newGameTable.table[coor.row + 1][coor.col + 1].pieces = null;
      print("fourth");
    }
    printer(newGameTable);
    return true;
  }
  return false;
}

List<Pieces> pieces_in_pervGameTable(GameTable prevGameTable) {
  List<Pieces> pieces = [];
  for (List<BlockTable> rows in prevGameTable.table) {
    for (BlockTable block in rows) {
      if (block.pieces != null) {
        pieces.add(block.pieces);
      }
    }
  }
  return pieces;
}

evaluateBoard() {
  int whites = Pieces.white_left();
  int blacks = Pieces.black_left();
  int white_king = Pieces.white_king_left();
  int black_king = Pieces.black_king_left();
  return (whites - blacks + (white_king / 2 - black_king / 2));
}

minimax(int depth, int player, GameTable newTable) {
  bool isMaximizingPlayer = false;
  if (player == 1) {
    isMaximizingPlayer = true;
  }
  if (depth == 0 || Pieces.isGameOver()) {
    return evaluateBoard();
  }

  if (isMaximizingPlayer) {
    double maxEval = -double.infinity;
    for (List move in getPossibleMoves(newTable, 1)) {
      GameTable copiedTable = copyGameTable(move[0]); // Copy the game state
      print("A recursion");
      double eval = minimax(depth - 1, 1, copiedTable);
      print("max AFTER RECURSION is ${eval}");
      // printer(copiedTable);
      maxEval = max(maxEval, eval);
      // print("HERE GOOOOOES MAAAAIN");
      // printer(newTable);
      // print('');
    }
    return maxEval;
  } else {
    double minEval = double.infinity;
    for (List move in getPossibleMoves(newTable, 2)) {
      GameTable copiedTable = copyGameTable(move[0]); // Copy the game state
      print("A recursion");
      double eval = minimax(depth - 1, 2, copiedTable);
      print("min AFTER RECURSION is ${eval}");
      print(
          "piece goes to ${move[1].coordinate.row},${move[1].coordinate.col}");
      // printer(copiedTable);
      minEval = min(minEval, eval);
    }
    return minEval;
  }
}

void printer(game) {
  for (var row in game.table) {
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
}
