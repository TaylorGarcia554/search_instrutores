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
      version: 1,
      onCreate: _createDB,
    );
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
        sheet TEXT
      )
    ''');
  }

  static Future<void> inserirRegistro(Map<String, String> data) async {
    final db = await database;
    await db.insert('registros', data);
  }

  static Future<List<Map<String, dynamic>>> buscarPorTermo(String termo) async {
    final db = await database;
    return await db.query(
      'registros',
      where: 'linha LIKE ?',
      whereArgs: ['%$termo%'],
    );
  }

  static Future<void> limparTabela() async {
    final db = await database;
    await db.delete('registros');
  }
}
