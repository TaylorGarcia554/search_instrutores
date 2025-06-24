import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class AddChatGuruProvider with ChangeNotifier {
  // Tenta enviar mensagem primeiro

  Future<void> enviarMensagem(
      String nome, String telefone, BuildContext context) async {
    const key =
        'Q5XVUH744SLGIVKTOVJOJQFINCRZEP9RU1ANV59M7F1LAOL4GPZPCFREV4KO384I';
    const accountId = '650ca87fdb54603da2048d70';
    const phoneId = '67aa0b4dc392ae0463b15cee';
    const phoneId2 = '67a20ee5f97631d6166b4bd3';
    const dialogId = '6852baeb6f95e77507614c13';
    const userid = '650d8c3814a92222e951158b';

    String text = 'Olá, Aqui é a atendente Michelle. Tudo bem com você?';

    const headers = <String, String>{
      'accept': 'application/json',
      'Content-Type': 'application/json'
    };

    try {
      //  Primeito ele tenta adicionar em um numero

      final apiCgMessageUrl = Uri.parse(
          'https://s19.chatguru.app/api/v1?key=$key&account_id=$accountId&phone_id=$phoneId&chat_number=$telefone&action=message_send&user_id=$userid&text=$text');

      final response = await http.post(apiCgMessageUrl, headers: headers);

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          log('Mensagem enviada com sucesso: ${data['message']}');
        }
      } else {
        // Se der errado ele enviar em outro numero

        final apiCgMessageUrl = Uri.parse(
            'https://s19.chatguru.app/api/v1?key=$key&account_id=$accountId&phone_id=$phoneId2&chat_number=$telefone&action=message_send&user_id=$userid&text=$text');
        final apiCgDialogoUrl = Uri.parse(
            'https://s19.chatguru.app/api/v1?key=$key&account_id=$accountId&phone_id=$phoneId&chat_number=$telefone&action=dialog_execute&dialog_id=$dialogId');

        final requests = [
          http.post(apiCgMessageUrl, headers: headers),
          (http.post(apiCgDialogoUrl, headers: headers)),
        ];

        final response = await Future.wait(requests);

        log('Response status 0 : ${response[0].statusCode}');
        log('Response body 0 : ${response[0].body}');
        log('-------------');
        log('Response status 1 : ${response[1].statusCode}');
        log('Response body 1 : ${response[1].body}');

        if (response[0].statusCode == 200) {
          final data = json.decode(response[0].body);
          if (data['status'] == 'success') {
            log('Mensagem enviada com sucesso: ${data['message']}');
          }
        } else {
          // Se der errado ele adiciona o chat
          await adicionarChat(nome, telefone);
        }
      }
    } catch (e) {
      return;
    }
  }

  Future<void> adicionarChat(
      String nome, String telefone) async {
    const key =
        'Q5XVUH744SLGIVKTOVJOJQFINCRZEP9RU1ANV59M7F1LAOL4GPZPCFREV4KO384I';
    const accountId = '650ca87fdb54603da2048d70';
    // const phoneId = '67aa0b4dc392ae0463b15cee';
    const phoneId2 = '67a20ee5f97631d6166b4bd3';
    const dialogId = '6852baeb6f95e77507614c13';
    const userid = '650d8c3814a92222e951158b';

    String text = 'Olá, Aqui é a atendente Michelle. Tudo bem com você?';

    const headers = <String, String>{
      'accept': 'application/json',
      'Content-Type': 'application/json'
    };

    try {
      //  Primeito ele tenta adicionar em um numero

      final apiCgMessageUrl = Uri.parse('https://s19.chatguru.app/api/v1'
          '?key=Q5XVUH744SLGIVKTOVJOJQFINCRZEP9RU1ANV59M7F1LAOL4GPZPCFREV4KO384I'
          '&account_id=650ca87fdb54603da2048d70'
          '&phone_id=67aa0b4dc392ae0463b15cee'
          '&chat_number=$telefone'
          '&action=chat_add'
          '&name=$nome'
          '&user_id=650d8c3814a92222e951158b'
          '&dialog_id=6852baeb6f95e77507614c13'
          '&text=Olá, Aqui é a atendente Michelle. Tudo bem com você?');

      final response = await http.post(apiCgMessageUrl, headers: headers);

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          log('Mensagem enviada com sucesso: ${data['message']}');
        }
      } else {
        // Se der errado ele enviar em outro numero

        final apiCgMessageUrl = Uri.parse(
            'https://s19.chatguru.app/api/v1?key=$key&account_id=$accountId&phone_id=$phoneId2&chat_number=$telefone&action=chat_add&name=$nome&user_id=$userid&dialog_id=$dialogId&text=$text');

        final response = await http.post(apiCgMessageUrl, headers: headers);

        log('Response status: ${response.statusCode}');
        log('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            log('Mensagem enviada com sucesso: ${data['message']}');
          } else {
            log('Erro ao adicionar: ${data['message']}');
          }
        } else {
          log('Erro ao adicionar: ${response.body}');
        }
      }
    } catch (e) {
      return;
    }
  }
}

final addChatGuruProvider = ChangeNotifierProvider<AddChatGuruProvider>((ref) {
  return AddChatGuruProvider();
});
