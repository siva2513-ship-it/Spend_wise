import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;

  const SummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
  });

  double get netBalance => totalIncome - totalExpense;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 600;

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMetricTile(
                    title: 'Total Balance',
                    amount: currencyFormatter.format(netBalance),
                    icon: Icons.account_balance_wallet,
                    iconBg: isDark ? const Color(0xFF0F766E).withAlpha(100) : const Color(0xFFCCFBF1),
                    iconColor: const Color(0xFF0F766E),
                    isPrimary: true,
                    context: context,
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          title: 'Income',
                          amount: '+${currencyFormatter.format(totalIncome)}',
                          icon: Icons.arrow_downward,
                          iconBg: isDark ? const Color(0xFF065F46).withAlpha(100) : const Color(0xFFD1FAE5),
                          iconColor: const Color(0xFF10B981),
                          context: context,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          title: 'Expenses',
                          amount: '-${currencyFormatter.format(totalExpense)}',
                          icon: Icons.arrow_upward,
                          iconBg: isDark ? const Color(0xFF7F1D1D).withAlpha(100) : const Color(0xFFFEE2E2),
                          iconColor: const Color(0xFFEF4444),
                          context: context,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _buildMetricTile(
                    title: 'Total Balance',
                    amount: currencyFormatter.format(netBalance),
                    icon: Icons.account_balance_wallet,
                    iconBg: isDark ? const Color(0xFF0F766E).withAlpha(100) : const Color(0xFFCCFBF1),
                    iconColor: const Color(0xFF0F766E),
                    isPrimary: true,
                    context: context,
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  flex: 3,
                  child: _buildMetricTile(
                    title: 'Total Income',
                    amount: '+${currencyFormatter.format(totalIncome)}',
                    icon: Icons.arrow_downward,
                    iconBg: isDark ? const Color(0xFF065F46).withAlpha(100) : const Color(0xFFD1FAE5),
                    iconColor: const Color(0xFF10B981),
                    context: context,
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  flex: 3,
                  child: _buildMetricTile(
                    title: 'Total Expenses',
                    amount: '-${currencyFormatter.format(totalExpense)}',
                    icon: Icons.arrow_upward,
                    iconBg: isDark ? const Color(0xFF7F1D1D).withAlpha(100) : const Color(0xFFFEE2E2),
                    iconColor: const Color(0xFFEF4444),
                    context: context,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String amount,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required BuildContext context,
    bool isPrimary = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  amount,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: isPrimary ? FontWeight.w800 : FontWeight.w700,
                    color: isPrimary
                        ? (isDark ? Colors.white : const Color(0xFF0F172A))
                        : iconColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

