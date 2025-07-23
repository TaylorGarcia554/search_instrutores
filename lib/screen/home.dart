import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/models/cliente.dart';
import 'package:search_instrutores/models/sincronizarDadosApi.dart';
import 'package:search_instrutores/provider/searchProvider.dart';
import 'package:search_instrutores/screen/home/cardValue.dart';
import 'package:search_instrutores/screen/newClient.dart';
import 'package:search_instrutores/screen/searchClients.dart';
import 'package:search_instrutores/utils/buttons.dart';
import 'package:search_instrutores/utils/cardClients.dart';
import 'package:search_instrutores/utils/cor.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    final List<Cliente> listaDeClientes = [
      Cliente(
        nome: 'Flavio Junior ( CFC Abrantes )',
        data: '02/07/2024',
        telefone: '(33) 99988-9999',
        diasRestantes: '5 Dias',
      ),
      Cliente(
        nome: 'Maria Silva',
        data: '15/07/2024',
        telefone: '(33) 98877-1234',
        diasRestantes: '10 Dias',
      ),
      Cliente(
        nome: 'Flavio Junior ( CFC Abrantes )',
        data: '02/07/2024',
        telefone: '(33) 99988-9999',
        diasRestantes: '5 Dias',
      ),
      Cliente(
        nome: 'Maria Silva',
        data: '15/07/2024',
        telefone: '(33) 98877-1234',
        diasRestantes: '10 Dias',
      ),
      Cliente(
        nome: 'Flavio Junior ( CFC Abrantes )',
        data: '02/07/2024',
        telefone: '(33) 99988-9999',
        diasRestantes: '5 Dias',
      ),
      Cliente(
        nome: 'Maria Silva',
        data: '15/07/2024',
        telefone: '(33) 98877-1234',
        diasRestantes: '10 Dias',
      ),
      Cliente(
        nome: 'Flavio Junior ( CFC Abrantes )',
        data: '02/07/2024',
        telefone: '(33) 99988-9999',
        diasRestantes: '5 Dias',
      ),
      Cliente(
        nome: 'Maria Silva',
        data: '15/07/2024',
        telefone: '(33) 98877-1234',
        diasRestantes: '10 Dias',
      ),
      // Adicione mais clientes aqui...
    ];

    return Scaffold(
      backgroundColor: Cor.background,
      body: Padding(
        padding: EdgeInsets.all(size.height * 0.08),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CardValue(), // This is the card that shows the value of sales and new clients
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  Container(
                    height: size.height * 0.4,
                    color: Cor.texto,
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Center(
                    child: Wrap(
                      spacing: size.width * 0.01, // espaçamento entre os botões
                      runSpacing:
                          size.height * 0.02, // espaçamento entre linhas
                      children: [
                        Hero(
                          tag: 'pesquisar',
                          child: ButtonsWidget(
                              text: '| Pesquisar',
                              icon: Icons.search,
                              onPressed: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const SearchClientsScreen(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      final curvedAnimation = CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeInOut,
                                      );

                                      return ScaleTransition(
                                        scale: curvedAnimation,
                                        child: child,
                                      );
                                    },
                                    transitionDuration:
                                        const Duration(milliseconds: 300),
                                  ),
                                );
                              }),
                        ),
                        ButtonsWidget(
                            text: '| Nova Venda',
                            icon: Icons.add_shopping_cart,
                            onPressed: () async {
                              final buscaratt = await ref
                                  .read(searchProvider.notifier)
                                  .buscarComprasPorCliente(208);
                              print(buscaratt);
                            }),
                        Hero(
                          tag: 'novoCliente',
                          child: ButtonsWidget(
                              text: '| Novo Cliente',
                              icon: Icons.person_add,
                              onPressed: () async {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const NewClient(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      final curvedAnimation = CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeInOut,
                                      );
                        
                                      return ScaleTransition(
                                        scale: curvedAnimation,
                                        child: child,
                                      );
                                    },
                                    transitionDuration:
                                        const Duration(milliseconds: 300),
                                  ),
                                );
                        
                              }),
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: SincronizadorApiLocal.isLoading2,
                          builder: (context, loading, child) {
                            return ButtonsWidget(
                              icon: Icons.sync,
                              text: '| Atualizar Dados',
                              isLoading: loading,
                              onPressed: () {
                                // chama a função de sincronização
                                SincronizadorApiLocal.sincronizarTodosOsDados();
                              },
                            );
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              width: size.width * 0.05,
            ),
            Expanded(
              flex: 4,
              child: Container(
                height: size.height * 0.9,
                decoration: BoxDecoration(
                  color: Cor.branco,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: Cor.texto,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(120),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4), // sombra para baixo
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        'Instrutores vencendo o Prazo',
                        style: TextStyle(
                          fontSize: size.width * 0.011,
                          color: Cor.texto,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: listaDeClientes.length, // lista de dados
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: CardClients(
                              cliente: listaDeClientes[
                                  index], // passe dados pro card
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
