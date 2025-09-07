import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:search_instrutores/components/showMessager.dart';

class ExportarCsvModal extends StatefulWidget {
  const ExportarCsvModal({super.key});

  @override
  State<ExportarCsvModal> createState() => _ExportarCsvModalState();
}

class _ExportarCsvModalState extends State<ExportarCsvModal> {
  DateTime? dataInicio;
  DateTime? dataFim;
  bool exportarVendas = true;
  bool exportarClientes = false;

  final formatoData = DateFormat('dd/MM/yyyy', 'pt_BR');

  Future<void> selecionarDataInicio() async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // cor do dia selecionado
              onPrimary: Colors.white, // cor do texto do dia selecionado
              onSurface: Colors.black, // cor dos dias não selecionados
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // cor dos botões OK/CANCEL
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (data != null) setState(() => dataInicio = data);
  }

  Future<void> selecionarDataFim() async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // cor do dia selecionado
              onPrimary: Colors.white, // cor do texto do dia selecionado
              onSurface: Colors.black, // cor dos dias não selecionados
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // cor dos botões OK/CANCEL
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (data != null) setState(() => dataFim = data);
  }

  Future<void> baixarCsv(BuildContext context, DateTime? dataInicio,
      DateTime? dataFim, bool exportarVendas) async {
    if (dataInicio == null || dataFim == null) {
      showCustomMessage(
        context,
        "Seleciona um período válido",
        type: MessageType.info,
      );
      return;
    }

    String tipo = exportarVendas ? "vendas" : "clientes";
    String url =
        "http://app.autoescolaonline.net/api/export/$tipo?inicio=${dataInicio.toIso8601String()}&fim=${dataFim.toIso8601String()}";

    try {
      // Diretório do app (Downloads em Android, Documents em iOS)
      Directory dir = await getApplicationDocumentsDirectory();
      String filePath =
          "${dir.path}/$tipo-${DateTime.now().millisecondsSinceEpoch}.csv";

      Dio dio = Dio();
      await dio.download(url, filePath);

      showCustomMessage(
        context,
        "Baixando arquivo...",
        type: MessageType.warning,
        duration: const Duration(seconds: 2),
      );

      // 👉 Se quiser abrir automaticamente o CSV
      await OpenFilex.open(
          filePath); // TODO: Trocar esse showCustom aqui para ficar independente, e aii mostrar quando for baixado.

      Navigator.pop(context); // Fecha o modal após o download
    } catch (e) {
      log("Erro ao baixar CSV: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text("Exportar CSV"),
      backgroundColor: Theme.of(context).cardColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Seleção de datas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: selecionarDataInicio,
                child: Text(
                  dataInicio == null
                      ? "Data início"
                      : formatoData.format(dataInicio!),
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              TextButton(
                onPressed: selecionarDataFim,
                child: Text(
                  dataFim == null ? "Data fim" : formatoData.format(dataFim!),
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Checkboxes
          CheckboxListTile(
            title: const Text("Vendas"),
            value: exportarVendas,
            onChanged: (val) {
              setState(() {
                exportarVendas = val ?? false;
                if (exportarVendas) exportarClientes = false;
              });
            },
          ),
          CheckboxListTile(
            title: const Text("Clientes"),
            value: exportarClientes,
            onChanged: (val) {
              setState(() {
                exportarClientes = val ?? false;
                if (exportarClientes) exportarVendas = false;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancelar",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            baixarCsv(context, dataInicio, dataFim, exportarVendas);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: const Text("Baixar"),
        ),
      ],
    );
  }
}
