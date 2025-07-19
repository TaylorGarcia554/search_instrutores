import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/utils/cor.dart';

class CardValue extends ConsumerWidget {
  const CardValue({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return Container(
        height: size.height * 0.15,
        decoration: BoxDecoration(
          color: Cor.branco,
          borderRadius: BorderRadius.circular(10),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // TODO: lembrar de colocar esse valor dinamico.

            // This is to get a Value of sales made in the month
            Text.rich(
              TextSpan(
                  text: 'Total de Vendas Mensal',
                  style: TextStyle(
                      fontSize: size.width * 0.008,
                      color: Cor.texto,
                      fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: '\nR\$ 1.000,00',
                      style: TextStyle(
                          fontSize: size.width * 0.02,
                          color: Cor.texto,
                          fontWeight: FontWeight.bold),
                    ),
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
                          color: Cor.texto,
                          fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: '\n10',
                          style: TextStyle(
                              fontSize: size.width * 0.02,
                              color: Cor.texto,
                              fontWeight: FontWeight.bold),
                        ),
                      ]),
                ),
              ],
            )
          ],
        ));
  }
}
