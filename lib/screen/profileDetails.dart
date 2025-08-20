import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:search_instrutores/components/comprasPassadas.dart';
import 'package:search_instrutores/components/showMessager.dart';
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

  Map<String, dynamic>? _clientes;

  Future<void> _buscarCliente() async {
    final resultado =
        await ref.read(searchProvider.notifier).buscarCliente(widget.profileId);
    if (resultado != null) {
      setState(() {
        _clientes = resultado;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _buscarCliente();
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

    if (_clientes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final nomeController = TextEditingController(text: _clientes!['nome']);
    final emailController = TextEditingController(text: _clientes?['email']);
    final cpfController = TextEditingController(
      text: isEditing
          ? (_clientes?['cpf'] ?? '')
              .replaceAll(RegExp(r'\D'), '') // valor limpo
          : formatador.formatCPFNumber(_clientes?['cpf'] ?? ''), // formatado
    );

    final telefoneController = TextEditingController(
        text: formatador.formatPhoneNumber(_clientes?['telefone'] ?? ''));
    final observacaoController =
        TextEditingController(text: _clientes?['observacao']);

    final customField = formatador.customField;

    final _formKey = GlobalKey<FormState>();

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
            child: Form(
              key: _formKey,
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
                            label: 'Nome:',
                            isEditing: isEditing,
                            textColor: isEditing ? Cor.texto : Cor.texto,
                            colorEditing: Cor.bordaBotao,
                            fontSize: size.width * 0.022,
                            filled: false,
                            maxLines: 1),
                      ),
                      Visibility(
                        visible: isEditing,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isEditing = !isEditing;
                                // Atualiza o estado para refletir a mudança
                              });
                              print('Cancelar pressionado');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 77, 0),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: isEditing,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final status = await ref
                                  .read(searchProvider.notifier)
                                  .atualizarCliente({
                                'id': widget.profileId,
                                'nome': nomeController.text,
                                'email': emailController.text,
                                'cpf': cpfController.text,
                                'telefone': telefoneController.text,
                                'observacao': observacaoController.text,
                              });

                              if (status['status'] == 'success') {
                                await _buscarCliente(); // atualiza dados da tela

                                setState(() {
                                  isEditing = false;
                                });

                                showCustomMessage(
                                  context,
                                  'Cliente atualizado com sucesso!',
                                  type: MessageType.success,
                                  duration: const Duration(seconds: 2),
                                );
                              } else {
                                showCustomMessage(
                                  context,
                                  'Erro ao salvar cliente',
                                  type: MessageType.error,
                                  duration: const Duration(seconds: 2),
                                );
                              }
                              print('Editar pressionado');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 0, 255, 68),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Salvar'),
                        ),
                      ),
                      Visibility(
                        visible: !isEditing,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isEditing = !isEditing;
                              // Atualiza o estado para refletir a mudança
                            });
                            print('Editar pressionado');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 0, 110, 255),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Editar'),
                        ),
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
                            label: 'CPF ou CNPJ',
                            isEditing: isEditing,
                            colorEditing: Cor.bordaBotao,
                            textColor: Cor.texto,
                            fontSize: size.width * 0.011,
                            filled: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'CPF/CNPJ obrigatório';
                              }
                              final cleaned =
                                  value.replaceAll(RegExp(r'\D'), '');
                              if (cleaned.length != 11 &&
                                  cleaned.length != 14) {
                                return 'CPF ou CNPJ inválido';
                              }
                              return null;
                            },
                            maxLines: 1),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: size.width * 0.27,
                        child: customField(
                            controller: emailController,
                            label: 'Email',
                            isEditing: isEditing,
                            colorEditing: Cor.bordaBotao,
                            textColor: Cor.texto,
                            fontSize: size.width * 0.011,
                            filled: true,
                            textInputType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email obrigatório';
                              }
                              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Email inválido';
                              }
                              return null;
                            },
                            maxLines: 1),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: size.width * 0.2,
                        child: customField(
                            controller: telefoneController,
                            label: 'Telefone',
                            isEditing: isEditing,
                            colorEditing: Cor.bordaBotao,
                            textColor: Cor.texto,
                            fontSize: size.width * 0.011,
                            filled: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Telefone obrigatório';
                              }
                              final numeric =
                                  value.replaceAll(RegExp(r'\D'), '');
                              if (numeric.length < 10) {
                                return 'Número inválido';
                              }
                              return null;
                            },
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
                        colorEditing: Cor.bordaBotao,
                        textColor: Cor.texto,
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
                      final observacao =
                          compra['observacao'] ?? 'Sem observação';
                      final entrega = compra['entrega'] ?? '';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color:
                                Theme.of(context).colorScheme.surfaceContainer,
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
            ),
          )),
        ),
      ),
    );
  }
}
