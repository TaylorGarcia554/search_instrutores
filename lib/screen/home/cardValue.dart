import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/provider/searchProvider.dart';
import 'package:search_instrutores/utils/cor.dart';
import 'package:intl/intl.dart';

class CardValue extends ConsumerWidget {
  const CardValue({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    final valorTotal = ref.watch(vendasPorMesProvider);
    final novosClientes = ref.watch(clientesNovosProvider);

    print('Valor Total: $novosClientes');

    final formatoMoeda = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return Container(
        height: size.height * 0.15,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(15),
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
          border: Border.all(
            color: Theme.of(context).extension<AppColors>()!.inputBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(120),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(7, 6), // sombra para baixo
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // This is to get a Value of sales made in the month
            Text.rich(
              TextSpan(
                  text: 'Total de Vendas Mensal\n',
                  style: TextStyle(
                      fontSize: size.width * 0.008,
                      fontWeight: FontWeight.bold),
                  children: [
                    valorTotal.when(
                      data: (valor) => TextSpan(
                        text: formatoMoeda.format(valor['total'] ?? 0),
                        style: TextStyle(
                          fontSize: size.width * 0.02,
                        ),
                      ),
                      loading: () => TextSpan(
                        text: '\nCarregando...',
                        style: TextStyle(
                          fontSize: size.width * 0.009,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      error: (err, stack) => TextSpan(
                        text: '\nErro',
                        style: TextStyle(
                          fontSize: size.width * 0.009,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // TextSpan(
                    //   text: '\nR\$ 1.000,00',
                    //   style: TextStyle(
                    //       fontSize: size.width * 0.02,
                    //       color: Cor.texto,
                    //       fontWeight: FontWeight.bold),
                    // ),
                  ]),
            ),
            // The size between the two containers
            SizedBox(
              width: size.width * 0.04,
            ),

            // To get the number of news clients on the month
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text.rich(
                  textAlign: TextAlign.end,
                  TextSpan(
                      text: 'Novos Clientes',
                      style: TextStyle(
                          fontSize: size.width * 0.008,
                          fontWeight: FontWeight.bold),
                      children: [
                        novosClientes.when(
                          data: (valor) => TextSpan(
                            text: '\n ${valor['clientes_novos']}',
                            style: TextStyle(
                              fontSize: size.width * 0.02,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          loading: () => TextSpan(
                            text: '',
                            style: TextStyle(
                              fontSize: size.width * 0.02,
                              color: Cor.texto,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          error: (err, stack) => TextSpan(
                            text: '\nErro',
                            style: TextStyle(
                              fontSize: size.width * 0.02,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ]),
                ),
              ],
            )
          ],
        ));
  }
}
