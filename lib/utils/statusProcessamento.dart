import 'package:flutter/material.dart';

class StatusProcessamento {
  final int id;
  final String nome;
  final Color cor;
  final Color corBorda;

  const StatusProcessamento({
    required this.id,
    required this.nome,
    required this.cor,
    required this.corBorda,
  });

  // Lista fixa com todos os status possíveis
  static const List<StatusProcessamento> todosStatus = [
    StatusProcessamento(
      id: 1,
      nome: 'Personalizando',
      cor: Color(0xffD0FDE2),
      corBorda: Color(0xff02FF39),
    ),
    StatusProcessamento(
      id: 2,
      nome: 'Em produção',
      cor: Color(0xffFCFFAC),
      corBorda: Color(0xffEEFF00),
    ),
    StatusProcessamento(
      id: 3,
      nome: 'Enviado',
      cor: Colors.white,
      corBorda: Colors.black,
    ),
  ];

  // Função para buscar o status pelo id
  static StatusProcessamento? getPorId(int id) {
    try {
      return todosStatus.firstWhere((status) => status.id == id);
    } catch (e) {
      return null; // ou um status padrão, se preferir
    }
  }
}
