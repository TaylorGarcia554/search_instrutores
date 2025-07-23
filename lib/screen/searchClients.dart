import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/components/resultadosSearch.dart';
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

  final meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro'
  ];

  //  String mesSelecionado = meses[DateTime.now().month - 1];
  // List<String> sheetNames = meses;

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

    return Hero(
      tag: 'pesquisar',
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
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
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Aqui pode voltar com o dropdown se quiser
                  ],
                ),
                const SizedBox(height: 16),

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
