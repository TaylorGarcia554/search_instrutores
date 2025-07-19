import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/models/cliente.dart';
import 'package:search_instrutores/utils/cor.dart';


class CardClients extends ConsumerWidget {
  final Cliente cliente;
  const CardClients({Key? key, required this.cliente}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.02,
        vertical: size.height * 0.009,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 226, 132, 132),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: const Color.fromARGB(255, 183, 0, 0),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SelectableText(
                cliente.nome,
                style: TextStyle(
                  fontSize: size.width * 0.01,
                  color: Cor.texto,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text(
                cliente.data,
                style: TextStyle(
                  fontSize: size.width * 0.01,
                  color: Cor.texto,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          Row(
            children: [
              SelectableText(
                cliente.telefone,
                style: TextStyle(
                  fontSize: size.width * 0.01,
                  color: Cor.texto,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text(
                cliente.diasRestantes,
                style: TextStyle(
                  fontSize: size.width * 0.01,
                  color: Cor.texto,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
