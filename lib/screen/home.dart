import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/models/cliente.dart';
import 'package:search_instrutores/provider/searchProvider.dart';
import 'package:search_instrutores/screen/home/cardValue.dart';
import 'package:search_instrutores/screen/newClient.dart';
import 'package:search_instrutores/screen/newSale.dart';
import 'package:search_instrutores/screen/searchClients.dart';
import 'package:search_instrutores/components/buttons.dart';
import 'package:search_instrutores/components/cardClients.dart';
import 'package:search_instrutores/utils/cor.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<CompraProcessamento> listaDeComprasProcessando = [];

  @override
  void initState() {
    super.initState();
    // Adicione inicializações aqui se necessário
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                        Hero(
                          tag: 'novaVenda',
                          child: ButtonsWidget(
                              text: '| Nova Venda',
                              icon: Icons.add_shopping_cart,
                              onPressed: () async {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const NewSale(),
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
                                        const Duration(milliseconds: 400),
                                  ),
                                );
                              }),
                        ),
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
                      offset: const Offset(0, 4), // sombra para baixo
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        'Aguardando Entrega',
                        style: TextStyle(
                          fontSize: size.width * 0.011,
                          color: Cor.texto,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Expanded(
                    //   child: ListView.builder(
                    //     padding: const EdgeInsets.all(8),
                    //     itemCount:
                    //         listaDeComprasProcessando.length, // lista de dados
                    //     itemBuilder: (context, index) {
                    //       return Padding(
                    //         padding: const EdgeInsets.symmetric(vertical: 6),
                    //         child: CardClients(
                    //           cliente: listaDeComprasProcessando[
                    //               index], // passe dados pro card
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                    Expanded(
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: SearchProvider().buscarProcessosIniciadosStream(
                            const Duration(seconds: 60)),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return const Center(
                                child: Text('Erro ao carregar dados'));
                          }

                          final dados = snapshot.data ?? [];

                          if (dados.isEmpty) {
                            return const Center(
                                child: Text('Todas vendas entregues!'));
                          }

                          final listaDeComprasProcessando = dados
                              .map((e) => CompraProcessamento.fromJson(e))
                              .toList();

                          return ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: listaDeComprasProcessando.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: CardClients(
                                  cliente: listaDeComprasProcessando[index],
                                ),
                              );
                            },
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
