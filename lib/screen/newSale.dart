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

  DateTime? dataPedido; // Variavel que pega a data do pedido
  DateTime? dataEntrega; // Variavel que pega a data da entrega
  double valorReal = 0.0; // Variavel que pega o valor real do produto
  Cliente? clienteSelecionado;
  Produto? _produtoSelecionado;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final dataNow =
        DateTime.now(); // Variavel para passar a data de hoje no campo

    return Hero(
      tag: 'novaVenda',
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: size.width * 0.2,
                                    child: CampoDataCustom(
                                      label: 'Data do Pedido',
                                      dataInicial: dataNow,
                                      onChanged: (novaData) {
                                        dataPedido = novaData;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: size.width * 0.2,
                                    child: CampoDataCustom(
                                      label: 'Data da Entrega',
                                      dataInicial: dataEntrega,
                                      onChanged: (novaData) {
                                        dataEntrega = novaData;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: size.width * 0.2,
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        labelText: 'Tipo de Entrega',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        // Aqui você pode salvar o tipo de entrega
                                      },
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 30),
                              Row(children: [
                                SizedBox(
                                    width: size.width * 0.2,
                                    child: CampoMonetario(
                                      onChanged: (valor) {
                                        valorReal = valor;
                                        print('Valor atualizado: $valorReal');
                                      },
                                    )),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: size.width * 0.2,
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Tipo de Pagamento',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      // Aqui você pode salvar o tipo de pagamento
                                    },
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 30),
                              Row(
                                children: [
                                  SizedBox(
                                    width: size.width * 0.5,
                                    // height: 120,
                                    child: CampoBuscaCliente(
                                      onClienteSelecionado: (cliente) {
                                        clienteSelecionado = cliente;
                                        print(
                                            'Cliente escolhido: ${cliente.nome}, ID: ${cliente.id}'); // TODO: Salvar o id aqui para publicar no post no banco de dados
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                ],
                              ),
                              SizedBox(
                                width: size.width * 0.4,
                                child: const DropdownProdutos(
                                  
                                ),
                              ),
                              const Text(
                                  'Voce precisa adicionar os campos \n ✅ Data pedido ( o mesmo pra compra e status_pedidos) \n ✅Data postagem ( o mesmo pra compra e status_pedidos) \n ✅ Tipo de entrega ( link, ou codigo) \n ✅ Valor \n ✅ Tipo de pagamento \n o Cliente (puxando da tabela clientes) \n observacao se houver \n o produto \n e por ultimo se houver, o valor dos correios.'),
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
    );
  }
}
