import 'dart:developer';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('dados_planilha.db');
    return _db!;
  }

  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  static Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE registros ADD COLUMN sheetId TEXT');
    }

    if (oldVersion < 3) {
      await db.execute(
          'ALTER TABLE registros ADD COLUMN lembrado INTERGER DEFAULT 0');
    }

  }

  static Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE registros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dataPedido TEXT,
        tipo TEXT,
        quantidade TEXT,
        nome TEXT,
        tipoConta TEXT,
        dataPagamento TEXT,
        formaPagamento TEXT,
        produto TEXT,
        valor TEXT,
        vazio TEXT,
        email TEXT,
        cpfOuCnpj TEXT,
        telefone TEXT,
        linha TEXT,
        sheet TEXT,
        sheetID TEXT,
        lembrado INTERGER DEFAULT 0
      )
    ''');
  }

  static Future<void> inserirRegistro(Map<String, String> registro) async {
    final db = await database;

    final existe = await db.query(
      'registros',
      where: 'linha = ? AND sheet = ?',
      whereArgs: [registro['linha'], registro['sheet']],
    );

    if (existe.isEmpty) {
      await db.insert('registros', registro);
    } else {
      log('Registro já existe, não será inserido: ${registro['linha']}');
    }
  }

  static Future<void> atualizarSheetIdPorNome(
      String sheetName, String sheetId) async {
    final db = await database;
    await db.update(
      'registros',
      {'sheetId': sheetId},
      where: 'sheet = ?',
      whereArgs: [sheetName],
    );
  }

  static Future<void> marcarComoAtualizado(int id) async {
    final db = await database;
    await db.update(
      'registros',
      {'lembrado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Map<String, dynamic>>> buscarTodosAtualizados() async {
    final db = await database;
    return await db.query(
      'registros',
      where: 'lembrado = ?',
      whereArgs: [1],
    );
  }

  static Future<List<Map<String, dynamic>>> buscarPorTermo(String termo) async {
    final db = await database;
    return await db.query(
      'registros',
      where: 'linha LIKE ? OR sheet LIKE ?',
      whereArgs: ['%$termo%', '%$termo%'],
    );
  }

  static Future<void> limparTabela() async {
    final db = await database;
    await db.delete('registros');
  }

  static Future<List<Map<String, dynamic>>> procurarPorMes(
      String anoMes) async {
    final db = await database;
    return await db.query(
      'registros',
      where: 'sheet = ?',
      whereArgs: [anoMes],
    );
  }
}
