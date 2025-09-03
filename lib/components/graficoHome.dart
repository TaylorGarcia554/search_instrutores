import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/provider/searchProvider.dart';
import 'package:search_instrutores/utils/cor.dart';
import 'package:intl/intl.dart';

class ComprasGrafico extends ConsumerWidget {
  const ComprasGrafico({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(buscarDadosGrafico);

    final size = MediaQuery.of(context).size;

    final formatoMoeda = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return asyncData.when(
      data: (dados) {
        // lista de nomes dos meses em PT-BR
        const meses = [
          "",
          "Jan",
          "Fev",
          "Mar",
          "Abr",
          "Mai",
          "Jun",
          "Jul",
          "Ago",
          "Set",
          "Out",
          "Nov",
          "Dez",
        ];

        // transformar os dados em spots para o gráfico
        final barGroups = dados.asMap().entries.map((entry) {
          final index = entry.key;
          final compra = entry.value;
          // final mes = compra['mes'] as int;
          final total = (compra['total'] as num).toDouble();

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: total,
                width: size.width * 0.022,
                borderRadius: BorderRadius.circular(size.width * 0.007),
                color: Theme.of(context).extension<AppColors>()!.chartColor,
              ),
            ],
          );
        }).toList();

        final borda = FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1),
              left: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1),
            ));

        final mostrarValores = BarTouchTooltipData(
          // tooltipBgColor: Colors.black87, // fundo do tooltip
          tooltipMargin: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              formatoMoeda.format(rod.toY), // texto que aparece
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            );
          },
        );

        return BarChart(
          BarChartData(
            gridData: const FlGridData(
              show: true,
              drawHorizontalLine: true,
              drawVerticalLine: false,
              horizontalInterval: 5000,
            ),
            borderData: borda,
            alignment: BarChartAlignment.spaceAround,
            // maxY: (dados.map((e) => e['total'] as num).reduce((a, b) => a > b ? a : b) as double) * 1.2,
            minY: 0,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: mostrarValores,
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: size.width * 0.025,
                  getTitlesWidget: (value, meta) {
                    String text;

                    if (value >= 1000) {
                      text =
                          "${(value ~/ 1000)}k"; // divide por 1000 e coloca "k"
                    } else {
                      text = value.toInt().toString();
                    }

                    return Text(
                      text,
                      style: TextStyle(
                        fontSize: size.width * 0.01,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xffA0A0A0),
                      ),
                    );
                  },
                ),
              ),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= dados.length) {
                      return const SizedBox();
                    }
                    final mes = dados[index]['mes'] as int;
                    return Text(meses[mes],
                        style: TextStyle(
                            fontSize: size.width * 0.009,
                            color: const Color(0xffA0A0A0)));
                  },
                ),
              ),
            ),
            barGroups: barGroups,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text("Erro: $err")),
    );
  }
}
