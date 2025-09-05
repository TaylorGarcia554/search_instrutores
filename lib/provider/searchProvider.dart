import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:search_instrutores/models/dbHelperNew.dart';

class SearchProvider extends ChangeNotifier {
  final String _searchQuery = '';

  String get searchQuery => _searchQuery;

  static const baseUrl = 'http://app.autoescolaonline.net/api';

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
    return await DBApiHelper.buscarProdutos(
        clientId); // TODO: Trocar para fazer uma requisicao HTTP
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

  // Funcao que busca os dados do gráfico
  Future<List<Map<String, dynamic>>> buscarDadosGrafico() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/valortotal12meses'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        log('Dados do gráfico: $data');
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        log('Erro ao buscar dados do gráfico: ${response.body}');
        throw Exception('Erro ao buscar dados do gráfico');
      }
    } catch (e) {
      log('Erro ao buscar dados do gráfico: $e');
      return [];
    }
  }

  // Funcao que atualiza o status do processamento
  Future<void> atualizarStatusProcessamento(
    int processamentoId,
    int status,
    {DateTime? dataFim}
  ) async {
    final atualizacao = {
      'estados_id': status,
      'data_fim': dataFim?.toIso8601String(),
    };

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/compraprocessamento/$processamentoId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(atualizacao),
      );

      if (response.statusCode == 200) {
        log('Status do processamento atualizado com sucesso');
        // Aqui você pode atualizar o banco de dados local se necessário
      } else {
        log('Erro ao atualizar status do processamento: ${response.body}');
        throw Exception('Erro ao atualizar status do processamento');
      }
    } catch (e) {
      log('Erro ao atualizar status do processamento: $e');
    }
  }

  // Funcao que atualiza a venda
  Future<void> atualizarVenda(
      int vendaId, Map<String, dynamic> dadosAtualizados) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/compras/$vendaId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dadosAtualizados),
      );

      if (response.statusCode == 200) {
        log('Venda atualizada com sucesso');
        // Aqui você pode atualizar o banco de dados local se necessário
      } else {
        log('Erro ao atualizar venda: ${response.body}');
        throw Exception('Erro ao atualizar venda');
      }
    } catch (e) {
      log('Erro ao atualizar venda: $e');
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

final refreshTriggerProvider = StateProvider<int>((ref) => 0);

// Vendas por mês depende do gatilho
final vendasPorMesProvider = FutureProvider<Map<String, double>>((ref) {
  final refresh = ref.watch(refreshTriggerProvider);
  final searchProv = ref.watch(searchProvider);
  return searchProv.buscarVendasPorMes();
});

// Clientes novos por mês depende do gatilho
final clientesNovosProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final refresh = ref.watch(refreshTriggerProvider);
  final searchProv = ref.watch(searchProvider);
  return searchProv.buscarClientesNovosPorMes();
});

final buscarDadosGrafico = FutureProvider<List<Map<String, dynamic>>>((ref) {
  final searchProv = ref.watch(searchProvider);
  return searchProv.buscarDadosGrafico();
});

class SearchNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final Ref ref;

  SearchNotifier(this.ref) : super([]);

  Future<List<Map<String, dynamic>>> buscarPorTermoNovo(String query) async {
    // aqui entra sua lógica real de busca, por exemplo chamando uma API
    print("Buscando por: $query");

    final resposta =
        await ref.read(searchProvider.notifier).buscarPorTermoNovo(query);

    state = resposta; // atualiza o estado
    return resposta; // retorna a lista também
  }
}

final cadeProvider =
    StateNotifierProvider<SearchNotifier, List<Map<String, dynamic>>>(
  (ref) => SearchNotifier(ref),
);

final produtoFutureProvider =
    FutureProvider.family<String, int>((ref, produtoId) {
  return ref.read(searchProvider).buscarProdutos(produtoId);
});
