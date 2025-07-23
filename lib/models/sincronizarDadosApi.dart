import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:search_instrutores/models/dbHelperNew.dart';

class SincronizadorApiLocal {
  static final ValueNotifier<bool> isLoading2 = ValueNotifier(false);

  static const baseUrl =
      'http://app.autoescolaonline.net/api'; // troque pela sua URL real

  static Future<void> sincronizarTodosOsDados() async {
    isLoading2.value = true; // Início

    try {
      await _sincronizarClientes();
      await _sincronizarProdutos();
      await _sincronizarCompras();
      log('Sincronização concluída.');
    } catch (e) {
      log('Erro na sincronização: $e');
    } finally {
      isLoading2.value = false; // Fim
    }
  }

  static Future<void> _sincronizarClientes() async {
    final response = await http.get(Uri.parse('$baseUrl/clientes'));

    if (response.statusCode == 200) {
      final List<dynamic> dados = json.decode(response.body);

      for (var item in dados) {
        final cliente = {
          'id': item['id'],
          'nome': item['nome'],
          'email': item['email'],
          'telefone': item['telefone'],
          'cpf': item['cpf'],
          'observacao': item['observacao'],
          'created_at': item['created_at'],
          'updated_at': item['updated_at'],
        };
        log('Cliente: $cliente, ID: ${cliente['id']}');
        await DBApiHelper.inserirCliente(Map<String, dynamic>.from(cliente));
      }
    } else {
      throw Exception('Erro ao buscar clientes: ${response.statusCode}');
    }
  }

  static Future<void> _sincronizarProdutos() async {
    final response = await http.get(Uri.parse('$baseUrl/produtos'));

    if (response.statusCode == 200) {
      final List<dynamic> dados = json.decode(response.body);

      for (var item in dados) {
        final produtos = {
          'id': item['id'],
          'nome': item['nome'],
          'preco': item['preco'],
          'created_at': item['created_at'],
          'updated_at': item['updated_at'],
        };
        log('Produto: $produtos, ID: ${produtos['id']}');
        await DBApiHelper.inserirProduto(Map<String, dynamic>.from(produtos));
      }
    } else {
      throw Exception('Erro ao buscar produtos: ${response.statusCode}');
    }
  }

  static Future<void> _sincronizarCompras() async {
    final response = await http.get(Uri.parse('$baseUrl/compras'));

    if (response.statusCode == 200) {
      final List<dynamic> dados = json.decode(response.body);

      for (var item in dados) {
        if (item == null) continue;

        final cliente = item['cliente'];
        final produto = item['produto'];

        if (cliente == null || produto == null) {
          log('[!] Compra ID ${item['id']} ignorada porque cliente ou produto está nulo.');
          continue;
        }

        final compra = {
          'id': item['id'],
          'client_id': item['cliente']['id'],
          'produto_id': item['produto']['id'],
          'data_pedido': item['data_pedido'],
          'data_postagem': item['data_postagem'],
          'valor': item['valor'],
          'pagamento_id': item['pagamento_id'],
          'created_at': item['created_at'],
          'updated_at': item['updated_at'],
          'entrega': item['entrega'],
          'observacao': item['observacao'],
        };
        log('Compra: $compra, ID: ${compra['id']}');
        await DBApiHelper.inserirCompras(Map<String, dynamic>.from(compra));
      }
    } else {
      throw Exception('Erro ao buscar compras: ${response.statusCode}');
    }
  }


}
