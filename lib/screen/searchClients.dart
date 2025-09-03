import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/components/resultadosSearchNovo.dart';
import 'package:search_instrutores/provider/searchProvider.dart';
import 'package:search_instrutores/screen/profileDetails.dart';
import 'package:search_instrutores/utils/cor.dart';

// class SearchClientsScreen extends ConsumerStatefulWidget {
class SearchClientsScreen extends ConsumerWidget {
  SearchClientsScreen({super.key});

//   @override
//   ConsumerState<SearchClientsScreen> createState() =>
//       _SearchClientsScreenState();
// }

// class _SearchClientsScreenState extends ConsumerState<SearchClientsScreen> {
  // final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> resultados = [];

  bool checkBox12meses = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("Resultado atual: ${resultados.length}");

    resultados = ref.watch(cadeProvider);

    return Scaffold(
      body: Column(
        children: [
          ExpansionTile(
            title: const Text(
              'Filtros',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Data inicial',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now()
                                    .subtract(const Duration(days: 30)),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                // TODO: salvar picked em uma variável de estado (ex: dataInicial)
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Data final',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                // TODO: salvar picked em uma variável de estado (ex: dataFinal)
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ✅ Filtro pré-definido: +12 meses sem compras
                    CheckboxListTile(
                      value: checkBox12meses, // trocar por variável de estado
                      onChanged: (value) {
                        // setState(() {
                        //   checkBox12meses =
                        //       value ?? false; // atualiza o estado
                        // });
                        // if (value == true) {
                        //   // Se marcado, chamar a função que busca clientes sem compras há +12 meses
                        //   compradosHaMaisDe12Meses();
                        // } else {
                        //   // Se desmarcado, limpar os resultados ou aplicar outro filtro
                        //   setState(() {
                        //     resultados = [];
                        //   });
                        // }
                      },
                      title: const Text(
                          'Clientes há mais de 12 meses sem compras'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),

                    const SizedBox(height: 16),

                    // 🔎 Botão para aplicar filtros
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: aplicar filtros
                          // - Se datas selecionadas: enviar pro servidor
                          // - Se checkbox true: usar a query especial
                        },
                        icon: const Icon(Icons.filter_alt),
                        label: const Text("Aplicar filtros"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                ),
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Cliente',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Email',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Última compra',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Contato',
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),

          // AQUI É A LISTA DE RESULTADOS
          Expanded(
            child: resultados.isEmpty
                ? const Center(child: Text("Nenhum resultado"))
                : ListView.builder(
                    itemCount: resultados.length,
                    itemBuilder: (context, index) {
                      final item = resultados[index];

                      final id = item['id'] ?? 0;
                      final nome = item['nome'] ?? '';
                      final cpf = item['cpf'] ?? '';
                      final valor = item['valor'] ?? '';
                      final email = item['email'] ?? '';
                      final telefone = item['telefone'] ?? '';
                      final observacao = item['observacao'] ?? '';

                      final backgroundColor = index % 2 == 0
                          ? Theme.of(context).scaffoldBackgroundColor
                          : Theme.of(context).colorScheme.surfaceContainer;

                      return InkWell(
                        onTap: () {
                          // Aqui você pode definir o que acontece ao clicar no item
                          print('Item clicado: $id');
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ProfileDetails(
                                profileId: id,
                                nome: nome,
                                cpf: cpf,
                                email: email,
                                telefone: telefone,
                                observacao: observacao);
                          }));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            // borderRadius: BorderRadius.circular(8),
                            color: backgroundColor,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            titleTextStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            subtitle: ResultadosSearchNovo(
                              nome: nome,
                              cpf: cpf,
                              valor: valor,
                              email: email,
                              telefone: telefone,
                              id: id,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
