import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_item.dart';

class TransactionCard extends StatelessWidget {
  final TransactionItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormatter = DateFormat('MMM d, yyyy');

    final isIncome = item.type == TransactionType.income;
    final amountColor = isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final amountPrefix = isIncome ? '+' : '-';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.category.color.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.category.icon,
                  color: item.category.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        Text(
                          item.category.displayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '•',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          dateFormatter.format(item.date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    if (item.note.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.note,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$amountPrefix${currencyFormatter.format(item.amount)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: amountColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        tooltip: 'Edit',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        onPressed: onEdit,
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: const Color(0xFFEF4444),
                        tooltip: 'Delete',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
