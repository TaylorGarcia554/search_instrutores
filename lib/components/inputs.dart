import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:search_instrutores/utils/cor.dart';

class CustomTextField extends StatelessWidget {
  final String label; // texto acima do campo
  final String hintText; // placeholder
  final TextEditingController? controller;
  final bool obscureText; // útil para senhas
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final int? maxLines;
  final bool isEditing; // 🔥 novo: controla edição
  final Color colorEditing; // 🔥 cor quando editável
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onTap;
  
  CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines,
    this.validator,
    this.isEditing = true,
    this.colorEditing = const Color(0xFF2F6AE7),
    this.maxLength,
    this.inputFormatters,
    this.onTap,
  });

  // 🔥 mascaradores
  final telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  Widget build(BuildContext context) {
    int? maxLength;
    List<TextInputFormatter> formatters = [];

    final appColors = Theme.of(context).extension<AppColors>()!;

    switch (label) {
      case 'CPF':
        maxLength = 11;
        formatters.add(FilteringTextInputFormatter.digitsOnly);
        break;
      case 'Telefone':
        formatters.add(telefoneFormatter);
        break;
      case 'Valor':
        formatters
            .add(FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')));
        break;
      case 'Nome':
        maxLength = 60;
        break;
      case 'Email':
        maxLength = 255;
        break;
    }

  
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
            child: Text(
              label,
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
                color: Colors.black.withAlpha(100),
                offset: const Offset(2, 2),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            readOnly: !isEditing,
            keyboardType: keyboardType,
            maxLength: maxLength,
            maxLines: maxLines ?? 1,
            inputFormatters: inputFormatters,
            validator: validator,
            onTap: onTap,
            decoration: InputDecoration(
              counterText: "",
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFFB0B0B0),
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: appColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  // color: Colors.black,
                  color: appColors.inputBorder,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: appColors.inputBorder,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: isEditing ? colorEditing : appColors.inputBorder,
                  width: 2,
                ),
              ),
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
