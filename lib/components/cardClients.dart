import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/provider/searchProvider.dart';
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

    final produtoAsync = ref.watch(produtoFutureProvider(cliente.produto));

    final fomatador = Formatadorhelpers();

    // Verifica se o status é 1 ou 2 para exibir o card
    final int status = cliente.statusProcessamento;
    StatusProcessamento? statusProcessamento =
        StatusProcessamento.getPorId(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.007,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Tooltip(
                message:
                    cliente.nome, // mostra o nome completo ao passar o mouse
                child: SelectableText(
                  cliente.nome.length > 40
                      ? '${cliente.nome.substring(0, 20)}...'
                      : cliente.nome,
                  style: TextStyle(
                    fontSize: size.width * 0.01,
                    color: Cor.texto,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                fomatador.formatData(cliente.data, semAno: true),
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
          SelectableText(
            cliente.telefone,
            style: TextStyle(
              fontSize: size.width * 0.01,
              color: Cor.texto,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: size.height * 0.01),
          SelectableText(
            cliente.email,
            style: TextStyle(
              fontSize: size.width * 0.01,
              color: Cor.texto,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: size.height * 0.01),
          SelectableText(
            produtoAsync.maybeWhen(
              data: (data) => data,
              orElse: () => 'Carregando...',
            ),
            style: TextStyle(
              fontSize: size.width * 0.01,
              color: Cor.texto,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
