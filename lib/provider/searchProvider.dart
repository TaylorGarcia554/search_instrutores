import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:search_instrutores/models/dbHelper.dart';
import 'package:search_instrutores/models/dbHelperNew.dart';

class SearchProvider extends ChangeNotifier {
  final String _searchQuery = '';
  bool _isLoading = false;

  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  static const baseUrl = 'http://app.autoescolaonline.net/api';

  Future<List<String>> obterNomesDasAbas(
      String spreadsheetId, String apiKey) async {
    final url =
        'https://sheets.googleapis.com/v4/spreadsheets/$spreadsheetId?key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List sheets = data['sheets'];

      // Pegamos o nome de cada aba
      final List<String> nomesDasAbas = sheets.map<String>((sheet) {
        return sheet['properties']['title'];
      }).toList();
      log('Abas: $nomesDasAbas');

      return nomesDasAbas;
    } else {
      throw Exception('Erro ao obter nomes das abas: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> buscarLocalmente(String termo) async {
    return await DBHelper.buscarPorTermo(termo.toLowerCase());
  }

  Future<List<Map<String, dynamic>>> buscarPorMes(String anoMes) async {
    return await DBHelper.procurarPorMes(anoMes);
  }

  Future<void> baixarEArmazenarDados(
    String spreadsheetId,
    String apiKey,
    List<String> sheetNames,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await DBHelper.limparTabela();

      final ultimasAbas = sheetNames.reversed.take(30);

      for (final sheet in ultimasAbas) {
        log('Buscando na aba: $sheet');
        final url =
            'https://sheets.googleapis.com/v4/spreadsheets/$spreadsheetId/values/${Uri.encodeComponent(sheet)}?key=$apiKey';

        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List valores = data['values'];

          for (final linha in valores) {
            if (linha.isEmpty) continue;

            // Garante que tenha 13 colunas preenchidas (com string vazia se necessário)
            final partes = List<String>.from(linha.map((e) => e.toString()));
            while (partes.length < 13) {
              partes.add('');
            }

            final linhaFormatada = partes.join(' | ');

            final registro = {
              'dataPedido': partes[0],
              'tipo': partes[1],
              'quantidade': partes[2],
              'nome': partes[3],
              'tipoConta': partes[4],
              'dataPagamento': partes[5],
              'formaPagamento': partes[6],
              'produto': partes[7],
              'valor': partes[8],
              'vazio': partes[9],
              'email': partes[10],
              'telefone': partes[11],
              'cpfOuCnpj': partes[12],
              'linha': linhaFormatada,
              'sheet': sheet,
            };

            await DBHelper.inserirRegistro(
              registro.map((key, value) => MapEntry(key, value.toString())),
            );
            // }
          }
        }
      }

      /// 🧠 Agora buscamos os sheetIds e atualizamos no banco
      final sheetsComIds = await obterSheetIDComIds(
          spreadsheetId, apiKey); // já está neste provider

      for (final aba in sheetsComIds) {
        final nome = aba['title'];
        final id = aba['sheetId'].toString();
        await DBHelper.atualizarSheetIdPorNome(nome, id);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------- API NOVA --------------------------

  Future<List<Map<String, dynamic>>> buscarPorTermoNovo(String filtro) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clientes/buscar/email?email=$filtro'),
      );

      log('Buscando clientes com filtro: $filtro');
      log('URL: ${response.request?.url}');
      log('Status Code: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        // Aqui você decide se retorna objetos ou mapas
        return data
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      } else {
        log('Erro ao buscar clientes (status ${response.statusCode})');
        return [];
      }
    } catch (e) {
      log('Erro ao buscar clientes: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> buscarComprasPorCliente(
      int clienteId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cc/$clienteId'), // seu endpoint Laravel
        headers: {'Content-Type': 'application/json'},
      );

      log('Buscando compras do cliente $clienteId');
      log('URL: ${response.request?.url}');
      log('Status Code: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      } else {
        log('Erro ao buscar compras do cliente (status ${response.statusCode})');
        return [];
      }
    } catch (e) {
      log('Erro ao buscar compras do cliente: $e');
      return [];
    }
  }

  Future<String> buscarProdutos(int clientId) async {
    return await DBApiHelper.buscarProdutos(clientId);
  }

  Future<void> inserirCompras(Map<String, dynamic> compras) async {
    await DBApiHelper.inserirCompras(compras);
  }

  Future<void> atualizarClientes(Map<String, dynamic> compras) async {
    await DBApiHelper.atualizarClientes(compras);
  }

  Future<Map<String, dynamic>?> buscarCliente(int id) async {
    final cliente = await DBApiHelper.buscarCliente(id);
    if (cliente != null) {
      log('Cliente encontrado: $cliente');
      return cliente;
    } else {
      log('Cliente não encontrado com ID: $id');
      return null;
    }
  }

  Future<Map<String, dynamic>> inserirClientes(
    Map<String, dynamic> cliente,
  ) async {
    final String email = cliente['email'];

    // 1️⃣ Verificar se já existe cliente com este email
    final verificaResponse = await http.get(
      Uri.parse('$baseUrl/clientes/buscar/email?email=$email'),
      headers: {'Content-Type': 'application/json'},
    );

    if (verificaResponse.statusCode == 200) {
      if (verificaResponse.body.isNotEmpty) {
        final decoded = json.decode(verificaResponse.body);

        if (decoded is Map<String, dynamic> && decoded.isNotEmpty) {
          return {
            'status': 'error',
            'message': 'Já existe um cliente cadastrado com este email.',
          };
        } else if (decoded is List && decoded.isNotEmpty) {
          return {
            'status': 'error',
            'message': 'Já existe um cliente cadastrado com este email.',
          };
        }
      }
    } else {
      return {
        'status': 'error',
        'message': 'Erro ao verificar cliente existente.',
      };
    }

    // 2️⃣ Inserir cliente
    log('Inserindo cliente: $cliente');
    final response = await http.post(
      Uri.parse('$baseUrl/clientes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cliente),
    );

    // 3️⃣ Tratar respostas
    if (response.statusCode == 201) {
      if (response.body.isEmpty) {
        return {
          'status': 'error',
          'message': 'Servidor não retornou dados do cliente inserido.',
        };
      }

      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        log('Cliente inserido: $decoded');
        await DBApiHelper.inserirCliente(decoded);
        decoded['status'] = 'success';
        return decoded;
      } else {
        return {
          'status': 'error',
          'message': 'Formato inesperado na resposta do servidor.',
        };
      }
    } else {
      if (response.body.isNotEmpty) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          decoded['status'] = 'error';
          return decoded;
        }
      }
      return {
        'status': 'error',
        'message': 'Falha ao inserir cliente.',
      };
    }
  }

  Future<Map<String, dynamic>> atualizarCliente(
      Map<String, dynamic> cliente) async {
    final response = await http.put(
      Uri.parse('$baseUrl/clientes/${cliente['id']}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cliente),
    );

    log('Atualizando cliente: ${cliente['id']}');
    log('Response: ${response.body}');
    if (response.statusCode == 404) {
      log('Cliente não encontrado: ${cliente['id']}');
      return {'status': 'error', 'message': 'Cliente não encontrado'};
    }

    if (response.statusCode != 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      data['status'] = 'error';
      return data;
    }

    final Map<String, dynamic> data = json.decode(response.body);
    // Atualiza o banco de dados local
    await DBApiHelper.inserirCliente(data);

    data['status'] = 'success';

    return data;
  }

  Future<Map<String, dynamic>> salvarVenda({
    required int cliente,
    required int produto,
    required double valor,
    required DateTime dataPedido,
    required DateTime? dataEntrega,
    required String? pagamentoId,
    required String? entrega,
    required String? pedido,
    String? observacoes,
    double? correios,
  }) async {
    final venda = {
      'client_id': cliente,
      'produto_id': produto,
      'valor': valor.toStringAsFixed(2),
      'correios': correios,
      'pagamento_id': pagamentoId,
      'entrega': entrega,
      'pedido': pedido,
      'data_pedido': dataPedido.toIso8601String(),
      'data_postagem': dataEntrega?.toIso8601String(),
      'observacao	': observacoes,
    };

    log('Salvando venda: $venda');

    final response = await http.post(
      Uri.parse('$baseUrl/compras'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(venda),
    );

    if (response.statusCode == 201) {
      log('Venda salva com sucesso');
      // Aqui você pode atualizar o banco de dados local se necessário
    } else {
      log('Erro ao salvar venda: ${response.body}');
      throw Exception('Erro ao salvar venda');
    }

    return json.decode(response.body);
  }

  Future<void> iniciarProcessodeVendas(int vendaId, int status,
      {DateTime? dataComeco, DateTime? dataEntraga}) async {
    print(
        'Iniciando processo de vendas para vendaId: $vendaId com status: $status');

    final processo = {
      'compra_id': vendaId,
      'estados_id': status,
      'data_comeco': dataComeco?.toIso8601String(),
      'data_fim': dataEntraga?.toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/compraprocessamento'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(processo),
      );

      if (response.statusCode == 201) {
        log('Processamento iniciado com sucesso');
        // Aqui você pode atualizar o banco de dados local se necessário
      } else {
        log('Erro ao iuniciar processo: ${response.body}');
        throw Exception('Erro ao iniciar processo');
      }
    } catch (e) {
      log('Erro ao iniciar processo de vendas: $e');
    }
  }

  // Funcao que busque os clientes que estão com o processo de vendas iniciado
  Stream<List<Map<String, dynamic>>> buscarProcessosIniciadosStream(
      Duration intervalo) async* {
    while (true) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/compraprocessamento'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          yield data.map((e) => e as Map<String, dynamic>).toList();
        } else {
          yield [];
        }
      } catch (e) {
        yield [];
      }

      await Future.delayed(intervalo);
    }
  }

  // Funcao que busque o valor total de vendas por mes
  Future<Map<String, double>> buscarVendasPorMes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/valortotal'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        log('Vendas por mês: $data');
        return data.map((key, value) => MapEntry(key, value.toDouble()));
      } else {
        log('Erro ao buscar vendas por mês: ${response.body}');
        throw Exception('Erro ao buscar vendas por mês');
      }
    } catch (e) {
      log('Erro ao buscar vendas por mês: $e');
      return {};
    }
  }

  // funcao que busca aumento de clientes novos por mes
  Future<Map<String, dynamic>> buscarClientesNovosPorMes() async {
    // final stopwatch = Stopwatch()..start(); // Inicia o timer

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clientesnovos?tipo=total'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // stopwatch.stop(); // Para o timer
        // log('Contagem: $data');
        // log('Tempo de execução: ${stopwatch.elapsedMilliseconds} ms');

        return data;
      } else {
        // stopwatch.stop();
        log('Erro ao buscar clientes: ${response.body}');
        // log('Tempo de execução (com erro): ${stopwatch.elapsedMilliseconds} ms');
        throw Exception('Erro ao buscar clientes');
      }
    } catch (e) {
      // stopwatch.stop();
      log('Erro ao buscar clientes: $e');
      // log('Tempo de execução (com exceção): ${stopwatch.elapsedMilliseconds} ms');
      return {};
    }
  }

  //funcao que busca os clientes que não compraram há mais de 12 meses
  Future<List<Map<String, dynamic>>>
      buscarClientesSemComprasHaMaisDe12Meses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clientespassados'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        log('Clientes sem compras há mais de 12 meses: $data');
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        log('Erro ao buscar clientes sem compras: ${response.body}');
        throw Exception('Erro ao buscar clientes sem compras');
      }
    } catch (e) {
      log('Erro ao buscar clientes sem compras: $e');
      return [];
    }
  }

  // -------------------------- API NOVA --------------------------
}

