import 'package:material_ui/material_ui.dart';

import '../pos_store.dart';

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
          title: const Text('Create Staff Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password (min 6 chars)',
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<UserRole>(
                initialValue: selectedRole,
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
                const SizedBox(height: 8),
                Text(formError!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
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
              child: const Text('Create'),
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
        title: const Text('User & Role Management'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('Add Staff'),
              onPressed: () => _openAddUserDialog(context),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: store.users.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final u = store.users[i];
          return ListTile(
            leading: CircleAvatar(
              child: Text(
                u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : '?',
              ),
            ),
            title: Text(
              u.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${u.email} • Role: ${u.role.name.toUpperCase()}'),
            trailing: Switch(
              value: u.isActive,
              onChanged: u.email == 'admin@pos.local'
                  ? null
                  : (_) => store.toggleUserStatus(u.id),
            ),
          );
        },
      ),
    );
  }
}
