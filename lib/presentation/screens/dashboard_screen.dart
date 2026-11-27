import 'package:material_ui/material_ui.dart';

import '../pos_store.dart';
import '../pos_theme.dart';

class DashboardScreen extends StatelessWidget {
  final PosStore store;

  const DashboardScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Command Overview')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _KpiCard(
                  title: "Today's Revenue",
                  value: '\$${store.todayRevenue.toStringAsFixed(2)}',
                  icon: Icons.payments_rounded,
                  accent: PosColors.electricBlue,
                ),
                _KpiCard(
                  title: 'Completed Orders',
                  value: '${store.orders.length}',
                  icon: Icons.receipt_rounded,
                  accent: PosColors.skyPulse,
                ),
                _KpiCard(
                  title: 'Catalog Items',
                  value: '${store.products.length}',
                  icon: Icons.grid_view_rounded,
                  accent: const Color(0xFF6366F1),
                ),
                _KpiCard(
                  title: 'Low Stock Alerts',
                  value: '${store.lowStockProducts.length}',
                  icon: Icons.warning_amber_rounded,
                  accent: store.lowStockProducts.isEmpty
                      ? PosColors.success
                      : PosColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 22),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.bolt_rounded,
                                  color: PosColors.skyPulse,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Recent Transactions',
                                  style: PosTypography.display(
                                    context,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            Expanded(
                              child: store.orders.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No sales recorded yet. Complete an order in POS Checkout.',
                                        style: PosTypography.body(
                                          context,
                                          color: PosColors.textSecondary,
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: store.orders.length,
                                      separatorBuilder: (_, _) =>
                                          const Divider(height: 1),
                                      itemBuilder: (_, i) {
                                        final o = store.orders[i];
                                        return ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 4,
                                                vertical: 4,
                                              ),
                                          leading: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: PosColors.deepNavyTint,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.receipt_long_rounded,
                                              color: PosColors.skyPulse,
                                              size: 18,
                                            ),
                                          ),
                                          title: Text(
                                            o.invoiceNo,
                                            style: PosTypography.mono(
                                              context,
                                              size: 13.5,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '${o.cashierName} • ${o.items.length} items',
                                            style: PosTypography.body(
                                              context,
                                              size: 12.5,
                                              color: PosColors.textSecondary,
                                            ),
                                          ),
                                          trailing: Text(
                                            '\$${o.total.toStringAsFixed(2)}',
                                            style: PosTypography.mono(
                                              context,
                                              size: 14.5,
                                              color: PosColors.skyPulse,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.inventory_rounded,
                                  color: PosColors.warning,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Low Stock (<= 5)',
                                  style: PosTypography.display(
                                    context,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            Expanded(
                              child: store.lowStockProducts.isEmpty
                                  ? Center(
                                      child: Text(
                                        'All inventory levels look healthy.',
                                        style: PosTypography.body(
                                          context,
                                          color: PosColors.textSecondary,
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: store.lowStockProducts.length,
                                      separatorBuilder: (_, _) =>
                                          const Divider(height: 1),
                                      itemBuilder: (_, i) {
                                        final p = store.lowStockProducts[i];
                                        return ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 4,
                                                vertical: 2,
                                              ),
                                          title: Text(
                                            p.name,
                                            style: PosTypography.body(
                                              context,
                                              weight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Text(
                                            p.category,
                                            style: PosTypography.body(
                                              context,
                                              size: 12,
                                              color: PosColors.textSecondary,
                                            ),
                                          ),
                                          trailing: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: PosColors.warning
                                                  .withValues(alpha: 0.14),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: PosColors.warning
                                                    .withValues(alpha: 0.4),
                                              ),
                                            ),
                                            child: Text(
                                              '${p.stock} left',
                                              style: PosTypography.mono(
                                                context,
                                                size: 11.5,
                                                color: PosColors.warning,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accent.withValues(alpha: 0.35)),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: PosTypography.body(
                        context,
                        size: 12,
                        color: PosColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(value, style: PosTypography.mono(context, size: 20)),
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
