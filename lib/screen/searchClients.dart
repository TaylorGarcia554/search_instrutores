import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/components/resultadosSearchNovo.dart';
import 'package:search_instrutores/provider/searchProvider.dart';
import 'package:search_instrutores/screen/profileDetails.dart';

class SearchClientsScreen extends ConsumerStatefulWidget {
  const SearchClientsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchClientsScreen> createState() =>
      _SearchClientsScreenState();
}

class _SearchClientsScreenState extends ConsumerState<SearchClientsScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> resultados = [];

  bool checkBox12meses = false;

  @override
  Widget build(BuildContext context) {
    print("Resultado atual: ${resultados.length}");

    void pesquisarClientes(String query) async {
      // lógica para filtrar/pesquisar
      print("Buscando: $query");
      final resposta =
          await ref.read(searchProvider.notifier).buscarPorTermoNovo(query);

      setState(() {
        resultados = resposta;
      });

      print("Buscando: $resposta");
    }

    void compradosHaMaisDe12Meses() async {
      // lógica para buscar clientes que não compraram nos últimos 12 meses
      final resposta = await ref
          .read(searchProvider.notifier)
          .buscarClientesSemComprasHaMaisDe12Meses();

      setState(() {
        resultados = resposta;
      });

      print("Clientes sem compras há mais de 12 meses: $resposta");
    }

    return Hero(
      tag: 'pesquisar',
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Campo de busca
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _controller,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.search,
                        onFieldSubmitted: (value) {
                          pesquisarClientes(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Digite o Nome ou o Email',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Aqui pode voltar com o dropdown se quiser
                  ],
                ),
                const SizedBox(height: 16),

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
                            value:
                                checkBox12meses, // trocar por variável de estado
                            onChanged: (value) {
                              setState(() {
                                checkBox12meses =
                                    value ?? false; // atualiza o estado
                              });
                              if (value == true) {
                                // Se marcado, chamar a função que busca clientes sem compras há +12 meses
                                compradosHaMaisDe12Meses();
                              } else {
                                // Se desmarcado, limpar os resultados ou aplicar outro filtro
                                setState(() {
                                  resultados = [];
                                });
                              }
                              
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

                // AQUI É A LISTA DE RESULTADOS
                Expanded(
                  child: ListView.builder(
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
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color:
                                Theme.of(context).colorScheme.surfaceContainer,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            titleTextStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
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
          ),
        ),
      ),
    );
  }
}
