import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/components/inputs.dart';
import 'package:search_instrutores/components/newSale/campoMonetario.dart';
import 'package:search_instrutores/provider/searchProvider.dart';
import 'package:search_instrutores/utils/statusProcessamento.dart';
import 'package:search_instrutores/models/cliente.dart';
import 'package:search_instrutores/utils/cor.dart';
import 'package:search_instrutores/utils/formatadorHelpers.dart';

class CardClients extends ConsumerWidget {
  final CompraProcessamento compra;

  const CardClients({super.key, required this.compra});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    final produtoAsync = ref.watch(produtoFutureProvider(compra.produto));

    final fomatador = Formatadorhelpers();

    // Verifica se o status é 1 ou 2 para exibir o card
    final int status = compra.statusProcessamento;
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
                    compra.nome, // mostra o nome completo ao passar o mouse
                child: SelectableText(
                  compra.nome.length > 40
                      ? '${compra.nome.substring(0, 20)}...'
                      : compra.nome,
                  style: TextStyle(
                    fontSize: size.width * 0.01,
                    color: Cor.texto,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                fomatador.formatData(compra.data, semAno: true),
                // compra.data,
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
            compra.telefone,
            style: TextStyle(
              fontSize: size.width * 0.01,
              color: Cor.texto,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: size.height * 0.01),
          SelectableText(
            compra.email,
            style: TextStyle(
              fontSize: size.width * 0.01,
              color: Cor.texto,
              fontWeight: FontWeight.bold,
            ),
          ),
          ExpansionTileTheme(
            data: const ExpansionTileThemeData(
              iconColor: Colors.black, // cor da setinha expandida
              collapsedIconColor: Colors.black, // cor da setinha fechada
              shape: Border(), // remove a borda padrão
              collapsedShape: Border(), // remove a borda quando fechado
            ),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero, // tira espaçamento lateral
              childrenPadding: EdgeInsets.zero, // tira espaçamento dos filhos
              dense: true, // deixa mais compacto

              title: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: SelectableText(
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
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: compra.statusProcessamento == 1,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Tem Certeza?'),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    backgroundColor:
                                        Theme.of(context).cardColor,
                                    content: const Text(
                                        'Deseja alterar o status para Aguardando Envio?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text(
                                          'Fechar',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: const Color(
                                              0xff01801C), // cor de fundo
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                8), // borda arredondada
                                            side: const BorderSide(
                                                color: Color(0xffBEFFCF),
                                                width:
                                                    1.5), // borda fina (opcional)
                                          ),
                                        ),
                                        child: const Text('Confirmar', 
                                            style:
                                                TextStyle(color: Colors.white)),
                                        onPressed: () {
                                          ref
                                              .read(searchProvider.notifier)
                                              .atualizarStatusProcessamento(
                                                  compra.id, 2);
                                          Navigator.of(context).pop();
                                          // print(compra.id);
                                        },
                                      ),
                                    ],
                                  );
                                });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xffFCFFAC), // cor de fundo
                            foregroundColor: Colors.black, // cor do texto
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8), // borda arredondada
                              side: const BorderSide(
                                  color: Color(0xffEAC04D),
                                  width: 1.5), // borda fina
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.005,
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.004,
                            ), // padding responsivo
                            textStyle: TextStyle(
                              fontSize: MediaQuery.of(context).size.width *
                                  0.04, // tamanho do texto responsivo
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Text(
                            "Aguardando Envio",
                            style: TextStyle(fontSize: size.width * 0.009),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              final tipoEntregaController =
                                  TextEditingController();
                              final valorCorreiosController =
                                  TextEditingController();

                              return AlertDialog(
                                title: const Text('Tem Certeza?'),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                backgroundColor: Theme.of(context).cardColor,
                                content: compra.statusProcessamento == 2
                                    ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                              'Preencha os dados de envio:'),
                                          const SizedBox(height: 12),
                                          CustomTextField(
                                            label: "Tipo de Entrega",
                                            hintText:
                                                "Digite o tipo de entrega",
                                            controller: tipoEntregaController,
                                            validator: (value) =>
                                                value == null || value.isEmpty
                                                    ? "Obrigatório"
                                                    : null,
                                            isEditing:
                                                true, // ou false se quiser bloqueado
                                          ),
                                          const SizedBox(height: 12),
                                          CampoMonetario(
                                            labelText: 'Valor Correios',
                                            onChanged: (valor) =>
                                                valorCorreiosController.text =
                                                    valor.toString(),
                                          ),
                                        ],
                                      )
                                    : const Text(
                                        'Deseja alterar o status para Finalizado?',
                                      ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Fechar',
                                        style: TextStyle(color: Colors.red)),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color(
                                          0xff01801C), // cor de fundo
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8), // borda arredondada
                                        side: const BorderSide(
                                            color: Color(0xffBEFFCF),
                                            width:
                                                1.5), // borda fina (opcional)
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (compra.statusProcessamento == 2) {
                                        final tipoEntrega =
                                            tipoEntregaController.text.trim();
                                        final valorCorreios =
                                            valorCorreiosController.text.trim();

                                        if (tipoEntrega.isEmpty ||
                                            valorCorreios.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Preencha todos os campos"),
                                            ),
                                          );
                                          return;
                                        }

                                        await ref
                                            .read(searchProvider.notifier)
                                            .atualizarVenda(
                                          compra.compraId,
                                          {
                                            'tipo_entrega': tipoEntrega,
                                            'valor_correios': double.tryParse(
                                                    valorCorreios) ??
                                                0,
                                          },
                                        );
                                      } else {
                                        await ref
                                            .read(searchProvider.notifier)
                                            .atualizarStatusProcessamento(
                                              compra.id,
                                              3,
                                              dataFim: DateTime.now(),
                                            );

                                        await ref
                                            .read(searchProvider.notifier)
                                            .atualizarVenda(
                                          compra.compraId,
                                          {
                                            'data_postagem': DateTime.now()
                                                .toIso8601String(),
                                          },
                                        );
                                      }

                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'Confirmar',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xff01801C), // cor de fundo
                          foregroundColor: Colors.black, // cor do texto
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8), // borda arredondada
                            side: const BorderSide(
                                color: Color(0xffBEFFCF),
                                width: 1.5), // borda fina
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical:
                                MediaQuery.of(context).size.height * 0.005,
                            horizontal:
                                MediaQuery.of(context).size.width * 0.004,
                          ), // padding responsivo
                          textStyle: TextStyle(
                            fontSize: MediaQuery.of(context).size.width *
                                0.04, // tamanho do texto responsivo
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(
                          "Finalizado",
                          style: TextStyle(
                              fontSize: size.width * 0.009,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
