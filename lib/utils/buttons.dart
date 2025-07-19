import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ButtonsWidget extends ConsumerWidget {
  const ButtonsWidget(this.text, this.icon, this.onPressed, {Key? key}) : super(key: key);
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const ButtonsWidget.named({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 160, // limite máximo se quiser travar
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          tapTargetSize:
              MaterialTapTargetSize.shrinkWrap, // reduz área de toque
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Colors.black, // cor da borda
              width: 1.5, // espessura da borda
            ),
          ),
        ),
      ),
    );
  }
}
