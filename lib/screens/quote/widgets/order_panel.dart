import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/market_provider.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class OrderPanel extends ConsumerStatefulWidget {
  final String symbol;
  const OrderPanel({Key? key, required this.symbol}) : super(key: key);

  @override
  ConsumerState<OrderPanel> createState() => _OrderPanelState();
}

class _OrderPanelState extends ConsumerState<OrderPanel> {
  final TextEditingController _qtyController = TextEditingController();
  bool _isBuy = true;
  int _quantity = 0;

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quoteAsync = ref.watch(stockQuoteProvider(widget.symbol));
    final portfolio = ref.watch(portfolioProvider);
    final holding = portfolio.holdings[widget.symbol];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
      ),
      child: quoteAsync.when(skipLoadingOnReload: true,
        data: (quote) {
          final estimatedCost = _quantity * quote.price;
          
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Buy/Sell Toggle
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  color: AppColors.panelBackground,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleButton('BUY', true),
                    _buildToggleButton('SELL', false),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              // Quantity Input
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyles.terminalBody.copyWith(color: AppColors.primaryText),
                  decoration: InputDecoration(
                    labelText: 'QTY',
                    labelStyle: TextStyles.terminalBodySmall.copyWith(color: AppColors.secondaryText),
                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryText)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _quantity = int.tryParse(val) ?? 0;
                    });
                  },
                ),
              ),
              
              const SizedBox(width: 16),
              // Cash & Pos Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cash: \$${portfolio.cashBalance.toStringAsFixed(2)}', style: TextStyles.terminalBodySmall.copyWith(color: AppColors.secondaryText)),
                    Text('Pos: ${holding ?? 0} sh', style: TextStyles.terminalBodySmall.copyWith(color: AppColors.secondaryText)),
                  ],
                ),
              ),
              
              // Submit button
              ElevatedButton(
                onPressed: _quantity > 0 ? () {
                  if (_isBuy) {
                    ref.read(portfolioProvider.notifier).buyStock(widget.symbol, _quantity, quote.price);
                  } else {
                    if ((holding ?? 0) >= _quantity) {
                      ref.read(portfolioProvider.notifier).sellStock(widget.symbol, _quantity, quote.price);
                    } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough shares to sell')));
                        return;
                    }
                  }
                  _qtyController.clear();
                  setState(() => _quantity = 0);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order executed for $_quantity shares.')));
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isBuy ? AppColors.positive : AppColors.negative,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: Text('SUBMIT: \$${estimatedCost.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator())),
        error: (e, s) => Center(child: Text('NO QUOTE', style: TextStyles.terminalBody.copyWith(color: AppColors.negative))),
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isBuyBtn) {
    final isSelected = _isBuy == isBuyBtn;
    return GestureDetector(
      onTap: () => setState(() => _isBuy = isBuyBtn),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isSelected ? (isBuyBtn ? AppColors.positive : AppColors.negative) : Colors.transparent,
        child: Text(
          label,
          style: TextStyles.terminalBodySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.background : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }
}
