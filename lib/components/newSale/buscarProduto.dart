import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Produto {
  final int id;
  final String nome;

  Produto({required this.id, required this.nome});

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(id: json['id'], nome: json['nome']);
  }
}

class DropdownProdutos extends StatefulWidget {
  final void Function(Produto)? onProdutoSelecionado;

  const DropdownProdutos({super.key, this.onProdutoSelecionado});

  @override
  State<DropdownProdutos> createState() => _DropdownProdutosState();
}

class _DropdownProdutosState extends State<DropdownProdutos> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<Produto> _produtos = [];
  bool _isLoading = false;
  Produto? _produtoSelecionado;

  @override
  void initState() {
    super.initState();
    _fetchProdutos();
  }

  Future<void> _fetchProdutos() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final url = Uri.parse('http://app.autoescolaonline.net/api/produtos');
    try {
      final response = await http.get(url);
      if (!mounted) return; // Verifica de novo após a requisição

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _produtos = data.map((e) => Produto.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        // Aqui você pode mostrar um erro
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      // Trate erro
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return; // já está aberto

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height),
          child: Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 200,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _produtos.length,
                itemBuilder: (context, index) {
                  final produto = _produtos[index];
                  return ListTile(
                    title: Text(produto.nome),
                    onTap: () {
                      setState(() {
                        _produtoSelecionado = produto;
                      });
                      if (widget.onProdutoSelecionado != null) {
                        widget.onProdutoSelecionado!(produto);
                      }

                      _removeOverlay();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _isLoading
            ? null
            : () {
                if (_overlayEntry == null) {
                  _showOverlay();
                } else {
                  _removeOverlay();
                }
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  _produtoSelecionado?.nome ?? 'Selecione um produto',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
