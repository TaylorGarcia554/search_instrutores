import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/components/newSale/buscarClientes.dart';
import 'package:search_instrutores/components/newSale/buscarProduto.dart';
import 'package:search_instrutores/components/newSale/campoMonetario.dart';
import 'package:search_instrutores/components/newSale/datePicker.dart';
import 'package:search_instrutores/components/showMessager.dart';
import 'package:search_instrutores/provider/searchProvider.dart';
import 'package:search_instrutores/utils/cor.dart';
import 'package:search_instrutores/utils/formatadorHelpers.dart';

class NewSale extends ConsumerStatefulWidget {
  const NewSale({
    super.key,
  });

  @override
  ConsumerState<NewSale> createState() => _NewSaleState();
}

class _NewSaleState extends ConsumerState<NewSale> {
  Future<List<Map<String, dynamic>>> buscarComprasPassadas(
      int clienteId) async {
    final compras = await ref
        .read(searchProvider.notifier)
        .buscarComprasPorCliente(clienteId);
    print('Compras encontradas: $compras');

    if (compras.isEmpty) {
      print('Nenhuma compra encontrada para o cliente com ID: $clienteId');
      return [];
    }
    return compras;
  }

  @override
  void initState() {
    super.initState();
  }

  final formatador = Formatadorhelpers();

  DateTime? dataPedido; // Pega a data do pedido
  DateTime? dataEntrega; // Pega a data da entrega
  double valorReal = 0.0; // Pega o valor real do produto
  double valorCorreios = 0.0; // Pega o valor real do produto
  Cliente? clienteSelecionado;
  Produto? _produtoSelecionado;
  String? observacoes;
  String? pedido;
  String? entrega;
  String? pagamentoId;

  void _tentarSalvarVenda(BuildContext context, WidgetRef ref) async {
    final erro = _validarFormulario();

    if (erro != null) {
      showCustomMessage(context, erro, type: MessageType.warning);
      return;
    }

    final resposta = await ref.read(searchProvider.notifier).salvarVenda(
          cliente: clienteSelecionado!.id,
          produto: _produtoSelecionado!.id,
          valor: valorReal,
          entrega: entrega,
          pagamentoId: pagamentoId,
          pedido: pedido,
          correios: valorCorreios,
          dataPedido: dataPedido!,
          dataEntrega: dataEntrega,
          observacoes: observacoes,
        );

    if (resposta.isEmpty || resposta['id'] == null) {
      showCustomMessage(context, 'Erro ao salvar a venda.',
          type: MessageType.error);
      return;
    }

    if (dataEntrega == null) {
      ref.read(searchProvider.notifier).iniciarProcessodeVendas(resposta['id']);
    }

    showCustomMessage(context, 'Venda salva com sucesso!',
        type: MessageType.success);
  }

  String? _validarFormulario() {
    if (clienteSelecionado == null) {
      return 'Selecione um cliente antes de salvar.';
    }
    if (_produtoSelecionado == null) {
      return 'Selecione um produto antes de salvar.';
    }
    if (dataPedido == null) return 'Preencha as datas do pedido.';
    if (valorReal <= 0) return 'O valor do produto deve ser maior que zero.';
    if (dataEntrega != null && dataEntrega!.isBefore(dataPedido!)) {
      return 'A data de entrega não pode ser anterior à data do pedido.';
    }
    if (valorCorreios < 0) return 'O valor dos Correios não pode ser negativo.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final dataNow =
        DateTime.now(); // Variavel para passar a data de hoje no campo

    dataPedido ??= dataNow; // Inicializa dataPedido com a data atual

    return Hero(
      tag: 'novaVenda',
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Nova Venda'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              children: [
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: [
                                    SizedBox(
                                      width: size.width * 0.25,
                                      child: CampoDataCustom(
                                        label: 'Data do Pedido',
                                        dataInicial: dataNow,
                                        onChanged: (novaData) {
                                          dataPedido = novaData;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: size.width * 0.25,
                                      child: CampoDataCustom(
                                        label: 'Data da Entrega',
                                        dataInicial: dataEntrega,
                                        onChanged: (novaData) {
                                          dataEntrega = novaData;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: [
                                    SizedBox(
                                      width: size.width * 0.25,
                                      child: TextField(
                                        decoration: const InputDecoration(
                                          labelText: 'Tipo de Entrega',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          entrega = value;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: size.width * 0.25,
                                      child: TextField(
                                        decoration: const InputDecoration(
                                          labelText: 'Pedido',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          pedido = value;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: [
                                    SizedBox(
                                      width: size.width * 0.25,
                                      child: CampoMonetario(
                                        labelText: 'Valor do Produto',
                                        onChanged: (valor) {
                                          valorReal = valor;
                                          log('Valor atualizado: $valorReal');
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: size.width * 0.25,
                                      child: TextField(
                                        decoration: const InputDecoration(
                                          labelText: 'Tipo de Pagamento',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          pagamentoId = value;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: size.width * 0.25,
                                      child: CampoMonetario(
                                        labelText: 'Valor Correios',
                                        onChanged: (valor) {
                                          valorCorreios = valor;
                                          log('Valor atualizado: $valorCorreios');
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: [
                                    SizedBox(
                                      width: size.width * 0.4,
                                      child: CampoBuscaCliente(
                                        onClienteSelecionado: (cliente) {
                                          clienteSelecionado = cliente;
                                          log('Cliente escolhido: ${cliente.nome}, ID: ${cliente.id}');
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: size.width * 0.4,
                                      child: DropdownProdutos(
                                        onProdutoSelecionado: (produto) {
                                          _produtoSelecionado = produto;
                                          log('Produto escolhido: ${produto.nome}, ID: ${produto.id}');
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                TextField(
                                  maxLines: 4,
                                  decoration: const InputDecoration(
                                    labelText: 'Observações',
                                    hintText:
                                        'Digite aqui observações sobre o pedido...',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    observacoes = value;
                                  },
                                ),
                                const SizedBox(height: 30),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      _tentarSalvarVenda(context, ref);
                                      setState(() {
                                        clienteSelecionado = null;
                                        _produtoSelecionado = null;
                                        dataPedido = null;
                                        dataEntrega = null;
                                        valorReal = 0.0;
                                        valorCorreios = 0.0;
                                        observacoes = '';
                                      });
                                    },
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
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
