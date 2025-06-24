import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/models/dbHelper.dart';

// Estado que guarda os ids atualizados, exemplo Set<int>
class AtualizadoNotifier extends StateNotifier<Set<int>> {
  AtualizadoNotifier() : super({});

  bool isAtualizado(int id) => state.contains(id);

  void marcarAtualizado(int id) async {
    await DBHelper.marcarComoAtualizado(id);

    state = {...state, id}; // adiciona id ao set (novo estado)
  }

   Future<void> carregarAtualizadosDoBanco() async {
    final registros = await DBHelper.buscarTodosAtualizados();
    final ids = registros.map<int>((r) => r['id'] as int).toSet();
    state = ids;
  }
}

final atualizadoProvider = StateNotifierProvider<AtualizadoNotifier, Set<int>>(
  (ref) => AtualizadoNotifier(),
);
