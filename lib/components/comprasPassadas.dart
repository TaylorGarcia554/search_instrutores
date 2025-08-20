// import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/provider/searchProvider.dart';
import 'package:search_instrutores/utils/formatadorHelpers.dart';
import 'dart:math';

class ComprasPassadas extends ConsumerWidget {
  final int id;
  final String dataCompra;
  final int produto;
  final double valor;
  // final double correios;
  final String entrega;
  final String observacao;

  const ComprasPassadas({
    super.key,
    required this.id,
    required this.dataCompra,
    required this.produto,
    required this.valor,
    required this.entrega,
    // required this.correios,
    required this.observacao,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final double fontSize = min(size.width * 0.012, 18);

    final format = Formatadorhelpers();

    final produtoNome = ref.read(searchProvider).buscarProdutos(produto);

    Widget divisorVertical() {
      return Container(
        width: 1,
        height: double.infinity,
        alignment: Alignment.center,
        child: FractionallySizedBox(
          heightFactor: 0.75,
          child: Container(
            width: 1,
            color: const Color.fromARGB(255, 84, 84, 84),
          ),
        ),
      );
    }

    return SizedBox(
      height: 50,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              width: size.width * 0.069,
              child: Text(
                format.formatData(dataCompra),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          divisorVertical(),
          Center(
            child: SizedBox(
                width: size.width * 0.3,
                child: FutureBuilder<String>(
                  future: produtoNome,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Carregando...');
                    } else if (snapshot.hasError) {
                      return const Text('Erro ao buscar');
                    } else {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Text(
                            snapshot.data ?? 'Produto não encontrado',
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                )),
          ),
          divisorVertical(),
          Center(
            child: SizedBox(
              width: size.width * 0.1,
              child: Text(
                format.formatDinheiro(
                    valor), // vamos usar um outro formato para o valor
                // cpf,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          divisorVertical(),
          Center(
            child: SizedBox(
              width: size.width * 0.13,
              child: Text(
                entrega,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          divisorVertical(),
          Center(
            child: SizedBox(
              width: size.width * 0.25,
              child: Text(
                observacao,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
