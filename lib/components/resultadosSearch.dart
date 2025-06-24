import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/models/dbHelper.dart';
import 'package:search_instrutores/provider/addChatguru.dart';
import 'package:search_instrutores/provider/botaoAtualizar.dart';
import 'package:search_instrutores/provider/updateSheet.dart';

class ResultadosSearch extends ConsumerWidget {
  final String nome;
  final String produto;
  final String valor;
  final String email;
  final String telefone;
  final String data;
  final String sheet;
  final String sheetID;
  final int id;
  final int lembrado;

  const ResultadosSearch({
    super.key,
    required this.nome,
    required this.produto,
    required this.valor,
    required this.email,
    required this.telefone,
    required this.data,
    required this.sheet,
    required this.sheetID,
    required this.id,
    required this.lembrado,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final atualizadoSet = ref.watch(atualizadoProvider);
    final lembrar = atualizadoSet.contains(id);
    ref.read(atualizadoProvider.notifier).carregarAtualizadosDoBanco();
    // log('Id atualizado: $id, Lembrado: $lembrado');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(
          text: 'Produto: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
          children: [
            TextSpan(
              text: produto,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        )),
        Text.rich(TextSpan(
          text: 'Valor: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
          children: [
            TextSpan(
              text: valor,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        )),
        Text.rich(TextSpan(
          text: 'Email: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
          children: [
            TextSpan(
              text: email,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        )),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'Telefone: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  children: [
                    TextSpan(
                      text: telefone,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                // Aqui você faz a ação desejada
                // Exemplo: pintar célula ou enviar notificação
                log('Clique em Atualizar para $telefone');

                // Verifica se o telefone está vazio
                String celular = '55${telefone.replaceAll(RegExp(r'\D'), '')}';
                log(celular);

                // Chama o metodo para mandar mensagem
                await ref
                    .read(addChatGuruProvider.notifier)
                    .enviarMensagem(nome, celular, context);

                // Atualiza o registro no banco de dados
                await DBHelper.marcarComoAtualizado(id);

                ref.read(atualizadoProvider.notifier).marcarAtualizado(id);

                // Chama o metodo para pintar a célula
                await ref.read(updateSheetProvider.notifier).buscarValorEPintar(
                    aba: sheet,
                    sheetId: sheetID,
                    valorProcurado: telefone,
                    colunaIndex: 11);

              },
              icon: Icon(Icons.notifications_active,
                  color: lembrar ? Colors.white : Colors.green),
              label: Text(
                lembrar ? 'Lembrete Enviado' : 'Enviar Lembrete',
                style: TextStyle(color: lembrar ? Colors.white : Colors.green),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size(10, 30),
                backgroundColor: lembrar ? Colors.green : Colors.white,
              ),
            )
          ],
        ),
        Text.rich(TextSpan(
          text: 'Data da Compra: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
          children: [
            TextSpan(
              text: data,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        )),
        Text.rich(TextSpan(
          text: 'Mês: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
          children: [
            TextSpan(
              text: sheet,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        )),
        
      ],
    );
  }
}
