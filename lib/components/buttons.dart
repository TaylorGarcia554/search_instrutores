import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/utils/cor.dart';

class ButtonsWidget extends ConsumerStatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String text;
  final bool isLoading;

  const ButtonsWidget({
    required this.onPressed,
    required this.icon,
    required this.text,
    this.isLoading = false,
    super.key,
  });

  @override
  ConsumerState<ButtonsWidget> createState() => _ButtonsWidgetState();
}

class _ButtonsWidgetState extends ConsumerState<ButtonsWidget> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: ElevatedButton.icon(
          onPressed: widget.isLoading
              ? null
              : widget.onPressed, // desabilita botão no loading
          icon: widget.isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _isHovering ? Colors.green : Colors.black,
                  ),
                )
              : Icon(widget.icon),
          label: widget.isLoading
              ? const Text('Carregando...')
              : Text(widget.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isHovering
                ? const Color.fromARGB(255, 225, 254, 224)
                : Colors.white,
            foregroundColor: Cor.texto,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: _isHovering
                    ? const Color.fromARGB(255, 0, 253, 8)
                    : Colors.black,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
