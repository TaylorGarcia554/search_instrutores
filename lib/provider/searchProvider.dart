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
