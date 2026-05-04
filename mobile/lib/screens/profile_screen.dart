import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/app_role.dart';
import '../providers/app_preferences_provider.dart';
import '../providers/auth_provider.dart';
import '../services/local_notification_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final notificationsOn = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const Center(child: Text('Not signed in'))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(user.displayName),
                  subtitle: Text(user.role.label),
                ),
                const Divider(),
                ListTile(
                  title: user.isStateCoordinator ? const Text('State') : const Text('Directorate'),
                  subtitle: Text(user.isStateCoordinator ? user.stateName ?? '' : user.directorateName ?? ''),
                ),
                if (user.phone != null)
                  ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: const Text('Phone'),
                    subtitle: Text(user.phone!),
                  ),
                if (user.email != null)
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Email'),
                    subtitle: Text(user.email!),
                  ),
                if (user.unitIds.isNotEmpty)
                  ListTile(
                    title: const Text('Assigned units'),
                    subtitle: Text(user.unitIds.join(', ')),
                  ),
                const Divider(),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  subtitle: const Text(
                    'Inbox alerts, devotion (7:30), lunch (12:00), and report reminder (3:00 PM). '
                    'All times are Mon–Fri in Lagos (WAT). One setting controls all.',
                  ),
                  value: notificationsOn,
                  onChanged: (v) => _onNotificationsChanged(context, ref, v),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).signOut();
                    if (context.mounted) context.go('/login');
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                ),
              ],
            ),
    );
  }

  Future<void> _onNotificationsChanged(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    if (enabled) {
      final ok = await LocalNotificationService.requestPermissions();
      if (!ok) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification permission is required for alerts and reminders.'),
            ),
          );
        }
        return;
      }
      await LocalNotificationService.scheduleOrgWeekdayReminders();
      await ref.read(notificationsEnabledProvider.notifier).setEnabled(true);
    } else {
      await LocalNotificationService.cancelOrgWeekdayReminders();
      await ref.read(notificationsEnabledProvider.notifier).setEnabled(false);
    }
  }
}
