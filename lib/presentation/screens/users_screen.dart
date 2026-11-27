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
          title: Text('Create Staff Account', style: PosTypography.display(ctx, size: 19)),
          content: SizedBox(
            width: 360,
            child: SingleChildScrollView(
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
                    decoration: const InputDecoration(labelText: 'Password (min 6 chars)'),
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
                      style: const TextStyle(color: PosColors.danger, fontSize: 12.5),
                    ),
                  ],
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
                if (nameCtrl.text.trim().isEmpty ||
                    emailCtrl.text.trim().isEmpty ||
                    passwordCtrl.text.length < 6) {
                  setDialogState(() => formError = 'Fill all fields (password >= 6 chars).');
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
    final isNarrow = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNarrow ? 'Staff & Roles' : 'Staff & Role Access'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: isNarrow ? 10 : 18),
            child: FilledButton.icon(
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: Text(isNarrow ? 'Add' : 'Add Staff'),
              onPressed: () => _openAddUserDialog(context),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(isNarrow ? 12 : 20),
        child: Card(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: store.users.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final u = store.users[i];
              final isAdminAccount = u.role == UserRole.admin;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isNarrow ? 12 : 18,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      width: isNarrow ? 36 : 42,
                      height: isNarrow ? 36 : 42,
                      decoration: BoxDecoration(
                        color: isAdminAccount
                            ? PosColors.electricBlue.withValues(alpha: 0.18)
                            : PosColors.deepNavyTint,
                        borderRadius: BorderRadius.circular(11),
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
                            size: isNarrow ? 14 : 16,
                            color: PosColors.skyPulse,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                u.fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: PosTypography.body(
                                  context,
                                  size: isNarrow ? 13.5 : 14.5,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
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
                                    size: 10,
                                    color: PosColors.skyPulse,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            u.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: PosTypography.body(
                              context,
                              size: 12,
                              color: PosColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Transform.scale(
                      scale: isNarrow ? 0.85 : 1.0,
                      child: Switch(
                        value: u.isActive,
                        activeThumbColor: PosColors.skyPulse,
                        activeTrackColor: PosColors.deepNavyTint,
                        onChanged: u.email == 'admin@pos.local'
                            ? null
                            : (_) => store.toggleUserStatus(u.id),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}