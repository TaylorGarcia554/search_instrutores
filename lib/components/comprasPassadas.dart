// import 'dart:developer';

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/components/newSale/buscarClientes.dart';
import 'package:search_instrutores/provider/searchProvider.dart';
import 'package:search_instrutores/screen/newSale.dart';
import 'package:search_instrutores/utils/formatadorHelpers.dart';
import 'dart:math';

class ComprasPassadas extends ConsumerWidget {
  final int id;
  final String dataCompra;
  final int produto;
  final double valor;
  final double? correios;
  final String entrega;
  final String observacao;
  final String pagamentoId;
  final String pedido;
  // final String cliente;

  const ComprasPassadas({
    super.key,
    required this.id,
    required this.dataCompra,
    required this.produto,
    required this.valor,
    required this.entrega,
    this.correios,
    required this.observacao,
    required this.pagamentoId,
    required this.pedido,
    // required this.cliente,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final double fontSize = min(size.width * 0.012, 18);

    final format = Formatadorhelpers();

    final produtoNome = ref.read(searchProvider).buscarProdutos(produto);

    // final clientes = ref.read(searchProvider).buscarCliente(cliente as int);

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
          Expanded(
            flex: 1, // data
            child: Center(
              child: SelectableText(
                format.formatData(dataCompra),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          divisorVertical(),
          Expanded(
            flex: 3, // produto
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
                      child: SelectableText(
                        snapshot.data ?? 'Produto não encontrado',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          divisorVertical(),
          Expanded(
            flex: 1, // valor
            child: Center(
              child: SelectableText(
                format.formatDinheiro(valor),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          divisorVertical(),
          Expanded(
            flex: 2, // entrega
            child: Center(
              child: SelectableText(
                entrega,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          divisorVertical(),
          Expanded(
            flex: 1, // pedido
            child: Center(
              child: SelectableText(
                pedido,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          divisorVertical(),
          Expanded(
            flex: 1, // pagamento
            child: Center(
              child: SelectableText(
                pagamentoId,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          divisorVertical(),
          Expanded(
            flex: 3, // observacao
            child: Center(
              child: SelectableText(
                observacao,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // divisorVertical(),
          // Expanded(
          //   flex: 1, // observacao
          //   child: Center(
          //       child: ElevatedButton(
          //     onPressed: () async {
          //       // final clienteMap = await ref
          //       //     .read(searchProvider)
          //       //     .buscarCliente(cliente as int);

          //       // if (clienteMap != null) {
          //       //   final clienteSelecionado = Cliente.fromJson(clienteMap);

          //         Navigator.of(context).pushReplacement(
          //           MaterialPageRoute(
          //               builder: (context) => NewSale(
          //                     id: id,
          //                     dataPedido: DateTime.parse(dataCompra),
          //                     // dataEntrega: DateTime.parse(dataCompra),
          //                     produtoSelecionado: produto,
          //                     valorReal: valor,
          //                     entrega: entrega,
          //                     valorCorreios: correios ?? 0.0,
          //                     observacoes: observacao,
          //                     pagamentoId: pagamentoId,
          //                     // clienteSelecionado: clienteSelecionado,
          //                     pedido: pedido,
          //                     metodo: 'editar',
          //                   )),
          //         );
          //       // } else {
          //       //   // Lidar com o caso onde o cliente não foi encontrado
          //       //   ScaffoldMessenger.of(context).showSnackBar(
          //       //     const SnackBar(content: Text('Cliente não encontrado')),
          //       //   );
          //       // }
          //     },
          //     child: const Icon(Icons.edit_note),
          //   )),
          // ),
        ],
      ),
    );
  }
}
