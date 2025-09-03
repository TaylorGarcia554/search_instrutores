import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:search_instrutores/utils/cor.dart';

class CampoMonetario extends StatefulWidget {
  final String labelText;
  final double initialValue;
  final ValueChanged<double> onChanged;

  const CampoMonetario({
    super.key,
    required this.labelText,
    required this.onChanged,
    this.initialValue = 0.0,
  });

  @override
  State<CampoMonetario> createState() => _CampoMonetarioState();
}

class _CampoMonetarioState extends State<CampoMonetario> {
  late final TextEditingController _controller;
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: '',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _formatter.format(widget.initialValue),
    );
  }

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

    final appColors = Theme.of(context).extension<AppColors>()!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
            child: Text(
              widget.labelText,
              style: const TextStyle(
                color: Color(0xFF797979),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                offset: const Offset(2, 2),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: TextFormField(
            controller: _controller,
            keyboardType: TextInputType.number,
            onChanged: _onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: appColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: appColors.inputBorder , width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: appColors.inputBorder, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide:
                    const BorderSide(color: Color(0xFF2F6AE7), width: 2),
              ),
              prefixText: 'R\$ ',
            ),
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
