import 'package:material_ui/material_ui.dart';
import '../pos_store.dart';
import '../pos_theme.dart';

class ProductsScreen extends StatefulWidget {
  final PosStore store;

  const ProductsScreen({super.key, required this.store});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _query = '';

  void _openProductForm({Product? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final catCtrl = TextEditingController(text: existing?.category ?? 'Drinks');
    final priceCtrl = TextEditingController(text: existing?.price.toString() ?? '');
    final stockCtrl = TextEditingController(text: existing?.stock.toString() ?? '10');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          existing == null ? 'Add Product' : 'Edit Product',
          style: PosTypography.display(ctx, size: 19),
        ),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: catCtrl,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Price (\$)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stock Quantity'),
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
          FilledButton(
            onPressed: () {
              final price = double.tryParse(priceCtrl.text) ?? 0;
              final stock = int.tryParse(stockCtrl.text) ?? 0;
              if (nameCtrl.text.trim().isEmpty || price <= 0) return;
              widget.store.saveProduct(
                id: existing?.id,
                name: nameCtrl.text.trim(),
                category: catCtrl.text.trim().isEmpty ? 'General' : catCtrl.text.trim(),
                price: price,
                stock: stock,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Save Product'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 700;
    final items = widget.store.products
        .where(
          (p) =>
      p.name.toLowerCase().contains(_query.toLowerCase()) ||
          p.category.toLowerCase().contains(_query.toLowerCase()),
    )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(isNarrow ? 'Add' : 'New Product'),
              onPressed: () => _openProductForm(),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(isNarrow ? 12 : 20),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Filter by name or category...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Card(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final p = items[i];
                    final isLow = p.stock <= 5;

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isNarrow ? 12 : 18,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: PosColors.deepNavyTint,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: PosColors.skyPulse,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: PosTypography.body(
                                    context,
                                    size: 14,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 2,
                                  children: [
                                    Text(
                                      p.category,
                                      style: PosTypography.body(
                                        context,
                                        size: 12,
                                        color: PosColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      'Stock: ${p.stock}',
                                      style: PosTypography.mono(
                                        context,
                                        size: 11.5,
                                        color: isLow
                                            ? PosColors.warning
                                            : PosColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\$${p.price.toStringAsFixed(2)}',
                            style: PosTypography.mono(
                              context,
                              size: 14,
                              color: PosColors.skyPulse,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit / Restock',
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.only(left: 6),
                            icon: const Icon(Icons.edit_outlined, size: 19),
                            color: PosColors.skyPulse,
                            onPressed: () => _openProductForm(existing: p),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.only(left: 4),
                            icon: const Icon(Icons.delete_outline, size: 19),
                            color: PosColors.danger,
                            onPressed: () => widget.store.deleteProduct(p.id),
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