Future<List<Map<String, dynamic>>> obterSheetIDComIds(
    String spreadsheetId, String apiKey) async {
  final url =
      'https://sheets.googleapis.com/v4/spreadsheets/$spreadsheetId?key=$apiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List sheets = data['sheets'];

    final sheetID = sheets.map<Map<String, dynamic>>((sheet) {
      return {
        'sheetId': sheet['properties']['sheetId'],
        'title': sheet['properties']['title'],
      };
    }).toList();

    log('SheetId: $sheetID');
    return sheetID;
  } else {
    throw Exception('Erro ao obter SheetID: ${response.body}');
  }
}

final searchProvider = ChangeNotifierProvider<SearchProvider>((ref) {
  return SearchProvider();
});

// final vendasPorMesProvider = FutureProvider<Map<String, double>>((ref) {
//   final searchProv = ref.watch(searchProvider);
//   return searchProv.buscarVendasPorMes();
// });
// final clientesNovosProvider = FutureProvider<Map<String, int>>((ref) {
//   final searchProv = ref.watch(searchProvider);
//   return searchProv.buscarClientesNovosPorMes();
// });

final refreshTriggerProvider = StateProvider<int>((ref) => 0);

// Vendas por mês depende do gatilho
final vendasPorMesProvider = FutureProvider<Map<String, double>>((ref) {
  final refresh = ref.watch(refreshTriggerProvider); // sempre que mudar, refaz
  final searchProv = ref.watch(searchProvider);
  return searchProv.buscarVendasPorMes();
});

// Clientes novos por mês depende do gatilho
final clientesNovosProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final refresh = ref.watch(refreshTriggerProvider);
  final searchProv = ref.watch(searchProvider);
  return searchProv.buscarClientesNovosPorMes();
});
