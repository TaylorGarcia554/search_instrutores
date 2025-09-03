import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
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

  String formatData(String data, {bool semAno = false}) {
    if (data.isEmpty) return '';

    // Pega só a parte antes do espaço (data)
    final dataSomente = data.split(' ').first;

    final partes = dataSomente.split('-');
    if (partes.length != 3) return data;

    final ano = partes[0].substring(2);
    final mes = partes[1].padLeft(2, '0');
    final dia = partes[2].padLeft(2, '0');

    if (semAno) {
      return '$dia/$mes';
    }

    return '$dia/$mes/$ano';
  }

  final telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );
}
