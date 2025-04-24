import 'package:flutter/material.dart';

class ResultadosSearch extends StatelessWidget {
  final String nome;
  final String produto;
  final String valor;
  final String email;
  final String telefone;
  final String data;
  final String sheet;

  const ResultadosSearch({
    super.key,
    required this.nome,
    required this.produto,
    required this.valor,
    required this.email,
    required this.telefone,
    required this.data,
    required this.sheet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(
          text: 'Produto: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
          children: [
            TextSpan(
              text: produto,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        )),
        Text.rich(TextSpan(
          text: 'Valor: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
          children: [
            TextSpan(
              text: valor,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        )),
        Text.rich(TextSpan(
          text: 'Email: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
          children: [
            TextSpan(
              text: email,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        )),
        Text.rich(TextSpan(
          text: 'Telefone: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
          children: [
            TextSpan(
              text: telefone,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        )),
        Text.rich(TextSpan(
          text: 'Data da Compra: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
          children: [
            TextSpan(
              text: data,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        )),
        Text.rich(TextSpan(
          text: 'Mês: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
          children: [
            TextSpan(
              text: sheet,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        )),
      ],
    );
  }
}
