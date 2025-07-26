import 'package:flutter/material.dart';

enum MessageType { success, error, info, warning }

OverlayEntry? _currentEntry;


void showCustomMessage(
  BuildContext context,
  String message, {
  MessageType type = MessageType.info,
  Duration duration = const Duration(seconds: 3),
}) {
  _currentEntry?.remove(); // Remove anterior se ainda estiver visível

  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (_) => _CustomMessageWidget(
      message: message,
      type: type,
      duration: duration,
      onClosed: () => _currentEntry = null,
    ),
  );

  _currentEntry = entry;
  overlay.insert(entry);
}

class _CustomMessageWidget extends StatefulWidget {
  final String message;
  final MessageType type;
  final Duration duration;
  final VoidCallback onClosed;

  const _CustomMessageWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onClosed,
  });

  @override
  State<_CustomMessageWidget> createState() => _CustomMessageWidgetState();
}

class _CustomMessageWidgetState extends State<_CustomMessageWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(widget.duration, () async {
      if (!mounted) return;
      await _controller.reverse();
      if (mounted) {
        widget.onClosed();
        if (mounted) {
          // Força o rebuild do Overlay para sair com a animação
          Overlay.of(context).setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData get icon {
    switch (widget.type) {
      case MessageType.success:
        return Icons.check_circle;
      case MessageType.error:
        return Icons.error;
      case MessageType.warning:
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  Color get background {
    switch (widget.type) {
      case MessageType.success:
        return Colors.green.shade600;
      case MessageType.error:
        return Colors.red.shade600;
      case MessageType.warning:
        return Colors.orange.shade700;
      default:
        return Colors.blue.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Positioned(
      // top: 40,
      bottom: 40,
      right: 0,
      child: SlideTransition(
        position: _animation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: media.width * 0.25,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white70,
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
