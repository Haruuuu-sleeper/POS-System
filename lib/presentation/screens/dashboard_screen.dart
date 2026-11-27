import 'package:material_ui/material_ui.dart';
import '../pos_store.dart';
import '../pos_theme.dart';

class DashboardScreen extends StatelessWidget {
  final PosStore store;

  const DashboardScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 720;
        final horizontalPadding = isNarrow ? 12.0 : 20.0;
        final availableWidth = constraints.maxWidth - (horizontalPadding * 2);
        final cardWidth = isNarrow
            ? availableWidth
            : ((availableWidth - 16) / 2).clamp(200.0, 260.0);

        final recentTransactionsCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      color: PosColors.skyPulse,
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recent Transactions',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PosTypography.display(context, size: 15.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                if (store.orders.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No sales recorded yet. Complete an order in POS Checkout.',
                        textAlign: TextAlign.center,
                        style: PosTypography.body(
                          context,
                          size: 13,
                          color: PosColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: store.orders.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final o = store.orders[i];
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 2,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: PosColors.deepNavyTint,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: PosColors.skyPulse,
                            size: 16,
                          ),
                        ),
                        title: Text(
                          o.invoiceNo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: PosTypography.mono(context, size: 13),
                        ),
                        subtitle: Text(
                          '${o.cashierName} • ${o.items.length} items',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: PosTypography.body(
                            context,
                            size: 12,
                            color: PosColors.textSecondary,
                          ),
                        ),
                        trailing: Text(
                          '\$${o.total.toStringAsFixed(2)}',
                          style: PosTypography.mono(
                            context,
                            size: 13.5,
                            color: PosColors.skyPulse,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );

        final lowStockCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_rounded,
                      color: PosColors.warning,
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Low Stock (<= 5)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PosTypography.display(context, size: 15.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                if (store.lowStockProducts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'All inventory levels look healthy.',
                        textAlign: TextAlign.center,
                        style: PosTypography.body(
                          context,
                          size: 13,
                          color: PosColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: store.lowStockProducts.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final p = store.lowStockProducts[i];
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 2,
                        ),
                        title: Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: PosTypography.body(
                            context,
                            size: 13.5,
                            weight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          p.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: PosTypography.body(
                            context,
                            size: 12,
                            color: PosColors.textSecondary,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: PosColors.warning.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: PosColors.warning.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            '${p.stock} left',
                            style: PosTypography.mono(
                              context,
                              size: 11,
                              color: PosColors.warning,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );

        return Scaffold(
          appBar: AppBar(title: const Text('Command Overview')),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _KpiCard(
                      width: cardWidth,
                      title: "Today's Revenue",
                      value: '\$${store.todayRevenue.toStringAsFixed(2)}',
                      icon: Icons.payments_rounded,
                      accent: PosColors.electricBlue,
                    ),
                    _KpiCard(
                      width: cardWidth,
                      title: 'Completed Orders',
                      value: '${store.orders.length}',
                      icon: Icons.receipt_rounded,
                      accent: PosColors.skyPulse,
                    ),
                    _KpiCard(
                      width: cardWidth,
                      title: 'Catalog Items',
                      value: '${store.products.length}',
                      icon: Icons.grid_view_rounded,
                      accent: const Color(0xFF6366F1),
                    ),
                    _KpiCard(
                      width: cardWidth,
                      title: 'Low Stock Alerts',
                      value: '${store.lowStockProducts.length}',
                      icon: Icons.warning_amber_rounded,
                      accent: store.lowStockProducts.isEmpty
                          ? PosColors.success
                          : PosColors.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (isNarrow) ...[
                  recentTransactionsCard,
                  const SizedBox(height: 14),
                  lowStockCard,
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: recentTransactionsCard),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: lowStockCard),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  const _KpiCard({
    required this.width,
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: accent.withValues(alpha: 0.35)),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PosTypography.body(
                        context,
                        size: 12,
                        color: PosColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PosTypography.mono(context, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}