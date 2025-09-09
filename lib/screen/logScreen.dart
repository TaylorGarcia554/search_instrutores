import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:search_instrutores/screen/menuHome.dart';

class LogsPage extends ConsumerStatefulWidget {
  @override
  _LogsPageState createState() => _LogsPageState();
}

class _LogsPageState extends ConsumerState<LogsPage> {
  List<String> logs = [];
  Timer? _timer;

  Future<List<String>> fetchLogs() async {
    final response = await http.get(
      Uri.parse('http://app.autoescolaonline.net/api/logs'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['logs']);
    } else {
      throw Exception('Falha ao carregar logs');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadLogs();

    // Atualiza a cada 5 segundos
    _timer = Timer.periodic(Duration(seconds: 5), (_) {
      _loadLogs();
    });
  }

  Future<void> _loadLogs() async {
    try {
      final newLogs = await fetchLogs();
      setState(() {
        logs = newLogs;
      });
    } catch (e) {
      print("Erro ao buscar logs: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget showLogs(BuildContext context, index) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.black87, // fundo geral do painel
      child: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];

          // Tenta separar hora do texto
          final regex = RegExp(r'^\[(.*?)\]\s*(.*)$');
          String hora = '';
          String texto = log;
          final match = regex.firstMatch(log);
          if (match != null) {
            hora = match.group(1)!;
            texto = match.group(2)!;
          }

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[900], // fundo do “quadrado”
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.greenAccent, width: 1.5),
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: hora.isNotEmpty ? "[$hora] " : "",
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  TextSpan(
                    text: texto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Logs do Sistema"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.black87, // fundo geral do painel
        child: ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];

            // Tenta separar hora do texto
            final regex = RegExp(r'^\[(.*?)\]\s*(.*)$');
            String hora = '';
            String texto = log;
            final match = regex.firstMatch(log);
            if (match != null) {
              hora = match.group(1)!;
              texto = match.group(2)!;
            }

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[900], // fundo do “quadrado”
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.greenAccent, width: 1.5),
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: hora.isNotEmpty ? "[$hora] " : "",
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    TextSpan(
                      text: texto,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
