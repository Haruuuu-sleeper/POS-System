import 'package:material_ui/material_ui.dart';

import '../pos_store.dart';
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
      appBar: AppBar(title: const Text('Orders & Receipt History')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search by invoice number or cashier...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: orders.isEmpty
                  ? const Center(child: Text('No orders found.'))
                  : ListView.separated(
                      itemCount: orders.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final o = orders[i];
                        return ListTile(
                          leading: const Icon(Icons.receipt_outlined),
                          title: Text(
                            o.invoiceNo,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${o.createdAt.toString().substring(0, 16)} • Cashier: ${o.cashierName}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\$${o.total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () => showReceiptDialog(context, o),
                                child: const Text('View Receipt'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
