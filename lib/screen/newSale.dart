import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/components/inputs.dart';
import 'package:search_instrutores/components/newSale/buscarClientes.dart';
import 'package:search_instrutores/components/newSale/buscarProduto.dart';
import 'package:search_instrutores/components/newSale/campoMonetario.dart';
import 'package:search_instrutores/components/newSale/datePicker.dart';
import 'package:search_instrutores/components/showMessager.dart';
import 'package:search_instrutores/provider/searchProvider.dart';
import 'package:search_instrutores/utils/cor.dart';
// import 'package:search_instrutores/utils/formatadorHelpers.dart';

class NewSale extends ConsumerStatefulWidget {
  const NewSale({
    super.key,
  });

  @override
  ConsumerState<NewSale> createState() => _NewSaleState();
}

class _NewSaleState extends ConsumerState<NewSale> {
  @override
  void initState() {
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();

  // Controllers para inputs
  final pedidoController = TextEditingController();
  final entregaController = TextEditingController();
  final pagamentoController = TextEditingController();
  final observacoesController = TextEditingController();

  // Variáveis de estado
  DateTime? dataPedido = DateTime.now();
  DateTime? dataEntrega;
  double valorReal = 0.0;
  double valorCorreios = 0.0;
  String? entrega;
  String? pedido;
  String? pagamentoId;
  String? observacoes;
  Cliente? clienteSelecionado;
  Produto? produtoSelecionado;

  @override
  void dispose() {
    pedidoController.dispose();
    entregaController.dispose();
    pagamentoController.dispose();
    observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    void _tentarSalvarVenda(BuildContext context) async {
      if (_formKey.currentState!.validate()) {
        // aqui vai lógica de salvar no banco
        final resposta = await ref.read(searchProvider.notifier).salvarVenda(
              cliente: clienteSelecionado!.id,
              produto: produtoSelecionado!.id,
              valor: valorReal,
              entrega: entregaController.text,
              pagamentoId: pagamentoController.text,
              pedido: pedidoController.text,
              correios: valorCorreios,
              dataPedido: dataPedido!,
              dataEntrega: dataEntrega,
              observacoes: observacoesController.text,
            );

        if (resposta.isEmpty || resposta['id'] == null) {
          showCustomMessage(context, 'Erro ao salvar a venda.',
              type: MessageType.error);
          return;
        }

        ref.read(searchProvider.notifier).iniciarProcessodeVendas(
              resposta['id'],
              dataEntrega == null ? 1 : 3,
              dataComeco: dataPedido,
              dataEntraga: dataEntrega,
            );

        ref.invalidate(vendasPorMesProvider);
        ref.invalidate(clientesNovosProvider);

        showCustomMessage(context, 'Venda salva com sucesso!',
            type: MessageType.success);

        // Limpar formulário
        setState(() {
          clienteSelecionado = null;
          produtoSelecionado = null;
          dataPedido = DateTime.now();
          dataEntrega = null;
          valorReal = 0.0;
          valorCorreios = 0.0;
          observacoesController.clear();
          pedidoController.clear();
          entregaController.clear();
          pagamentoController.clear();
        });
      } else {
        log("Erro: formulário inválido.");
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Nova Venda',
                style: TextStyle(
                  fontSize: size.width * 0.02,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Form(
              key: _formKey,
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // 🔹 Datas
                    Row(
                      children: [
                        SizedBox(
                          width: size.width * 0.25,
                          child: CampoDataCustom(
                            label: 'Data do Pedido',
                            dataInicial: dataPedido,
                            onChanged: (novaData) => setState(() {
                              dataPedido = novaData;
                            }),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: size.width * 0.25,
                          child: CampoDataCustom(
                            label: 'Data da Entrega',
                            dataInicial: dataEntrega,
                            onChanged: (novaData) => setState(() {
                              dataEntrega = novaData;
                            }),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // 🔹 Tipo de entrega e pedido
                    Row(
                      children: [
                        SizedBox(
                          width: size.width * 0.25,
                          child: CustomTextField(
                            label: "Tipo de Entrega",
                            hintText: "Digite o tipo de entrega",
                            controller: entregaController,
                            // validator: (value) => value == null || value.isEmpty
                            //     ? "Obrigatório"
                            //     : null,
                            isEditing: true, // ou false se quiser bloqueado
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: size.width * 0.25,
                          child: CustomTextField(
                            label: "Pedido",
                            hintText: "Digite o tipo do pedido",
                            controller: pedidoController,
                            validator: (value) => value == null || value.isEmpty
                                ? "Obrigatório"
                                : null,
                            isEditing: true, // ou false se quiser bloqueado
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // 🔹 Valores e pagamento
                    Row(
                      children: [
                        SizedBox(
                          width: size.width * 0.17,
                          child: CampoMonetario(
                            labelText: 'Valor do Produto',
                            initialValue: valorReal,
                            onChanged: (valor) {
                              valorReal = valor;
                              print('Valor atualizado: $valorReal');
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: size.width * 0.17,
                          child: CustomTextField(
                            label: "Tipo de Pagamento",
                            hintText: "Dropdown futuramente",
                            controller: pagamentoController,
                            validator: (value) => value == null || value.isEmpty
                                ? "Obrigatório"
                                : null,
                            isEditing: true, // ou false se quiser bloqueado
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: size.width * 0.17,
                          child: CampoMonetario(
                            labelText: 'Valor Correios',
                            onChanged: (valor) => valorCorreios = valor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // 🔹 Cliente e Produto
                    Row(
                      children: [
                        SizedBox(
                          width: size.width * 0.4,
                          child: CampoBuscaCliente(
                            onClienteSelecionado: (cliente) =>
                                clienteSelecionado = cliente,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: size.width * 0.4,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Produto',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(100),
                                      offset: const Offset(7, 6),
                                      blurRadius: 4,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Theme.of(context).extension<AppColors>()!.inputBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).extension<AppColors>()!.inputBackground,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: DropdownProdutos(
                                    onProdutoSelecionado: (produto) =>
                                        produtoSelecionado = produto,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // 🔹 Observações
                    CustomTextField(
                        label: 'Observacoes',
                        hintText: 'Digite aqui observações sobre o pedido...',
                        controller: observacoesController,
                        maxLines: 7,
                        validator: (value) => null),
                    const SizedBox(height: 30),

                    // 🔹 Botão salvar
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => _tentarSalvarVenda(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 0, 255, 68),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Salvar Venda',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // final formatador = Formatadorhelpers();

  // DateTime? dataPedido; // Pega a data do pedido
  // DateTime? dataEntrega; // Pega a data da entrega
  // double valorReal = 0.0; // Pega o valor real do produto
  // double valorCorreios = 0.0; // Pega o valor real do produto
  // Cliente? clienteSelecionado;
  // Produto? _produtoSelecionado;
  // String? observacoes;
  // String? pedido;
  // String? entrega;
  // String? pagamentoId;

  // void _tentarSalvarVenda(BuildContext context, WidgetRef ref) async {
  //   final erro = _validarFormulario();

  //   if (erro != null) {
  //     showCustomMessage(context, erro, type: MessageType.warning);
  //     return;
  //   }

  //   final resposta = await ref.read(searchProvider.notifier).salvarVenda(
  //         cliente: clienteSelecionado!.id,
  //         produto: _produtoSelecionado!.id,
  //         valor: valorReal,
  //         entrega: entrega,
  //         pagamentoId: pagamentoId,
  //         pedido: pedido,
  //         correios: valorCorreios,
  //         dataPedido: dataPedido!,
  //         dataEntrega: dataEntrega,
  //         observacoes: observacoes,
  //       );

  //   if (resposta.isEmpty || resposta['id'] == null) {
  //     showCustomMessage(context, 'Erro ao salvar a venda.',
  //         type: MessageType.error);
  //     return;
  //   }

  //   ref.read(searchProvider.notifier).iniciarProcessodeVendas(
  //         resposta['id'],
  //         dataEntrega == null ? 1 : 3,
  //         dataComeco: dataPedido,
  //         dataEntraga: dataEntrega,
  //       );

  //   setState(() {
  //     clienteSelecionado = null;
  //     _produtoSelecionado = null;
  //     dataPedido = null;
  //     dataEntrega = null;
  //     valorReal = 0.0;
  //     valorCorreios = 0.0;
  //     observacoes = '';
  //   });

  //   ref.invalidate(vendasPorMesProvider);
  //   ref.invalidate(clientesNovosProvider);

  //   showCustomMessage(context, 'Venda salva com sucesso!',
  //       type: MessageType.success);
  // }

  // String? _validarFormulario() {
  //   if (clienteSelecionado == null) {
  //     return 'Selecione um cliente antes de salvar.';
  //   }
  //   if (_produtoSelecionado == null) {
  //     return 'Selecione um produto antes de salvar.';
  //   }
  //   if (dataPedido == null) return 'Preencha as datas do pedido.';
  //   if (valorReal <= 0) return 'O valor do produto deve ser maior que zero.';
  //   if (dataEntrega != null && dataEntrega!.isBefore(dataPedido!)) {
  //     return 'A data de entrega não pode ser anterior à data do pedido.';
  //   }
  //   if (valorCorreios < 0) return 'O valor dos Correios não pode ser negativo.';
  //   return null;
  // }

  // @override
  // Widget build(BuildContext context) {
  //   final size = MediaQuery.of(context).size;

  //   final dataNow =
  //       DateTime.now(); // Variavel para passar a data de hoje no campo

  //   dataPedido ??= dataNow; // Inicializa dataPedido com a data atual

  //   return Scaffold(

  //     body: Padding(
  //       padding: const EdgeInsets.all(20.0),
  //       child: SizedBox(
  //         width: double.infinity,
  //         child: Center(
  //           child: Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: SingleChildScrollView(
  //               padding: const EdgeInsets.all(8.0),
  //               child: ConstrainedBox(
  //                 constraints: BoxConstraints(
  //                   minHeight: MediaQuery.of(context).size.height,
  //                 ),
  //                 child: IntrinsicHeight(
  //                   child: Column(
  //                     children: [
  //                       Wrap(
  //                         spacing: 16,
  //                         runSpacing: 16,
  //                         children: [
  //                           SizedBox(
  //                             width: size.width * 0.25,
  //                             child: CampoDataCustom(
  //                               label: 'Data do Pedido',
  //                               dataInicial: dataNow,
  //                               onChanged: (novaData) {
  //                                 dataPedido = novaData;
  //                               },
  //                             ),
  //                           ),
  //                           SizedBox(
  //                             width: size.width * 0.25,
  //                             child: CampoDataCustom(
  //                               label: 'Data da Entrega',
  //                               dataInicial: dataEntrega,
  //                               onChanged: (novaData) {
  //                                 dataEntrega = novaData;
  //                                 print(
  //                                     'Nova data de entrega: $dataEntrega');
  //                               },
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       const SizedBox(height: 30),
  //                       Wrap(
  //                         spacing: 16,
  //                         runSpacing: 16,
  //                         children: [
  //                           SizedBox(
  //                             width: size.width * 0.25,
  //                             child: TextField(
  //                               decoration: const InputDecoration(
  //                                 labelText: 'Tipo de Entrega',
  //                                 border: OutlineInputBorder(),
  //                               ),
  //                               onChanged: (value) {
  //                                 entrega = value;
  //                               },
  //                             ),
  //                           ),
  //                           SizedBox(
  //                             width: size.width * 0.25,
  //                             child: TextField(
  //                               decoration: const InputDecoration(
  //                                 labelText: 'Pedido',
  //                                 border: OutlineInputBorder(),
  //                               ),
  //                               onChanged: (value) {
  //                                 pedido = value;
  //                               },
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       const SizedBox(height: 30),
  //                       Wrap(
  //                         spacing: 16,
  //                         runSpacing: 16,
  //                         children: [
  //                           SizedBox(
  //                             width: size.width * 0.25,
  //                             child: CampoMonetario(
  //                               labelText: 'Valor do Produto',
  //                               onChanged: (valor) {
  //                                 valorReal = valor;
  //                                 log('Valor atualizado: $valorReal');
  //                               },
  //                             ),
  //                           ),
  //                           SizedBox(
  //                             width: size.width * 0.25,
  //                             child: TextField(
  //                               decoration: const InputDecoration(
  //                                 labelText: 'Tipo de Pagamento',
  //                                 border: OutlineInputBorder(),
  //                               ),
  //                               onChanged: (value) {
  //                                 pagamentoId = value;
  //                               },
  //                             ),
  //                           ),
  //                           SizedBox(
  //                             width: size.width * 0.25,
  //                             child: CampoMonetario(
  //                               labelText: 'Valor Correios',
  //                               onChanged: (valor) {
  //                                 valorCorreios = valor;
  //                                 log('Valor atualizado: $valorCorreios');
  //                               },
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       const SizedBox(height: 30),
  //                       Wrap(
  //                         spacing: 16,
  //                         runSpacing: 16,
  //                         children: [
  //                           SizedBox(
  //                             width: size.width * 0.4,
  //                             child: CampoBuscaCliente(
  //                               onClienteSelecionado: (cliente) {
  //                                 clienteSelecionado = cliente;
  //                                 log('Cliente escolhido: ${cliente.nome}, ID: ${cliente.id}');
  //                               },
  //                             ),
  //                           ),
  //                           SizedBox(
  //                             width: size.width * 0.4,
  //                             child: DropdownProdutos(
  //                               onProdutoSelecionado: (produto) {
  //                                 _produtoSelecionado = produto;
  //                                 log('Produto escolhido: ${produto.nome}, ID: ${produto.id}');
  //                               },
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       const SizedBox(height: 30),
  //                       TextField(
  //                         maxLines: 4,
  //                         decoration: const InputDecoration(
  //                           labelText: 'Observações',
  //                           hintText:
  //                               'Digite aqui observações sobre o pedido...',
  //                           border: OutlineInputBorder(),
  //                         ),
  //                         onChanged: (value) {
  //                           observacoes = value;
  //                         },
  //                       ),
  //                       const SizedBox(height: 30),
  //                       Align(
  //                         alignment: Alignment.centerRight,
  //                         child: ElevatedButton(
  //                           onPressed: () async {
  //                             _tentarSalvarVenda(context, ref);
  //                             // setState(() {
  //                             //   clienteSelecionado = null;
  //                             //   _produtoSelecionado = null;
  //                             //   dataPedido = null;
  //                             //   dataEntrega = null;
  //                             //   valorReal = 0.0;
  //                             //   valorCorreios = 0.0;
  //                             //   observacoes = '';
  //                             // });
  //                           },
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor:
  //                                 const Color.fromARGB(255, 0, 255, 68),
  //                             foregroundColor: Colors.black,
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(8),
  //                             ),
  //                           ),
  //                           child: const Text(
  //                             'Salvar Venda',
  //                             style: TextStyle(
  //                               fontSize: 12,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
