import 'package:flutter/material.dart';
import 'package:search_instrutores/utils/cor.dart';

class Formatadorhelpers {
  String formatPhoneNumber(String value) {
    if (value.length == 11) {
      return '(${value.substring(0, 2)}) ${value.substring(2, 7)}-${value.substring(7)}';
    } else if (value.length == 10) {
      return '(${value.substring(0, 2)}) ${value.substring(2, 6)}-${value.substring(6)}';
    } else {
      return value; // Return the original value if it doesn't match expected lengths
    }
  }

  String formatCPFNumber(String value) {
    final letras = value.length;
    print('CPF Length: $letras'); // Debugging line to check length

    switch (letras) {
      case 14:
        return '${value.substring(0, 2)}.${value.substring(2, 5)}.${value.substring(5, 8)}/${value.substring(8, 12)}-${value.substring(12, 14)}';
      case 11:
        return '${value.substring(0, 3)}.${value.substring(3, 6)}.${value.substring(6, 9)}-${value.substring(9)}';
      default:
        return value; // Return the original value if it doesn't match expected lengths
    }
  }

  String formatDinheiro(double value) {
    if (value.isNaN || value.isInfinite) {
      return '0,00'; // Return a default value for invalid numbers
    }
    if (value < 0) {
      return '-${value.abs().toStringAsFixed(2).replaceAll('.', ',')}';
    }

    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String formatData(String data) {
    if (data.isEmpty) return '';

    final partes = data.split('-');
    if (partes.length != 3) return data; // Retorna a data original se não estiver no formato esperado

    final ano = partes[0].substring(2);
    final mes = partes[1].padLeft(2, '0');
    final dia = partes[2].padLeft(2, '0');

    return '$dia/$mes/$ano';
  }

  Widget customField({
    required TextEditingController controller,
    required String label,
    required bool isEditing,
    required Color textColor,
    required double fontSize,
    required bool filled,
    required int maxLines,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: !isEditing, // usa readOnly em vez de enabled
      enableInteractiveSelection: true, // garante que pode selecionar/copiar
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
      ),
      keyboardType: TextInputType.multiline,
      maxLines: maxLines, // permite altura dinâmica
      minLines: 1, // começa com uma linha
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Cor.texto),
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        filled: filled,
        fillColor: Color.fromARGB(255, 217, 217, 217),
        border: filled
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.black, width: 1.5),
              )
            : InputBorder.none,
        enabledBorder: filled
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: isEditing ? Colors.blue : Colors.black,
                    width: isEditing ? 2 : 1.5),
              )
            : InputBorder.none,
        disabledBorder: filled
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black, width: 1.5),
              )
            : InputBorder.none,
        focusedBorder: filled
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black, width: 1.5),
              )
            : InputBorder.none,
      ),
    );
  }


}
