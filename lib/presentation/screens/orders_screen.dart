import 'package:material_ui/material_ui.dart';

import '../pos_store.dart';
import '../pos_theme.dart';
import 'pos_screen.dart';

class OrdersScreen extends StatefulWidget {
  final PosStore store;

  const OrdersScreen({super.key, required this.store});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final orders = widget.store.orders
        .where(
          (o) =>
              o.invoiceNo.toLowerCase().contains(_search.toLowerCase()) ||
              o.cashierName.toLowerCase().contains(_search.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Orders & Receipts')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search invoice number or cashier...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: orders.isEmpty
                  ? Card(
                      child: Center(
                        child: Text(
                          'No completed orders yet.',
                          style: PosTypography.body(
                            context,
                            color: PosColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  : Card(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: orders.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final o = orders[i];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 6,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: PosColors.deepNavyTint,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.receipt_long_rounded,
                                color: PosColors.skyPulse,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              o.invoiceNo,
                              style: PosTypography.mono(context, size: 14),
                            ),
                            subtitle: Text(
                              '${o.createdAt.toString().substring(0, 16)} • ${o.cashierName}',
                              style: PosTypography.body(
                                context,
                                size: 12.5,
                                color: PosColors.textSecondary,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '\$${o.total.toStringAsFixed(2)}',
                                  style: PosTypography.mono(
                                    context,
                                    size: 15,
                                    color: PosColors.skyPulse,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton.icon(
                                  icon: const Icon(
                                    Icons.visibility_outlined,
                                    size: 15,
                                  ),
                                  label: const Text('Receipt'),
                                  onPressed: () =>
                                      showReceiptDialog(context, o),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
