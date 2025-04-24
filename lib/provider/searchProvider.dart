import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:search_instrutores/models/dbHelper.dart';

class SearchProvider extends ChangeNotifier {
  String _searchQuery = '';
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
      print('Abas: $nomesDasAbas');

      return nomesDasAbas;
    } else {
      throw Exception('Erro ao obter nomes das abas: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> buscarLocalmente(String termo) async {
    return await DBHelper.buscarPorTermo(termo.toLowerCase());
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
        print('Buscando na aba: $sheet');
        final url =
            'https://sheets.googleapis.com/v4/spreadsheets/$spreadsheetId/values/${Uri.encodeComponent(sheet)}?key=$apiKey';

        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List valores = data['values'];

          for (final linha in valores) {
            final linhaFormatada = linha.join(' | ');

            if (linhaFormatada.trim().isNotEmpty && linha.length >= 13) {
              final partes =
                  linhaFormatada.split(' | ').map((e) => e.trim()).toList();

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
                'cpfOuCnpj': partes[11],
                'telefone': partes[12],
                'linha': linhaFormatada,
                'sheet': sheet,
              };

              await DBHelper.inserirRegistro(
                registro.map((key, value) => MapEntry(key, value.toString())),
              );
            }
          }
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

final searchProvider = ChangeNotifierProvider<SearchProvider>((ref) {
  return SearchProvider();
});

