
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/market_provider.dart';

class AdvancedDataCard extends ConsumerStatefulWidget {
  final String symbol;

  const AdvancedDataCard({super.key, required this.symbol});

  @override
  ConsumerState<AdvancedDataCard> createState() => _AdvancedDataCardState();
}

class _AdvancedDataCardState extends ConsumerState<AdvancedDataCard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Advanced Intelligence',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Options Chain'),
                Tab(text: 'Holders & Insiders'),
                Tab(text: 'Analyst Ratings'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _OptionsTab(symbol: widget.symbol),
                  _HoldersTab(symbol: widget.symbol),
                  _AnalystsTab(symbol: widget.symbol),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionsTab extends ConsumerWidget {
  final String symbol;
  const _OptionsTab({required this.symbol});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionsAsync = ref.watch(stockOptionsProvider(symbol));

    return optionsAsync.when(
      data: (data) {
        if (data.isEmpty || data['expirations'] == null || (data['expirations'] as List).isEmpty) {
          return const Center(child: Text('No options data available.'));
        }

        final calls = (data['calls'] as Map<String, dynamic>?)?.values.toList() ?? [];
        final puts = (data['puts'] as Map<String, dynamic>?)?.values.toList() ?? [];

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Text('Expiration: ${data['target_date']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const TabBar(tabs: [Tab(text: 'Calls'), Tab(text: 'Puts')]),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildOptionsTable(calls),
                    _buildOptionsTable(puts),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading options data')),
    );
  }

  Widget _buildOptionsTable(List<dynamic> options) {
    if (options.isEmpty) return const Center(child: Text('No entries.'));
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Strike')),
            DataColumn(label: Text('Last Price')),
            DataColumn(label: Text('Bid')),
            DataColumn(label: Text('Ask')),
            DataColumn(label: Text('Volume')),
            DataColumn(label: Text('OI')),
          ],
          rows: options.map<DataRow>((opt) {
            return DataRow(
              cells: [
                DataCell(Text(opt['strike']?.toString() ?? '')),
                DataCell(Text(opt['lastPrice']?.toString() ?? '')),
                DataCell(Text(opt['bid']?.toString() ?? '')),
                DataCell(Text(opt['ask']?.toString() ?? '')),
                DataCell(Text(opt['volume']?.toString() ?? '0')),
                DataCell(Text(opt['openInterest']?.toString() ?? '0')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _HoldersTab extends ConsumerWidget {
  final String symbol;
  const _HoldersTab({required this.symbol});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdersAsync = ref.watch(stockHoldersProvider(symbol));

    return holdersAsync.when(
      data: (data) {
        final insider = (data['insider_transactions'] as List<dynamic>?) ?? [];
        if (insider.isEmpty) {
          return const Center(child: Text('No insider transactions.'));
        }
        return ListView.builder(
          itemCount: insider.length,
          itemBuilder: (context, index) {
            final txn = insider[index];
            return ListTile(
              title: Text('${txn['Insider'] ?? ''} - ${txn['Transaction'] ?? ''}'),
              subtitle: Text('${txn['Text'] ?? ''} | Shares: ${txn['Shares'] ?? ''} | Value: ${txn['Value'] ?? ''}'),
              trailing: Text(txn['Start Date'] ?? ''),
            );
          }
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading holders data')),
    );
  }
}

class _AnalystsTab extends ConsumerWidget {
  final String symbol;
  const _AnalystsTab({required this.symbol});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analystsAsync = ref.watch(stockAnalystsProvider(symbol));

    return analystsAsync.when(
      data: (data) {
        final upgrades = (data['upgrades'] as List<dynamic>?) ?? [];
        if (upgrades.isEmpty) {
          return const Center(child: Text('No analyst data available.'));
        }
        return ListView.builder(
          itemCount: upgrades.length,
          itemBuilder: (context, index) {
            final ug = upgrades[index];
            return ListTile(
              title: Text('${ug['Firm'] ?? ''} -> ${ug['Action'] ?? ''}'),
              subtitle: Text('From: ${ug['From Grade'] ?? '-'} | To: ${ug['To Grade'] ?? '-'}'),
              trailing: Text(ug['Grade Date'] ?? ''),
            );
          }
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading analyst data')),
    );
  }
}
