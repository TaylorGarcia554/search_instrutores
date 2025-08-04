import 'dart:developer';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBApiHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('dados_api.db'); // nome diferente
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
      CREATE TABLE clientes (
        id INTEGER PRIMARY KEY,
        nome TEXT,
        email TEXT,
        telefone TEXT,
        cpf TEXT,
        observacao TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE produtos (
        id INTEGER PRIMARY KEY,
        nome TEXT,
        preco DOUBLE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE compras (
        id INTEGER PRIMARY KEY,
        client_id INTEGER,
        produto_id INTEGER,
        data_pedido DATE,
        data_postagem DATE,
        valor DOUBLE,
        pagamento_id TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        entrega TEXT,
        observacao TEXT,
        pedido TEXT,
        FOREIGN KEY (client_id) REFERENCES clientes(id),  
        FOREIGN KEY (produto_id) REFERENCES produtos(id)
      )
    ''');
  }

  static Future<void> inserirCliente(Map<String, dynamic> cliente) async {
    final db = await database;

    // Verifica se já existe cliente com esse id
    final existing = await db.query(
      'clientes',
      where: 'id = ?',
      whereArgs: [cliente['id']],
    );

    if (existing.isEmpty) {
      // Insere novo
      await db.insert('clientes', cliente,
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      // Atualiza existente
      await db.update(
        'clientes',
        cliente,
        where: 'id = ?',
        whereArgs: [cliente['id']],
      );
    }
  }

  static Future<void> inserirProduto(Map<String, dynamic> produto) async {
    final db = await database;

    // Verifica se já existe produto com esse id
    final existing = await db.query(
      'produtos',
      where: 'id = ?',
      whereArgs: [produto['id']],
    );

    if (existing.isEmpty) {
      await db.insert('produtos', produto,
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await db.update(
        'produtos',
        produto,
        where: 'id = ?',
        whereArgs: [produto['id']],
      );
    }
  }

  static Future<void> inserirCompras(Map<String, dynamic> compras) async {
    final db = await database;

    final existing = await db.query(
      'compras',
      where: 'id = ?',
      whereArgs: [compras['id']],
    );

    if (existing.isEmpty) {
      await db.insert('compras', compras,
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await db.update(
        'compras',
        compras,
        where: 'id = ?',
        whereArgs: [compras['id']],
      );
    }
  }

  static Future<void> atualizarClientes(Map<String, dynamic> clientes) async {
    final db = await database;

    final existing = await db.query(
      'clientes',
      where: 'id = ?',
      whereArgs: [clientes['id']],
    );
    if (existing.isNotEmpty) {
      await db.update(
        'clientes',
        clientes,
        where: 'id = ?',
        whereArgs: [clientes['id']],
      );
    } else {
      log('Cliente com ID ${clientes['id']} não encontrado para atualização.');
    }
  }

  static Future<List<Map<String, dynamic>>> buscarPorTermoNovo(
      String termo) async {
    final db = await database;
    return await db.query(
      'clientes',
      where: 'nome LIKE ? OR telefone LIKE ? OR cpf LIKE ? or email LIKE ?',
      whereArgs: ['%$termo%', '%$termo%', '%$termo%', '%$termo%'],
    );
  }

  static Future<List<Map<String, dynamic>>> buscarPorMes(String mes) async {
    final db = await database;
    return await db.query(
      'compras',
      where: 'strftime("%m", data_pedido) = ?',
      whereArgs: [mes],
    );
  }

  static Future<List<Map<String, dynamic>>> buscarComprasPorCliente(int clienteId) async {
    final db = await database;
    return await db.query(
      'compras',
      where: 'client_id = ?',
      whereArgs: [clienteId],
    );
  }
  
  static Future<String> buscarProdutos(int produto) async {
    final db = await database;
    final nome = await db.query(
      'produtos',
      where: 'id = ?',
      whereArgs: [produto],
    );

    return nome.isNotEmpty ? nome.first['nome'] as String : 'Produto não encontrado';
  }

  static Future<Map<String, dynamic>> buscarCliente(int id) {
    return database.then((db) async {
      final result = await db.query(
        'clientes',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return result.first;
      } else {
        log('Cliente não encontrado com ID: $id');
        return {};
      }
    });

  }

}
