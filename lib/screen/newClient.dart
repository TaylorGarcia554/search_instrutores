import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/components/showMessager.dart';
import 'package:search_instrutores/provider/searchProvider.dart';
import 'package:search_instrutores/utils/cor.dart';
import 'package:search_instrutores/utils/formatadorHelpers.dart';

class NewClient extends ConsumerStatefulWidget {
  const NewClient({
    super.key,
  });

  @override
  ConsumerState<NewClient> createState() => _NewClientState();
}

class _NewClientState extends ConsumerState<NewClient> {
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final nomeController = TextEditingController();
    final emailController = TextEditingController();
    final cpfController = TextEditingController();
    final telefoneController = TextEditingController();
    final observacaoController = TextEditingController();

    final customField = formatador.customField;

    final _formKey = GlobalKey<FormState>();

    return Hero(
      tag: 'novoCliente',
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            // width: size.width * 0.4,
                            child: SizedBox(
                              width: size.width * 0.7,
                              child: customField(
                                  controller: nomeController,
                                  label: 'Nome:',
                                  isEditing: true,
                                  textColor: Cor.texto,
                                  colorEditing:
                                      const Color.fromARGB(255, 0, 255, 68),
                                  fontSize: size.width * 0.022,
                                  filled: false,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Nome é obrigatório';
                                    }
                                    if (!RegExp(r"^[a-zA-ZÀ-ÿ\s]+$")
                                        .hasMatch(value)) {
                                      return 'Nome inválido (sem números ou símbolos)';
                                    }
                                    return null;
                                  },
                                  maxLines: 1),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final status = await ref
                                      .read(searchProvider.notifier)
                                      .inserirClientes({
                                    'nome': nomeController.text,
                                    'email': emailController.text,
                                    'cpf': cpfController.text,
                                    'telefone': telefoneController.text,
                                    'observacao': observacaoController.text,
                                  });
                                  if (status['status'] == 'success') {
                                    showCustomMessage(
                                      context,
                                      'Cliente salvo com sucesso!',
                                      type: MessageType.success,
                                      duration: const Duration(seconds: 2),
                                    );
                                    // Limpa os campos após salvar
                                    nomeController.clear();
                                    emailController.clear();
                                    cpfController.clear();
                                    telefoneController.clear();
                                    observacaoController.clear();
                                  } else {
                                    showCustomMessage(
                                      context,
                                      'Erro ao tentar salvar o cliente',
                                      type: MessageType.error,
                                      duration: const Duration(seconds: 2),
                                    );
                                    // Limpa os campos após salvar
                                    nomeController.clear();
                                    emailController.clear();
                                    cpfController.clear();
                                    telefoneController.clear();
                                    observacaoController.clear();
                                  }
                                }
                                print('Editar pressionado');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 255, 68),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(
                                      color: Colors.black, width: 1.5),
                                ),
                              ),
                              child: const Text('Salvar',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                  )),
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
                                isEditing: true,
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
                                isEditing: true,
                                colorEditing: Cor.bordaBotao,
                                textColor: Cor.texto,
                                fontSize: size.width * 0.011,
                                filled: true,
                                textInputType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email obrigatório';
                                  }
                                  if (!RegExp(
                                          r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
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
                                isEditing: true,
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
                            isEditing: true,
                            colorEditing: Cor.bordaBotao,
                            textColor: Cor.texto,
                            fontSize: size.width * 0.011,
                            filled: true,
                            maxLines: 7),
                      ),
                    ],
                  ),
                ),
              )),
            ),
          ),
        ),
      ),
    );
  }
}
