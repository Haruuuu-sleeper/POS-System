import 'package:flutter/material.dart';

import '../pos_store.dart';

class UsersScreen extends StatelessWidget {
  final PosStore store;

  const UsersScreen({super.key, required this.store});

  void _openAddUserDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final userCtrl = TextEditingController();
    UserRole selectedRole = UserRole.cashier;

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
                controller: userCtrl,
                decoration: const InputDecoration(labelText: 'Username'),
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
                    userCtrl.text.trim().isEmpty)
                  return;
                store.addUser(
                  nameCtrl.text.trim(),
                  userCtrl.text.trim(),
                  selectedRole,
                );
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
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final u = store.users[i];
          return ListTile(
            leading: CircleAvatar(child: Text(u.fullName[0].toUpperCase())),
            title: Text(
              u.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '@${u.username} • Role: ${u.role.name.toUpperCase()}',
            ),
            trailing: Switch(
              value: u.isActive,
              onChanged: u.username == 'admin'
                  ? null
                  : (_) => store.toggleUserStatus(u.id),
            ),
          );
        },
      ),
    );
  }
}
