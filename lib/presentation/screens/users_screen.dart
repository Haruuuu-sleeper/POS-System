import 'package:material_ui/material_ui.dart';

import '../pos_store.dart';
import '../pos_theme.dart';

class UsersScreen extends StatelessWidget {
  final PosStore store;

  const UsersScreen({super.key, required this.store});

  void _openAddUserDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController(text: 'password123');
    UserRole selectedRole = UserRole.cashier;
    String? formError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            'Create Staff Account',
            style: PosTypography.display(ctx, size: 19),
          ),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password (min 6 chars)',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  initialValue: selectedRole,
                  dropdownColor: PosColors.elevatedCard,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: UserRole.values
                      .map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Text(r.name.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedRole = v);
                  },
                ),
                if (formError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    formError!,
                    style: const TextStyle(
                      color: PosColors.danger,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: PosColors.textSecondary),
              ),
            ),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty ||
                    emailCtrl.text.trim().isEmpty ||
                    passwordCtrl.text.length < 6) {
                  setDialogState(
                    () => formError = 'Fill all fields (password >= 6 chars).',
                  );
                  return;
                }
                final err = store.createStaffUser(
                  fullName: nameCtrl.text,
                  email: emailCtrl.text,
                  password: passwordCtrl.text,
                  role: selectedRole,
                );
                if (err != null) {
                  setDialogState(() => formError = err);
                  return;
                }
                Navigator.pop(ctx);
              },
              child: const Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff & Role Access'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: FilledButton.icon(
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: const Text('Add Staff'),
              onPressed: () => _openAddUserDialog(context),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: store.users.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final u = store.users[i];
              final isAdminAccount = u.role == UserRole.admin;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isAdminAccount
                        ? PosColors.electricBlue.withValues(alpha: 0.18)
                        : PosColors.deepNavyTint,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAdminAccount
                          ? PosColors.electricBlue.withValues(alpha: 0.5)
                          : PosColors.borderSubtle,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : '?',
                      style: PosTypography.display(
                        context,
                        size: 16,
                        color: PosColors.skyPulse,
                      ),
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      u.fullName,
                      style: PosTypography.body(
                        context,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: PosColors.deepNavyTint,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        u.role.name.toUpperCase(),
                        style: PosTypography.mono(
                          context,
                          size: 10.5,
                          color: PosColors.skyPulse,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  u.email,
                  style: PosTypography.body(
                    context,
                    size: 12.5,
                    color: PosColors.textSecondary,
                  ),
                ),
                trailing: Switch(
                  value: u.isActive,
                  activeThumbColor: PosColors.skyPulse,
                  activeTrackColor: PosColors.deepNavyTint,
                  onChanged: u.email == 'admin@pos.local'
                      ? null
                      : (_) => store.toggleUserStatus(u.id),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
