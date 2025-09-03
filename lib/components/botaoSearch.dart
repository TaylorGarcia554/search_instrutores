import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/screen/menuHome.dart';
import 'package:search_instrutores/utils/cor.dart';

class ExpandableSearchButton extends ConsumerStatefulWidget {
  final Function(String) onChanged;
  final Function() onSearch;

  const ExpandableSearchButton({
    super.key,
    required this.onChanged,
    required this.onSearch,
  });

  @override
  ConsumerState<ExpandableSearchButton> createState() =>
      _ExpandableSearchButtonState();
}

class _ExpandableSearchButtonState
    extends ConsumerState<ExpandableSearchButton> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _expanded = false;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      // 🔎 Aqui você terá o lugar pra mudar o notifier
      final container = ProviderScope.containerOf(context);

      if (_focusNode.hasFocus) {
        container.read(searchFocusProvider.notifier).setFocus(1);
      } else {
        container.read(searchFocusProvider.notifier).setFocus(0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final _selectedIndex = ref.watch(navigationProvider);

    // Se o índice não for 3, fecha automaticamente
    if (_selectedIndex != 3 && _expanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _expanded = false;
            _controller.clear();
          });
        }
      });
    }

    Widget _buildSearchField({VoidCallback? onTap}) {
      return TextField(
        focusNode: _focusNode,
        controller: _controller,
        onChanged: widget.onChanged,
        onSubmitted: (_) => widget.onSearch(),
        onTap: onTap, // 👈 se não precisar, passa null
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).extension<AppColors>()!.inputBackground,
          hintText: 'Pesquisar',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).extension<AppColors>()!.inputBorder,
            ),
          ),
          isDense: true,
          
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 12,
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _expanded
          ? size.width * 0.5
          : size.width * 0.17, // quando fechado, só botão
      curve: Curves.easeInOut,
      child: Row(
        children: [
          // TextField com animação de tamanho
          Expanded(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _expanded
                  ? _buildSearchField() // sem onTap
                  : _buildSearchField(
                      onTap: () {
                        setState(() {
                          _expanded = true;
                          ref.read(navigationProvider.notifier).setIndex(3);
                        });
                      },
                    ),
            ),
          ),

          // const SizedBox(width: 8),

          // Botão corrigido
          Visibility(
            visible: _expanded,
            child: TextButton(
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                setState(() {
                  _controller.clear();
                  widget.onChanged('');
                  _focusNode.unfocus();
                  _expanded = false;
                  ref.read(navigationProvider.notifier).setIndex(0);
                });
              },
              child: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchFocusNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setFocus(int value) {
    state = value;
  }
}

final searchFocusProvider =
    NotifierProvider<SearchFocusNotifier, int>(() => SearchFocusNotifier());
