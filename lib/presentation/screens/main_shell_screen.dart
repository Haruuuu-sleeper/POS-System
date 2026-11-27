import 'package:flutter/material.dart';

import '../pos_store.dart';
import 'dashboard_screen.dart';
import 'pos_screen.dart';
import 'products_screen.dart';
import 'orders_screen.dart';
import 'users_screen.dart';

class MainShellScreen extends StatefulWidget {
  final PosStore store;
  final VoidCallback onLogout;

  const MainShellScreen({
    super.key,
    required this.store,
    required this.onLogout,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final isAdmin = widget.store.currentUser.role == UserRole.admin;

        final navItems = <({String label, IconData icon, Widget page})>[
          if (isAdmin)
            (
              label: 'Dashboard',
              icon: Icons.dashboard_outlined,
              page: DashboardScreen(store: widget.store),
            ),
          (
            label: 'POS Checkout',
            icon: Icons.point_of_sale_outlined,
            page: PosScreen(store: widget.store),
          ),
          if (isAdmin)
            (
              label: 'Products & Stock',
              icon: Icons.inventory_2_outlined,
              page: ProductsScreen(store: widget.store),
            ),
          (
            label: 'Orders History',
            icon: Icons.receipt_long_outlined,
            page: OrdersScreen(store: widget.store),
          ),
          if (isAdmin)
            (
              label: 'Users & Roles',
              icon: Icons.manage_accounts_outlined,
              page: UsersScreen(store: widget.store),
            ),
        ];

        final safeIndex = _selectedIndex >= navItems.length
            ? 0
            : _selectedIndex;

        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: MediaQuery.of(context).size.width >= 900,
                selectedIndex: safeIndex,
                onDestinationSelected: (i) =>
                    setState(() => _selectedIndex = i),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      const Icon(Icons.storefront, size: 32),
                      const SizedBox(height: 6),
                      Text(
                        widget.store.currentUser.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        widget.store.currentUser.role.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: IconButton(
                        tooltip: 'Logout',
                        icon: const Icon(Icons.logout, color: Colors.red),
                        onPressed: widget.onLogout,
                      ),
                    ),
                  ),
                ),
                destinations: navItems
                    .map(
                      (item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        label: Text(item.label),
                      ),
                    )
                    .toList(),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: navItems[safeIndex].page),
            ],
          ),
        );
      },
    );
  }
}
