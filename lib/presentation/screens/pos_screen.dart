import 'package:material_ui/material_ui.dart';
import '../pos_store.dart';
import '../pos_theme.dart';

class PosScreen extends StatefulWidget {
  final PosStore store;

  const PosScreen({super.key, required this.store});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  void _openCheckoutDialog() {
    final total = widget.store.cartTotal;
    final cashCtrl = TextEditingController(text: total.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final cash = double.tryParse(cashCtrl.text) ?? 0;
          final change = cash - total;

          return AlertDialog(
            title: Text('Complete Payment', style: PosTypography.display(ctx, size: 19)),
            content: SizedBox(
              width: 360,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: PosColors.deepNavyTint,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: PosColors.electricBlue.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL DUE',
                          style: PosTypography.mono(
                            ctx,
                            size: 11,
                            color: PosColors.skyPulse,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: PosTypography.mono(ctx, size: 24),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: cashCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: PosTypography.mono(ctx, size: 16),
                    decoration: const InputDecoration(
                      labelText: 'Cash Received (\$)',
                      prefixIcon: Icon(Icons.attach_money_rounded),
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    change >= 0
                        ? 'Change Due: \$${change.toStringAsFixed(2)}'
                        : 'Insufficient cash received',
                    style: PosTypography.mono(
                      ctx,
                      size: 14,
                      color: change >= 0 ? PosColors.success : PosColors.danger,
                    ),
                  ),
                ],
              ),
            ),
          ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: PosColors.textSecondary)),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Confirm & Receipt'),
                onPressed: change >= 0
                    ? () {
                  final order = widget.store.completeCheckout(cash);
                  Navigator.pop(ctx);
                  showReceiptDialog(context, order);
                }
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCatalogSection(BuildContext context, {required bool isNarrow}) {
    final filteredProducts = widget.store.products.where((p) {
      final matchesCat = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    return Padding(
      padding: EdgeInsets.all(isNarrow ? 12 : 18),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search menu or products...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: widget.store.categories.map((cat) {
                final selected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? PosColors.electricBlue
                            : PosColors.elevatedCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? PosColors.electricBlue
                              : PosColors.borderSubtle,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: PosTypography.body(
                          context,
                          size: 12.5,
                          weight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : PosColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: isNarrow ? 170 : 210,
                childAspectRatio: isNarrow ? 1.05 : 1.15,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (_, i) {
                final p = filteredProducts[i];
                final outOfStock = p.stock <= 0;

                return Material(
                  color: outOfStock
                      ? PosColors.obsidianSurface
                      : PosColors.elevatedCard,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    hoverColor: PosColors.hoverSurface,
                    onTap: outOfStock ? null : () => widget.store.addToCart(p),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: outOfStock
                              ? PosColors.borderSubtle.withValues(alpha: 0.4)
                              : PosColors.borderSubtle,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: PosColors.deepNavyTint,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    p.category,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: PosTypography.body(
                                      context,
                                      size: 10.5,
                                      weight: FontWeight.w600,
                                      color: PosColors.skyPulse,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                outOfStock ? 'OUT' : '${p.stock} left',
                                style: PosTypography.mono(
                                  context,
                                  size: 10.5,
                                  color: outOfStock
                                      ? PosColors.danger
                                      : p.stock <= 5
                                      ? PosColors.warning
                                      : PosColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            p.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: PosTypography.display(
                              context,
                              size: 14,
                              weight: FontWeight.w600,
                              color: outOfStock
                                  ? PosColors.textMuted
                                  : PosColors.textPrimary,
                            ),
                          ),
                          Text(
                            '\$${p.price.toStringAsFixed(2)}',
                            style: PosTypography.mono(
                              context,
                              size: 15,
                              color: outOfStock
                                  ? PosColors.textMuted
                                  : PosColors.skyPulse,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketSection(BuildContext context, {required bool isNarrow}) {
    return Container(
      width: isNarrow ? double.infinity : 370,
      height: isNarrow ? (widget.store.cart.isEmpty ? 140 : 200) : null,
      decoration: BoxDecoration(
        color: PosColors.obsidianSurface,
        border: isNarrow
            ? const Border(top: BorderSide(color: PosColors.borderSubtle))
            : const Border(left: BorderSide(color: PosColors.borderSubtle)),
      ),
      padding: EdgeInsets.all(isNarrow ? 12 : 18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.shopping_bag_rounded,
                    color: PosColors.skyPulse,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Active Ticket',
                    style: PosTypography.display(context, size: 16),
                  ),
                ],
              ),
              if (widget.store.cart.isNotEmpty)
                TextButton(
                  onPressed: widget.store.clearCart,
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: PosColors.danger),
                  ),
                ),
            ],
          ),
          const Divider(height: 10),
          Expanded(
            child: widget.store.cart.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.touch_app_rounded,
                    size: 28,
                    color: PosColors.textMuted,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap items to build an order',
                    textAlign: TextAlign.center,
                    style: PosTypography.body(
                      context,
                      size: 12.5,
                      color: PosColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
                : ListView.separated(
              itemCount: widget.store.cart.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final item = widget.store.cart[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: PosTypography.body(
                                context,
                                size: 13,
                                weight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '\$${item.subtotal.toStringAsFixed(2)}',
                              style: PosTypography.mono(
                                context,
                                size: 12,
                                color: PosColors.skyPulse,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.remove_circle_outline, size: 19),
                        color: PosColors.textSecondary,
                        onPressed: () =>
                            widget.store.updateCartQty(item.product.id, -1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '${item.quantity}',
                          style: PosTypography.mono(context, size: 13.5),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.add_circle_outline, size: 19),
                        color: PosColors.skyPulse,
                        onPressed: () =>
                            widget.store.updateCartQty(item.product.id, 1),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: PosColors.elevatedCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PosColors.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: PosTypography.display(context, size: 15),
                ),
                Text(
                  '\$${widget.store.cartTotal.toStringAsFixed(2)}',
                  style: PosTypography.mono(
                    context,
                    size: 18,
                    color: PosColors.skyPulse,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton.icon(
              icon: const Icon(Icons.bolt_rounded, size: 18),
              label: const Text('Charge Order'),
              onPressed: widget.store.cart.isEmpty ? null : _openCheckoutDialog,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          MediaQuery.of(context).size.width < 760
              ? 'POS Register'
              : 'Point of Sale Register',
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 760;
          if (isNarrow) {
            return Column(
              children: [
                Expanded(child: _buildCatalogSection(context, isNarrow: true)),
                _buildTicketSection(context, isNarrow: true),
              ],
            );
          }
          return Row(
            children: [
              Expanded(flex: 3, child: _buildCatalogSection(context, isNarrow: false)),
              _buildTicketSection(context, isNarrow: false),
            ],
          );
        },
      ),
    );
  }
}

void showReceiptDialog(BuildContext context, PosOrder order) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(order.invoiceNo, style: PosTypography.mono(ctx, size: 18)),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              'Cashier: ${order.cashierName}',
              style: PosTypography.body(ctx, size: 13, color: PosColors.textSecondary),
            ),
            Text(
              'Date: ${order.createdAt.toString().substring(0, 16)}',
              style: PosTypography.body(ctx, size: 13, color: PosColors.textSecondary),
            ),
            const SizedBox(height: 10),
            const Divider(),
            ...order.items.map(
                  (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.product.name} ×${item.quantity}', style: PosTypography.body(ctx)),
                    Text(
                      '\$${item.subtotal.toStringAsFixed(2)}',
                      style: PosTypography.mono(ctx, size: 13),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: PosTypography.display(ctx, size: 15)),
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: PosTypography.mono(ctx, size: 16, color: PosColors.skyPulse),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cash Paid', style: PosTypography.body(ctx, size: 13, color: PosColors.textSecondary)),
                Text('\$${order.cashReceived.toStringAsFixed(2)}', style: PosTypography.mono(ctx, size: 13)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Change Due', style: PosTypography.body(ctx, size: 13, color: PosColors.textSecondary)),
                Text(
                  '\$${order.changeDue.toStringAsFixed(2)}',
                  style: PosTypography.mono(ctx, size: 13, color: PosColors.success),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
      actions: [
        FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
      ],
    ),
  );
}