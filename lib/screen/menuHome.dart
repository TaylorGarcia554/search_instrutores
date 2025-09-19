import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:search_instrutores/components/botaoSearch.dart';
// import 'package:search_instrutores/components/inputs.dart';
import 'package:search_instrutores/models/cliente.dart';
import 'package:search_instrutores/provider/searchProvider.dart';
import 'package:search_instrutores/screen/atualizacoesScreen.dart';
import 'package:search_instrutores/screen/configScreen.dart';
import 'package:search_instrutores/screen/home.dart';
import 'package:search_instrutores/screen/newClient.dart';
import 'package:search_instrutores/screen/newSale.dart';
import 'package:search_instrutores/screen/searchClients.dart';
// import 'package:search_instrutores/utils/cor.dart';

class Menuhome extends ConsumerStatefulWidget {
  const Menuhome({super.key});

  @override
  ConsumerState<Menuhome> createState() => _MenuhomeState();
}

class _MenuhomeState extends ConsumerState<Menuhome> {
  final List<CompraProcessamento> listaDeComprasProcessando = [];
  // int _selectedIndex = 0; // índice selecionado no NavigationRail
  // final NavigationProvider _navigationProvider = NavigationProvider();

  Widget _buildMenuItem(
      IconData icon, String? title, int index, bool collapsed) {
    final selectedIndex = ref.watch(navigationProvider);

    final size = MediaQuery.of(context).size;

    final bool temTitulo = title != null;

    return InkWell(
      onTap: () => ref.read(navigationProvider.notifier).setIndex(index),
      child: Container(
        decoration: BoxDecoration(
          color: selectedIndex == index
              ? Theme.of(context).colorScheme.onPrimary
              : Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Center(child: Icon(icon, color: Colors.white)),
              SizedBox(width: temTitulo ? 0 : 10),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: collapsed ? 0 : 120, // ajusta pro tamanho do texto
                  child: AnimatedOpacity(
                    opacity: collapsed ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      "  ${title!}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                ),
              ),
              // if (title != null)
              //   Text(
              //     title,
              //     style: const TextStyle(
              //       color: Colors.white,
              //       fontSize: 16,
              //       fontFamily: 'Inter',
              //       fontWeight: FontWeight.w500,
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Adicione inicializações aqui se necessário
  }

  @override
  Widget build(BuildContext context) {
    final _selectedIndex = ref.watch(navigationProvider);

    final _controller = TextEditingController();

    final size = MediaQuery.of(context).size;

    final bool tamanhoTela = size.width < 1000;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70), // aumenta a altura do AppBar
        child: AppBar(
          titleSpacing: 0,
          title: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Center(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/iconBusca.png',
                          height: 40,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Combo Search',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 🔎 Nosso botão de pesquisa expansível
                  ExpandableSearchButton(
                    onChanged: (text) {
                      _controller.text = text;
                    },
                    onSearch: () {
                      final termo = _controller.text; // ou pega direto do botão
                      ref.read(cadeProvider.notifier).buscarPorTermoNovo(termo);
                    },
                  ),
                ],
              ),
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 10,
          shadowColor: Colors.black,
        ),
      ),
      body:
          // Padding(
          //   padding: EdgeInsets.all(size.height * 0.08),
          // child:
          Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: tamanhoTela ? 66 : 180, // alterna entre estreito e largo
            color: Theme.of(context).colorScheme.onSecondary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                _buildMenuItem(Icons.dashboard, "Dashboard", 0, tamanhoTela),
                _buildMenuItem(
                    Icons.add_shopping_cart, "Nova Venda", 1, tamanhoTela),
                _buildMenuItem(
                    Icons.person_add, "Novo Cliente", 2, tamanhoTela),
                _buildMenuItem(Icons.sync, "Atualizações", 5, tamanhoTela),
                const Spacer(),
                _buildMenuItem(Icons.settings, "Configuração", 4, tamanhoTela),
                const SizedBox(height: 30),
              ],
            ),
          ),

          // conteúdo da página
          Expanded(
              child: switch (_selectedIndex) {
            0 => const HomeScreen(),
            1 => const NewSale(),
            2 => const NewClient(),
            3 => SearchClientsScreen(),
            4 => const ConfigScreen(),
            5 => const Atualizacoesscreen(),
            _ => const HomeScreen()
          }),
        ],
      ),
    );
  }
}

class NavigationProvider extends StateNotifier<int> {
  NavigationProvider() : super(0);

  void setIndex(int index) {
    state = index;
  }
}

final navigationProvider =
    StateNotifierProvider<NavigationProvider, int>((ref) {
  return NavigationProvider();
});
