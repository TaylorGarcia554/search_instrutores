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

  static const baseUrl =
      'http://app.autoescolaonline.net/api'; // troque pela sua URL real

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

  Future<List<Map<String, dynamic>>> buscarPorTermoNovo(String anoMes) async {
    return await DBApiHelper.buscarPorTermoNovo(anoMes);
  }

  Future<List<Map<String, dynamic>>> buscarComprasPorCliente(
      int clientId) async {
    return await DBApiHelper.buscarComprasPorCliente(clientId);
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
      Map<String, dynamic> cliente) async {
    // TODO: VERIFICAR SE O CLIENTE JA EXISTE PRIMEIRO, ANTES DE JA SAIR SALVANDO NO BANCO DE DADOS
    log('Inserindo cliente: $cliente');
    final response = await http.post(
      Uri.parse('$baseUrl/clientes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cliente),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      log('Cliente inserido: $data');
      // Atualiza o banco de dados local
      await DBApiHelper.inserirCliente(data);
      // Notifica os ouvintes sobre a mudança
      data['status'] = 'success';
      return data;
    } else {
      final Map<String, dynamic> data = json.decode(response.body);
      data['status'] = 'error';
      return data;
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
      log('Erro ao atualizar cliente: ${data}');
      data['status'] = 'error';
      return data;
    }

    final Map<String, dynamic> data = json.decode(response.body);
    // Atualiza o banco de dados local
    await DBApiHelper.inserirCliente(data);

    data['status'] = 'success';

    return data;
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
