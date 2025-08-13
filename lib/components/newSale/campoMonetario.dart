import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CampoMonetario extends StatefulWidget {
  final void Function(double) onChanged;
  final String labelText;

  const CampoMonetario(
      {super.key, required this.onChanged, required this.labelText});

  @override
  State<CampoMonetario> createState() => _CampoMonetarioState();
}

class _CampoMonetarioState extends State<CampoMonetario> {
  final TextEditingController _controller = TextEditingController();
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: '',
    decimalDigits: 2,
  );

  String _numericOnly(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

  void _onChanged(String value) {
    String onlyNumbers = _numericOnly(value);
    if (onlyNumbers.isEmpty) onlyNumbers = '0';

    double valor = double.parse(onlyNumbers) / 100;

    String newText = _formatter.format(valor);

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );

    widget.onChanged(valor);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: const OutlineInputBorder(),
        prefixText: 'R\$ ',
      ),
      onChanged: _onChanged,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}
