// import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/utils/formatadorHelpers.dart';

class ResultadosSearchNovo extends ConsumerWidget {
  final String nome;
  final String cpf;
  final String valor;
  final String email;
  final String telefone;
  final int id;

  const ResultadosSearchNovo({
    super.key,
    required this.nome,
    required this.cpf,
    required this.valor,
    required this.email,
    required this.telefone,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final double fontSize = size.width * 0.012;

    final format = Formatadorhelpers();

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
      height: 70,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome
          Expanded(
            flex: 2, // ocupa 2 partes
            child: Center(
              child: Text(
                nome,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          divisorVertical(),

          // Email (maior)
          Expanded(
            flex: 3, // ocupa 3 partes
            child: Center(
              child: Text(
                email,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          divisorVertical(),

          // CPF
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                format.formatCPFNumber(cpf),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          divisorVertical(),

          // Telefone
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                format.formatPhoneNumber(telefone),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
