import 'package:flutter/material.dart';

class StorageInfoBanner extends StatelessWidget {
  const StorageInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF064E3B).withAlpha(80) : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF047857) : const Color(0xFFA7F3D0),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '100% Client-Side Local Storage (Offline Ready)',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFD1FAE5) : const Color(0xFF065F46),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Transactions persist across refreshes via browser SharedPreferences. No remote database or external API dependencies.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF047857),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, size: 18),
            color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
            tooltip: 'Persistence Details',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _showPersistenceDialog(context),
          ),
        ],
      ),
    );
  }

  static void _showPersistenceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.storage, color: Color(0xFF0F766E)),
              SizedBox(width: 10),
              Text('Data Persistence Architecture'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How SpendWise Stores Your Data:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Local Storage: All transactions are serialized to JSON and stored directly within your web browser using HTML5 IndexedDB / LocalStorage backing SharedPreferences.\n\n'
                '• Page Refresh Safe: Reloading or closing the tab will retain all your transactions and balances.\n\n'
                '• Privacy First: Zero server-side database. No telemetry, third-party trackers, or cloud sync.\n\n'
                '• Important Limitation: Clearing browser cookies/cache or using Incognito/Private mode will reset the locally stored transactions. Data does NOT automatically synchronize across different devices or separate browsers.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Understood'),
            ),
          ],
        );
      },
    );
  }
}

