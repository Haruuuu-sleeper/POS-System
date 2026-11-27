import 'package:material_ui/material_ui.dart';

import '../pos_store.dart';
import '../pos_theme.dart';
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
        final user = widget.store.currentUser;
        final isAdmin = user?.role == UserRole.admin;
        final wide = MediaQuery.of(context).size.width >= 960;

        final navItems = <({String label, IconData icon, Widget page})>[
          if (isAdmin)
            (
              label: 'Dashboard',
              icon: Icons.space_dashboard_rounded,
              page: DashboardScreen(store: widget.store),
            ),
          (
            label: 'POS Checkout',
            icon: Icons.point_of_sale_rounded,
            page: PosScreen(store: widget.store),
          ),
          if (isAdmin)
            (
              label: 'Products & Stock',
              icon: Icons.inventory_2_rounded,
              page: ProductsScreen(store: widget.store),
            ),
          (
            label: 'Orders History',
            icon: Icons.receipt_long_rounded,
            page: OrdersScreen(store: widget.store),
          ),
          if (isAdmin)
            (
              label: 'Users & Roles',
              icon: Icons.admin_panel_settings_rounded,
              page: UsersScreen(store: widget.store),
            ),
        ];

        final safeIndex = _selectedIndex >= navItems.length
            ? 0
            : _selectedIndex;
        final name = user?.fullName ?? 'Staff';
        final roleLabel = (user?.role.name ?? 'cashier').toUpperCase();

        return Scaffold(
          body: Row(
            children: [
              Container(
                width: wide ? 236 : 82,
                decoration: const BoxDecoration(
                  color: PosColors.obsidianSurface,
                  border: Border(
                    right: BorderSide(color: PosColors.borderSubtle),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(wide ? 16 : 12),
                      child: Container(
                        padding: EdgeInsets.all(wide ? 12 : 8),
                        decoration: BoxDecoration(
                          color: PosColors.elevatedCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: PosColors.borderSubtle),
                        ),
                        child: Row(
                          mainAxisAlignment: wide
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    PosColors.electricBlue,
                                    PosColors.cobaltGlow,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'P',
                                  style: PosTypography.display(
                                    context,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            if (wide) ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: PosTypography.body(
                                        context,
                                        size: 13,
                                        weight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: PosColors.deepNavyTint,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        roleLabel,
                                        style: PosTypography.mono(
                                          context,
                                          size: 10,
                                          color: PosColors.skyPulse,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: navItems.length,
                        itemBuilder: (context, index) {
                          final item = navItems[index];
                          final active = index == safeIndex;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Material(
                              color: active
                                  ? PosColors.deepNavyTint
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                hoverColor: PosColors.hoverSurface,
                                onTap: () =>
                                    setState(() => _selectedIndex = index),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: wide ? 14 : 10,
                                    vertical: 12,
                                  ),
                                  decoration: active
                                      ? BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: PosColors.electricBlue
                                                .withValues(alpha: 0.45),
                                          ),
                                        )
                                      : null,
                                  child: Row(
                                    mainAxisAlignment: wide
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        item.icon,
                                        size: 20,
                                        color: active
                                            ? PosColors.skyPulse
                                            : PosColors.textSecondary,
                                      ),
                                      if (wide) ...[
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            item.label,
                                            style: PosTypography.body(
                                              context,
                                              size: 13.5,
                                              weight: active
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              color: active
                                                  ? PosColors.textPrimary
                                                  : PosColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: widget.onLogout,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: PosColors.danger,
                            side: BorderSide(
                              color: PosColors.danger.withValues(alpha: 0.35),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: wide
                              ? const Text('Sign Out')
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: navItems[safeIndex].page),
            ],
          ),
        );
      },
    );
  }
}
