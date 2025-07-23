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
      height: 50,
      width: double.infinity,
      
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              width: size.width * 0.2,
              child: Text(
                nome,
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
              child: Text(
                email,
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
              width: size.width * 0.2,
              child: Text(
                format.formatCPFNumber(cpf),
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
              width: size.width * 0.2,
              child: Text(
                format.formatPhoneNumber(telefone),
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
