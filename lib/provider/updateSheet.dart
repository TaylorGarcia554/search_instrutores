import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:search_instrutores/keys/keys.dart';

class UpdateSheetProvider extends ChangeNotifier {
  static const _scopes = [SheetsApi.spreadsheetsScope];
  static const _spreadsheetId = SecretKeys.spreadsheetId;

  SheetsApi? _sheetsApi;

  Future<void> _initSheetsApi() async {
    if (_sheetsApi != null) return;

    try {
      final jsonString =
          await rootBundle.loadString('assets/credenciais-google.json');
      final credentials = ServiceAccountCredentials.fromJson(jsonString);

      final client = await clientViaServiceAccount(credentials, _scopes);
      _sheetsApi = SheetsApi(client);
      log('Sheets API inicializada com sucesso.');
    } catch (e) {
      log('Erro ao inicializar Sheets API: $e');
    }
  }

  Future<void> pintarCelula({
    required String sheetId,
    required int rowIndex,
    required int columnIndex,
  }) async {
    await _initSheetsApi();
    if (_sheetsApi == null) {
      log('Sheets API não inicializada.');
      return;
    }

    final request = BatchUpdateSpreadsheetRequest.fromJson({
      "requests": [
        {
          "repeatCell": {
            "range": {
              "sheetId": int.parse(sheetId),
              "startRowIndex": rowIndex,
              "endRowIndex": rowIndex + 1,
              "startColumnIndex": columnIndex,
              "endColumnIndex": columnIndex + 1
            },
            "cell": {
              "userEnteredFormat": {
                "backgroundColor": {"red": 0.0, "green": 1.0, "blue": 0.0}
              }
            },
            "fields": "userEnteredFormat.backgroundColor"
          }
        }
      ]
    });

    try {
      await _sheetsApi!.spreadsheets.batchUpdate(
        request,
        _spreadsheetId,
      );
      log('✅ Célula pintada com sucesso!');
    } catch (e) {
      log('❌ Erro ao pintar célula: $e');
    }
  }

  Future<void> buscarValorEPintar({
    required String aba,
    required String sheetId,
    required String valorProcurado,
    required int colunaIndex,
  }) async {
    await _initSheetsApi();

    final range =
        '$aba!${String.fromCharCode(65 + colunaIndex)}:${String.fromCharCode(65 + colunaIndex)}';
    final response =
        await _sheetsApi!.spreadsheets.values.get(_spreadsheetId, range);

    final values = response.values;
    if (values == null || values.isEmpty) {
      log('Nenhum dado encontrado na coluna especificada.');
      return;
    }

    for (int i = 0; i < values.length; i++) {
      if (values[i].isNotEmpty && values[i][0] == valorProcurado) {
        log('Encontrado na linha ${i + 1}');

        await pintarCelula(
          sheetId: sheetId,
          rowIndex: i,
          columnIndex: colunaIndex,
        );
        return;
      }
    }

    log('Valor não encontrado.');
  }
}

final updateSheetProvider = ChangeNotifierProvider<UpdateSheetProvider>((ref) {
  return UpdateSheetProvider();
});
