import 'package:flutter/material.dart';

import '../pos_store.dart';

class DashboardScreen extends StatelessWidget {
  final PosStore store;

  const DashboardScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard & Sales Summary')),
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
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
                _KpiCard(
                  title: 'Total Orders',
                  value: '${store.orders.length}',
                  icon: Icons.shopping_bag_outlined,
                  color: Colors.blue,
                ),
                _KpiCard(
                  title: 'Total Products',
                  value: '${store.products.length}',
                  icon: Icons.inventory_2_outlined,
                  color: Colors.indigo,
                ),
                _KpiCard(
                  title: 'Low Stock Alerts',
                  value: '${store.lowStockProducts.length}',
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recent Transactions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            Expanded(
                              child: store.orders.isEmpty
                                  ? const Center(
                                      child: Text('No sales recorded yet.'),
                                    )
                                  : ListView.builder(
                                      itemCount: store.orders.length,
                                      itemBuilder: (_, i) {
                                        final o = store.orders[i];
                                        return ListTile(
                                          title: Text(o.invoiceNo),
                                          subtitle: Text(
                                            'Cashier: ${o.cashierName} • ${o.items.length} items',
                                          ),
                                          trailing: Text(
                                            '\$${o.total.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
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
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Low Stock Items (<= 5)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            Expanded(
                              child: store.lowStockProducts.isEmpty
                                  ? const Center(
                                      child: Text('All stock levels healthy.'),
                                    )
                                  : ListView.builder(
                                      itemCount: store.lowStockProducts.length,
                                      itemBuilder: (_, i) {
                                        final p = store.lowStockProducts[i];
                                        return ListTile(
                                          title: Text(p.name),
                                          subtitle: Text(p.category),
                                          trailing: Chip(
                                            label: Text('${p.stock} left'),
                                            backgroundColor:
                                                Colors.orange.shade100,
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
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
