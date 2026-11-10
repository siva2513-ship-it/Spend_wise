import 'package:flutter/material.dart';
import 'models/transaction_item.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'widgets/category_breakdown.dart';
import 'widgets/responsive_layout.dart';
import 'widgets/storage_info_banner.dart';
import 'widgets/summary_card.dart';
import 'widgets/transaction_card.dart';
import 'widgets/transaction_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await StorageService.init();
  runApp(SpendWiseApp(storageService: storageService));
}

class SpendWiseApp extends StatefulWidget {
  final StorageService storageService;

  const SpendWiseApp({super.key, required this.storageService});

  @override
  State<SpendWiseApp> createState() => _SpendWiseAppState();
}

class _SpendWiseAppState extends State<SpendWiseApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendWise – Personal Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      // Supporting Flutter client-side routing & deep linking
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Any subroute like /dashboard, /transactions, /analytics, or unknown routes
        // map smoothly to the main dashboard without causing 404s on browser reload.
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => SpendWiseDashboard(
            storageService: widget.storageService,
            onToggleTheme: _toggleTheme,
            currentThemeMode: _themeMode,
          ),
        );
      },
    );
  }
}

class SpendWiseDashboard extends StatefulWidget {
  final StorageService storageService;
  final VoidCallback onToggleTheme;
  final ThemeMode currentThemeMode;

  const SpendWiseDashboard({
    super.key,
    required this.storageService,
    required this.onToggleTheme,
    required this.currentThemeMode,
  });

  @override
  State<SpendWiseDashboard> createState() => _SpendWiseDashboardState();
}

class _SpendWiseDashboardState extends State<SpendWiseDashboard> {
  List<TransactionItem> _transactions = [];
  bool _isLoading = true;
  int _selectedTabIndex = 0; // 0: All, 1: Expenses, 2: Income
  String _searchQuery = '';
  TransactionCategory? _selectedCategoryFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final items = await widget.storageService.loadTransactions();
    setState(() {
      _transactions = items;
      _isLoading = false;
    });
  }

  Future<void> _addOrUpdateTransaction(TransactionItem item) async {
    final index = _transactions.indexWhere((t) => t.id == item.id);
    final updatedList = List<TransactionItem>.from(_transactions);

    if (index >= 0) {
      updatedList[index] = item;
    } else {
      updatedList.insert(0, item);
    }
    updatedList.sort((a, b) => b.date.compareTo(a.date));

    setState(() => _transactions = updatedList);
    await widget.storageService.saveTransactions(updatedList);
  }

  Future<void> _deleteTransaction(String id) async {
    final updatedList = _transactions.where((t) => t.id != id).toList();
    setState(() => _transactions = updatedList);
    await widget.storageService.saveTransactions(updatedList);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Transactions?'),
        content: const Text(
          'This will permanently delete all locally stored transactions in this browser. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.storageService.clearAllTransactions();
      setState(() => _transactions = []);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All local transactions cleared')),
        );
      }
    }
  }

  void _openTransactionDialog([TransactionItem? item]) async {
    final result = await TransactionDialog.show(context, existingItem: item);
    if (result != null) {
      await _addOrUpdateTransaction(result);
    }
  }

  List<TransactionItem> get _filteredTransactions {
    return _transactions.where((item) {
      if (_selectedTabIndex == 1 && item.type != TransactionType.expense) {
        return false;
      }
      if (_selectedTabIndex == 2 && item.type != TransactionType.income) {
        return false;
      }
      if (_selectedCategoryFilter != null &&
          item.category != _selectedCategoryFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = item.title.toLowerCase().contains(query);
        final matchesNote = item.note.toLowerCase().contains(query);
        final matchesCategory = item.category.displayName.toLowerCase().contains(query);
        return matchesTitle || matchesNote || matchesCategory;
      }
      return true;
    }).toList();
  }

  double get _totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get _totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, item) => sum + item.amount);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F766E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.wallet, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'SpendWise',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6).withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Web Service',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F766E),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            tooltip: 'Clear Storage',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _clearAllData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
        onPressed: () => _openTransactionDialog(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 24 : 16,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const StorageInfoBanner(),
                        const SizedBox(height: 16),
                        SummaryCard(
                          totalIncome: _totalIncome,
                          totalExpense: _totalExpense,
                        ),
                        const SizedBox(height: 16),
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: _buildTransactionsList(theme),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 4,
                                child: CategoryBreakdownCard(
                                  transactions: _transactions,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          CategoryBreakdownCard(transactions: _transactions),
                          const SizedBox(height: 16),
                          _buildTransactionsList(theme),
                        ],
                        const SizedBox(height: 80), // Fab spacing
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTransactionsList(ThemeData theme) {
    final filtered = _filteredTransactions;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tabs & Search bar
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(value: 0, label: Text('All')),
                          ButtonSegment(value: 1, label: Text('Expenses')),
                          ButtonSegment(value: 2, label: Text('Income')),
                        ],
                        selected: {_selectedTabIndex},
                        onSelectionChanged: (set) {
                          setState(() => _selectedTabIndex = set.first);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transactions (${filtered.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (_selectedCategoryFilter != null)
              TextButton.icon(
                icon: const Icon(Icons.filter_alt_off, size: 16),
                label: const Text('Clear Filter'),
                onPressed: () => setState(() => _selectedCategoryFilter = null),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (filtered.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No matching transactions found.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = filtered[index];
              return TransactionCard(
                item: item,
                onEdit: () => _openTransactionDialog(item),
                onDelete: () => _deleteTransaction(item.id),
              );
            },
          ),
      ],
    );
  }
}
