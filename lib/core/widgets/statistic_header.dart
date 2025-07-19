import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class StatisticsHeader extends StatelessWidget {
  final int completati;   // Task completate o articoli acquistati
  final int inCorso;      // Task in corso o articoli da acquistare
  final int totali;

  final String labelCompletati;
  final String labelInCorso;
  final String labelTotali;

  const StatisticsHeader({
    super.key,
    required this.completati,
    required this.inCorso,
    required this.totali,
    this.labelCompletati = 'Completate',
    this.labelInCorso = 'In corso',
    this.labelTotali = 'Totali',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              labelInCorso,
              inCorso.toString(),
              Colors.orange,
              labelInCorso == "Da comprare" ? FluentIcons.money_20_filled : FluentIcons.arrow_sync_circle_20_filled,
            ),
          ),
          _divider(),
          Expanded(
            child: _buildStatItem(
              labelCompletati,
              completati.toString(),
              Colors.green,
              labelCompletati == "Acquistati" ? FluentIcons.receipt_money_20_filled : FluentIcons.checkmark_circle_20_filled,
            ),
          ),
          _divider(),
          Expanded(
            child: _buildStatItem(
              labelTotali,
              totali.toString(),
              Colors.blue,
              labelCompletati == "Acquistati" ? FluentIcons.cart_20_filled : FluentIcons.clipboard_task_list_ltr_20_filled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}