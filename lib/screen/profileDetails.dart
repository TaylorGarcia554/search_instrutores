import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:search_instrutores/components/comprasPassadas.dart';
import 'package:search_instrutores/provider/searchProvider.dart';
import 'package:search_instrutores/utils/cor.dart';
import 'package:search_instrutores/utils/formatadorHelpers.dart';

class ProfileDetails extends ConsumerStatefulWidget {
  const ProfileDetails({
    super.key,
    required this.profileId,
    required this.nome,
    required this.cpf,
    required this.email,
    required this.telefone,
    required this.observacao,
  });

  final int profileId;
  final String nome;
  final String cpf;
  final String email;
  final String telefone;
  final String observacao;

  @override
  ConsumerState<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends ConsumerState<ProfileDetails> {
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
    buscarComprasPassadas(widget.profileId).then((compras) {
      if (compras.isNotEmpty) {
        print('Compras passadas encontradas: $compras');
        setState(() {
          comprasPassadas = compras;
        });
      } else {
        print(
            'Nenhuma compra passada encontrada para o cliente com ID: ${widget.profileId}');
      }
    });
  }

  List<Map<String, dynamic>> comprasPassadas = [];

  bool isEditing = false;
  final formatador = Formatadorhelpers();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final nomeController = TextEditingController(text: widget.nome);
    final emailController = TextEditingController(text: widget.email);
    final cpfController =
        TextEditingController(text: formatador.formatCPFNumber(widget.cpf));
    final telefoneController = TextEditingController(
        text: formatador.formatPhoneNumber(widget.telefone));
    final observacaoController = TextEditingController(text: widget.observacao);

    final customField = formatador.customField;

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de ${widget.nome}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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
          child: SingleChildScrollView(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: customField(
                          controller: nomeController,
                          label: '',
                          isEditing: isEditing,
                          textColor: isEditing ? Cor.texto : Cor.texto,
                          fontSize: size.width * 0.022,
                          filled: false,
                          maxLines: 1),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isEditing = !isEditing;
                          // Atualiza o estado para refletir a mudança
                        });
                        print('Editar pressionado');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 110, 255),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Editar'),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Wrap(
                  spacing: 15,
                  children: [
                    SizedBox(
                      width: size.width * 0.18,
                      child: customField(
                          controller: cpfController,
                          label: 'CPF',
                          isEditing: isEditing,
                          textColor: isEditing ? Cor.texto : Cor.texto,
                          fontSize: size.width * 0.011,
                          filled: true,
                          maxLines: 1),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: size.width * 0.27,
                      child: customField(
                          controller: emailController,
                          label: 'Email',
                          isEditing: isEditing,
                          textColor: isEditing ? Cor.texto : Cor.texto,
                          fontSize: size.width * 0.011,
                          filled: true,
                          maxLines: 1),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: size.width * 0.2,
                      child: customField(
                          controller: telefoneController,
                          label: 'Telefone',
                          isEditing: isEditing,
                          textColor: isEditing ? Cor.texto : Cor.texto,
                          fontSize: size.width * 0.011,
                          filled: true,
                          maxLines: 1),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: size.width * 0.8,
                  child: customField(
                      controller: observacaoController,
                      label: 'Observação',
                      isEditing: isEditing,
                      textColor: isEditing ? Cor.texto : Cor.texto,
                      fontSize: size.width * 0.011,
                      filled: true,
                      maxLines: 7),
                ),
                const SizedBox(height: 30),
                Text(
                  'Compras Passadas',
                  style: TextStyle(
                    fontSize: size.width * 0.015,
                    color: Cor.texto,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true, // necessário dentro de Column
                  physics:
                      const NeverScrollableScrollPhysics(), // desativa scroll interno
                  itemCount: comprasPassadas.length,
                  itemBuilder: (context, index) {
                    final compra = comprasPassadas[index];
                    final id = compra['id'] ?? 0;
                    final data = compra['data_pedido'] ?? 'Sem data';
                    final produto = compra['produto_id'] ?? 'Sem produto';
                    final valor = compra['valor'] ?? 0.00;
                    final observacao = compra['observacao'] ?? 'Sem observação';
                    final entrega = compra['entrega'] ?? '';

                    return Slidable(
                      key: ValueKey('item_$id'),
                      dragStartBehavior: DragStartBehavior.start,
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        closeThreshold: 0.9,
                        extentRatio: 0.14,
                        openThreshold: 0.1,

                        children: [
                          CustomSlidableAction(
                            // onPressed: (_) => editarItem(),
                            onPressed: (BuildContext context) {
                              // Aqui você pode implementar a lógica de edição
                              print('Editar item com ID: $id');
                            },
                            child: Container(
                              width: 110,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit, color: Colors.white),
                                  SizedBox(height: 9),
                                  Text(
                                    'Editar',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          titleTextStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          subtitle: ComprasPassadas(
                            id: id,
                            dataCompra: data,
                            produto: produto,
                            valor: valor,
                            entrega: entrega,
                            observacao: observacao,
                          ),
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          )),
        ),
      ),
    );
  }
}
