import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:search_instrutores/components/graficoHome.dart';
import 'package:search_instrutores/models/cliente.dart';
import 'package:search_instrutores/provider/searchProvider.dart';
import 'package:search_instrutores/screen/home/cardValue.dart';
import 'package:search_instrutores/components/cardClients.dart';
import 'package:search_instrutores/utils/cor.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<CompraProcessamento> listaDeComprasProcessando = [];
  Timer? _timer;

  String saudacaoDoDia() {
    final hora = DateTime.now().hour;

    if (hora >= 5 && hora < 12) {
      return "Bom dia!";
    } else if (hora >= 12 && hora < 18) {
      return "Boa tarde!";
    } else {
      return "Boa noite!";
    }
  }

  String dataFormatada() {
    final agora = DateTime.now();

    // Locale "pt_BR" precisa estar configurado no projeto
    final formatador = DateFormat("EEEE, d 'de' MMMM 'de' y", "pt_BR");

    // Capitalizar a primeira letra do dia da semana
    String data = formatador.format(agora);
    return "Hoje é ${data[0].toUpperCase()}${data.substring(1)}";
  }

  Map<String, dynamic>? _ultimoResultado;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 20), (_) async {
      if (!mounted) return;

      final clientes =
          await ref.read(searchProvider.notifier).buscarClientesNovosPorMes();

      final vendas =
          await ref.read(searchProvider.notifier).buscarVendasPorMes();

      // Cria um "snapshot" do estado atual
      final novoResultado = {
        "clientes": clientes,
        "vendas": vendas,
      };

      // Compara com o último snapshot
      if (_ultimoResultado == null ||
          jsonEncode(_ultimoResultado) != jsonEncode(novoResultado)) {
        _ultimoResultado = novoResultado;
        ref.read(refreshTriggerProvider.notifier).state++;
        print('🔄 Dados mudaram, atualizando...');
      } else {
        print('✅ Sem mudanças, não atualizei.');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(size.height * 0.04),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Olá, ${saudacaoDoDia()}",
                      style: TextStyle(
                        fontSize: size.width * 0.012,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: size.height * 0.75,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        border: Border.all(
                            width: 1.5,
                            color: Theme.of(context)
                                .extension<AppColors>()!
                                .inputBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(120),
                            spreadRadius: 0,
                            blurRadius: 4,
                            offset: const Offset(7, 6), // sombra para baixo
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              'Aguardando Entrega',
                              style: TextStyle(
                                fontSize: size.width * 0.011,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: StreamBuilder<List<Map<String, dynamic>>>(
                              stream: SearchProvider()
                                  .buscarProcessosIniciadosStream(
                                      const Duration(seconds: 60)),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return const Center(
                                      child: Text('Erro ao carregar dados'));
                                }

                                final dados = snapshot.data ?? [];

                                if (dados.isEmpty) {
                                  return const Center(
                                      child: Text('Todas vendas entregues!'));
                                }

                                final listaDeComprasProcessando = dados
                                    .map((e) => CompraProcessamento.fromJson(e))
                                    .toList();

                                return ListView.builder(
                                  padding: const EdgeInsets.all(8),
                                  itemCount: listaDeComprasProcessando.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 1),
                                      child: CardClients(
                                        compra:
                                            listaDeComprasProcessando[index],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: size.width * 0.05,
              ),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        dataFormatada(),
                        style: TextStyle(
                          fontSize: size.width * 0.011,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const CardValue(),
                    SizedBox(
                      height: size.height * 0.05,
                    ),
                    Container(
                      height: size.height * 0.4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(size.height * 0.02),
                          bottomLeft: Radius.circular(size.height * 0.02),
                          bottomRight: Radius.circular(size.height * 0.02),
                        ),
                        color: Theme.of(context).cardColor,
                        border: Border.all(
                            width: 1.5,
                            color: Theme.of(context)
                                .extension<AppColors>()!
                                .inputBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(120),
                            spreadRadius: 0,
                            blurRadius: 4,
                            offset: const Offset(7, 6), // sombra para baixo
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Expanded(
                            child: Text(
                              'Desempenho no mês'
                            ),
                          ),
                          Expanded(
                            flex: 9,
                            child: Padding(
                              padding: EdgeInsets.all(size.height * 0.02),
                              child: const ComprasGrafico(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
