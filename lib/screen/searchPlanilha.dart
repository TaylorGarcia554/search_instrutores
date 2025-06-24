import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/components/resultadosSearch.dart';
import 'package:search_instrutores/keys/keys.dart';
import 'package:search_instrutores/main.dart';
import 'package:search_instrutores/provider/searchProvider.dart';

class BuscaPlanilhaPage extends ConsumerStatefulWidget {
  const BuscaPlanilhaPage({super.key});

  @override
  BuscaPlanilhaPageState createState() => BuscaPlanilhaPageState();
}

// final secrets = SecretKeysNotifier();

class BuscaPlanilhaPageState extends ConsumerState<BuscaPlanilhaPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> resultados = [];
  List<String> sheetNames = [];

  String spreadsheetId = SecretKeys.spreadsheetId;
  String apiKey = SecretKeys.apiKey;
  String? mesSelecionado;

  void _setAbas() {
    ref
        .read(searchProvider)
        .obterNomesDasAbas(spreadsheetId, apiKey)
        .then((value) {
      setState(() {
        sheetNames = value.reversed.take(30).toList();
        if (sheetNames.isNotEmpty) {
          mesSelecionado = sheetNames.first;
        }
      });
    }).catchError((error) {
      log('Erro ao obter nomes das abas: $error');
    });
  }

  @override
  void initState() {
    _setAbas();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Combo Vendas',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                Switch(
                  value: isDark,
                  onChanged: (value) =>
                      ref.read(themeProvider.notifier).state = value,
                ),
              ]),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Campo de busca ocupando o máximo de espaço
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Digite o Nome ou o Email',
                        prefixIcon: Icon(Icons.search),
                        labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 18),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2.0,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.0,
                          ),
                        ),
                      ),
                      cursorColor: Theme.of(context).colorScheme.primary,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o Nome';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 12), // Espaço entre os dois campos

                  // Dropdown com largura fixa
                  SizedBox(
                    width: 140,
                    child: DropdownButtonFormField<String>(
                      value: sheetNames.contains(mesSelecionado)
                          ? mesSelecionado
                          : null,
                      hint: const Text("Mês"),
                      items: sheetNames.map((mes) {
                        return DropdownMenuItem<String>(
                          value: mes,
                          child: Text(mes),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        log('Mes selecionado: $value');

                        final buscarAtt = await ref
                            .read(searchProvider.notifier)
                            .buscarPorMes(value ?? '');

                        // print(buscarAtt);

                        setState(() {
                          mesSelecionado = value;
                          resultados = buscarAtt;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Consumer(
                  builder: (context, ref, _) {
                    final isLoading = ref.watch(searchProvider).isLoading;
                    final provider = ref.read(searchProvider);

                    return ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              try {
                                _setAbas();

                                final abas = await provider.obterNomesDasAbas(
                                    spreadsheetId, apiKey);
                                setState(() {
                                  sheetNames = abas;
                                });

                                await provider.baixarEArmazenarDados(
                                    spreadsheetId, apiKey, sheetNames);
                              } catch (e) {
                                log('Erro geral: $e');
                              }
                              setState(() {});
                            },
                      style: const ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Color(0xffB71E3F)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              "Atualizar",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    final buscaratt = await ref
                        .read(searchProvider.notifier)
                        .buscarLocalmente(_controller.text);
                    // print(buscaratt);

                    setState(() {
                      // formatarResultado(asyncResult);

                      resultados = buscaratt;
                      // asyncResult;
                    });
                  },
                  style: const ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(Color(0xffB71E3F))),
                  child: const Text(
                    "Buscar",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ]),
              SizedBox(height: 24),
              Expanded(
                  child: ListView.builder(
                itemCount: resultados.length,
                itemBuilder: (context, index) {
                  final item = resultados[index];

                  final id = item['id'] ?? '';
                  final nome = item['nome'] ?? '';
                  final produto = item['produto'] ?? '';
                  final valor = item['valor'] ?? '';
                  final email = item['email'] ?? '';
                  final telefone = item['telefone'] ?? '';
                  final data = item['dataPedido'] ?? '';
                  final sheet = item['sheet'] ?? '';
                  final sheetID = item['sheetId'] ?? 0;
                  final lembrado = item['lembrado'] ?? 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      title: Text(nome),
                      titleTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ResultadosSearch(
                            nome: nome,
                            produto: produto,
                            valor: valor,
                            email: email,
                            telefone: telefone,
                            data: data,
                            sheet: sheet,
                            sheetID: sheetID,
                            id: id,
                            lembrado: lembrado,
                          )
                        ],
                      ),
                    ),
                  );
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}
