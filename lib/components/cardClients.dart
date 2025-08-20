import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/utils/statusProcessamento.dart';
import 'package:search_instrutores/models/cliente.dart';
import 'package:search_instrutores/utils/cor.dart';
import 'package:search_instrutores/utils/formatadorHelpers.dart';

class CardClients extends ConsumerWidget {
  final CompraProcessamento cliente;

  const CardClients({super.key, required this.cliente});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    // Calcular os dias restantes
    final DateTime dataCompra = DateTime.parse(cliente.data);
    final DateTime dataAtual = DateTime.now();
    final Duration diferenca = dataAtual.difference(dataCompra);
    final int diasRestantes = diferenca.inDays;

    final fomatador = Formatadorhelpers();

    // Verifica se o status é 1 ou 2 para exibir o card
    final int status = cliente.statusProcessamento;
    StatusProcessamento? statusProcessamento =
        StatusProcessamento.getPorId(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.02,
        vertical: size.height * 0.009,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: statusProcessamento?.cor ?? Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: statusProcessamento?.corBorda ?? Colors.black,
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
              const Spacer(),
              Text(
                fomatador.formatData(cliente.data),
                // cliente.data,
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
              const Spacer(),
              Text(
                'Comprou a $diasRestantes dias',
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
                cliente.email,
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
