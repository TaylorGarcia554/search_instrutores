import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Cliente {
  final int id;
  final String nome;
  final String email;

  Cliente({required this.id, required this.nome, required this.email});

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nome: json['nome'],
      email: json['email'] ?? '',
    );
  }
}

class CampoBuscaCliente extends StatefulWidget {
  final void Function(Cliente cliente) onClienteSelecionado;

  const CampoBuscaCliente({super.key, required this.onClienteSelecionado});

  @override
  State<CampoBuscaCliente> createState() => _CampoBuscaClienteState();
}

class _CampoBuscaClienteState extends State<CampoBuscaCliente> {
  final TextEditingController _clienteController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;

  static const baseUrl = 'http://app.autoescolaonline.net/api';

  Timer? _debounce;
  List<Cliente> _clientesEncontrados = [];
  bool _isLoading = false;
  String? _error;
  Cliente? _clienteSelecionado;

  void _onChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.length > 2) {
        _buscarClientes(value);
      } else {
        _removeOverlay();
        setState(() => _clientesEncontrados = []);
      }
    });
  }

  Future<void> _buscarClientes(String filtro) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clientes/buscar/email?email=$filtro'),
      );
      log('Buscando clientes com filtro: $filtro');
      log('URL: ${response.request?.url}');
      log('Status Code: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _clientesEncontrados = data.map((e) => Cliente.fromJson(e)).toList();
          _isLoading = false;
        });
        _showOverlay();
      } else {
        setState(() {
          _error = 'Erro ao buscar clientes (status ${response.statusCode})';
          _isLoading = false;
          _clientesEncontrados = [];
        });
        _removeOverlay();
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao buscar clientes: $e';
        _isLoading = false;
        _clientesEncontrados = [];
      });
      _removeOverlay();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _clientesEncontrados.length,
                itemBuilder: (context, index) {
                  final cliente = _clientesEncontrados[index];
                  return ListTile(
                    title: Text(cliente.nome),
                    subtitle: Text(cliente.email),
                    onTap: () {
                      _selecionarCliente(cliente);
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

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selecionarCliente(Cliente cliente) {
    setState(() {
      _clienteSelecionado = cliente;
      _clienteController.text = cliente.email;
      _clientesEncontrados = [];
    });
    widget.onClienteSelecionado(cliente);
    _removeOverlay();
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _clienteController.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _clienteController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              labelText: 'Buscar Cliente',
              border: const OutlineInputBorder(),
              suffixIcon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : (_clienteController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _clienteController.clear();
                            setState(() {
                              _clientesEncontrados = [];
                              _clienteSelecionado = null;
                            });
                            _removeOverlay();
                          },
                        )
                      : const Icon(Icons.search)),
            ),
            onChanged: _onChanged,
          ),
          if (_clienteSelecionado != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Cliente selecionado: ${_clienteSelecionado!.nome.split(' ').length > 1 ? '${_clienteSelecionado!.nome.split(' ')[0]} ${_clienteSelecionado!.nome.split(' ')[1]}' : _clienteSelecionado!.nome}',
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
