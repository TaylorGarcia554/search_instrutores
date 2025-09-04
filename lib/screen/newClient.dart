import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:search_instrutores/components/button.dart';
import 'package:search_instrutores/components/inputs.dart';
import 'package:search_instrutores/components/showMessager.dart';
import 'package:search_instrutores/provider/searchProvider.dart';
// import 'package:search_instrutores/utils/cor.dart';
import 'package:search_instrutores/utils/formatadorHelpers.dart';

class NewClient extends ConsumerStatefulWidget {
  const NewClient({
    super.key,
  });

  @override
  ConsumerState<NewClient> createState() => _NewClientState();
}

class _NewClientState extends ConsumerState<NewClient> {
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

    // final customField = formatador.customField;

    // Cria o formatter CPF/CNPJ
    // final cpfCnpjFormatter = MaskTextInputFormatter(
    //   mask: '###.###.###-##', // CPF
    //   filter: {"#": RegExp(r'[0-9]')},
    // );

    // final cnpjFormatter = MaskTextInputFormatter(
    //   mask: '##.###.###/####-##', // CNPJ
    //   filter: {"#": RegExp(r'[0-9]')},
    // );

    final _formKey = GlobalKey<FormState>();

    void _limparCampos() {
      setState(() {
        nomeController.clear();
        emailController.clear();
        cpfController.clear();
        telefoneController.clear();
        observacaoController.clear();
      });
    }

    Future<void> _salvarCliente(BuildContext context, WidgetRef ref) async {
      if (_formKey.currentState!.validate()) {
        final status = await ref.read(searchProvider.notifier).inserirClientes({
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

          // Atualiza lista e gráficos
          ref.read(refreshTriggerProvider.notifier).state++;
          ref.invalidate(vendasPorMesProvider);
          ref.invalidate(clientesNovosProvider);

          // Limpa campos
          _limparCampos();
        } else {
          showCustomMessage(
            context,
            status['message'],
            type: MessageType.error,
            duration: const Duration(seconds: 2),
          );

          _limparCampos();
        }
      }

      // Garantia de atualização
      ref.read(refreshTriggerProvider.notifier).state++;
      ref.invalidate(vendasPorMesProvider);
      ref.invalidate(clientesNovosProvider);

      print('Editar pressionado');
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Novo Cliente',
                  style: TextStyle(
                    fontSize: size.width * 0.02,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: size.width * 0.4,
                  child: CustomTextField(
                    label: "Nome",
                    hintText: "Digite o nome",
                    controller: nomeController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nome é obrigatório';
                      }
                      if (!RegExp(r"^[a-zA-ZÀ-ÿ\s]+$").hasMatch(value)) {
                        return 'Nome inválido (sem números ou símbolos)';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: size.width * 0.5,
                  child: CustomTextField(
                    label: "Email",
                    hintText: "Digite o email",
                    controller: emailController,
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
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        label: "CPF/CNPJ",
                        hintText: "Digite o CPF ou CNPJ",
                        controller: cpfController,
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return 'CPF/CNPJ obrigatório';
                        //   }
                        //   final cleaned = value.replaceAll(RegExp(r'\D'), '');
                        //   if (cleaned.length != 11 && cleaned.length != 14) {
                        //     return 'CPF ou CNPJ inválido';
                        //   }
                        //   return null;
                        // },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        flex: 2,
                        child: CustomTextField(
                          label: "Telefone",
                          hintText: "(00) 00000-0000",
                          controller: telefoneController,
                          inputFormatters: [
                            MaskTextInputFormatter(
                                mask: '(##) #####-####',
                                filter: {"#": RegExp(r'[0-9]')})
                          ],
                        )),
                  ],
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  label: "Observação",
                  hintText: "Digite uma observação",
                  controller: observacaoController,
                  maxLines: 7,
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: CustomButton(
                    text: "Salvar",
                    onPressed: () {
                      _salvarCliente(context, ref);
                    },
                  ),
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
