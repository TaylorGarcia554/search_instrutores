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
import 'package:search_instrutores/utils/newSalesTutor.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
// import 'package:search_instrutores/utils/formatadorHelpers.dart';

class NewSale extends ConsumerStatefulWidget {
  const NewSale({
    super.key,
  });

  @override
  ConsumerState<NewSale> createState() => _NewSaleState();
}

class _NewSaleState extends ConsumerState<NewSale> {
  final _formKey = GlobalKey<FormState>();

  // Global Key para o tutorial
  final GlobalKey keyDataPedido = GlobalKey();
  final GlobalKey keyDataEntrega = GlobalKey();
  final GlobalKey keyTipoEntrega = GlobalKey();
  final GlobalKey keyPedido = GlobalKey();
  final GlobalKey keyValor = GlobalKey();
  final GlobalKey keyTipoPagamento = GlobalKey();
  final GlobalKey keyValorCorreios = GlobalKey();
  final GlobalKey keyCliente = GlobalKey();
  final GlobalKey keyProduto = GlobalKey();
  final GlobalKey keySalvarVenda = GlobalKey();

  List<TargetFocus> targets = [];

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
  void initState() {
    super.initState();
  }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                ElevatedButton(
                  onPressed: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      initTargets(
                        keyDataPedido,
                        keyDataEntrega,
                        keyTipoEntrega,
                        keyPedido,
                        keyValor,
                        keyTipoPagamento,
                        keyValorCorreios,
                        keyCliente,
                        keyProduto,
                      );
                      showTutorial(context);
                    });
                    // showTutorial(context);
                  },
                  child: Text(
                    "Ver Tutorial",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface
                    ),
                  ),
                )
              ],
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
                          key: keyDataPedido,
                          child: CampoDataCustom(
                            // key: keyDataPedido,
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
                          key: keyDataEntrega,
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
                          key: keyTipoEntrega,
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
                          key: keyPedido,
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
                          key: keyValor,
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
                          key: keyTipoPagamento,
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
                          key: keyValorCorreios,
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
                          key: keyCliente,
                          child: CampoBuscaCliente(
                            onClienteSelecionado: (cliente) =>
                                clienteSelecionado = cliente,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: size.width * 0.3,
                          key: keyProduto,
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
                                    color: Theme.of(context)
                                        .extension<AppColors>()!
                                        .inputBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .extension<AppColors>()!
                                        .inputBackground,
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
}
