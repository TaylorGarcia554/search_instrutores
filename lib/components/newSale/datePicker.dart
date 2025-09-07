import 'package:flutter/material.dart';
import 'package:search_instrutores/components/inputs.dart';

class CampoDataCustom extends StatefulWidget {
  final void Function(DateTime?) onChanged;
  final DateTime? dataInicial;
  final String label;

  const CampoDataCustom({
    super.key,
    required this.onChanged,
    required this.label,
    this.dataInicial,
  });

  @override
  State<CampoDataCustom> createState() => _CampoDataCustomState();
}

class _CampoDataCustomState extends State<CampoDataCustom> {
  DateTime? dataSelecionada;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.dataInicial != null) {
      dataSelecionada = widget.dataInicial!;
      controller.text = '${dataSelecionada!.day.toString().padLeft(2, '0')}/'
          '${dataSelecionada!.month.toString().padLeft(2, '0')}/'
          '${dataSelecionada!.year}';
    }
  }

  Future<void> _selecionarData() async {
    final agora = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: dataSelecionada ?? agora,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // cor do dia selecionado
              onPrimary: Colors.white, // cor do texto do dia selecionado
              onSurface: Colors.black, // cor dos dias não selecionados
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // cor dos botões OK/CANCEL
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (data != null) {
      setState(() {
        dataSelecionada = data;
        controller.text = '${data.day.toString().padLeft(2, '0')}/'
            '${data.month.toString().padLeft(2, '0')}/'
            '${data.year}';
      });

      widget.onChanged(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: widget.label,
      hintText: '',
      controller: controller,
      onTap: _selecionarData,
      // readOnly: true,
    );

    // TextFormField(
    //   controller: controller,
    //   readOnly: true,
    //   decoration: InputDecoration(
    //     labelText: widget.label,
    //     labelStyle: TextStyle(
    //       color: Theme.of(context).colorScheme.primary,
    //       fontSize: 12
    //     ),
    //     border: const OutlineInputBorder(),
    //     suffixIcon: const Icon(Icons.calendar_today),
    //   ),
    //   onTap: _selecionarData,
    // );
  }
}
