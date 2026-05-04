import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_runtime.dart';
import '../providers/app_preferences_provider.dart';
import '../providers/auth_provider.dart';
import '../services/local_notification_service.dart';
import '../services/supabase_auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/session_user_hero_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _uploading = false;

  static void _showNotificationLearnMore(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final bottom = MediaQuery.paddingOf(ctx).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottom),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Reminders & alerts',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  'When enabled, one setting turns on all IMS reminders on this device:',
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 16),
                _bottomBullet(ctx, 'Inbox alerts for items that need your attention'),
                _bottomBullet(ctx, 'Devotion reminder at 7:30'),
                _bottomBullet(ctx, 'Lunch reminder at 12:00'),
                _bottomBullet(ctx, 'Report reminder at 3:00 PM'),
                const SizedBox(height: 16),
                Text(
                  'Schedule: Monday–Friday only. All times are West Africa Time (WAT / Lagos).',
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your device may still require notification permission. If permission is denied, '
                  'alerts cannot be delivered until you enable notifications for this app in system settings.',
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _bottomBullet(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: AppTheme.brandRed,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45)),
          ),
        ],
      ),
    );
  }

  bool get _canSyncAvatarPhoto =>
      supabaseApplicationReady && Supabase.instance.client.auth.currentUser != null;

  Future<void> _onChangePhoto() async {
    if (!_canSyncAvatarPhoto) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in with your EBOMIM account to add a profile photo.'),
        ),
      );
      return;
    }
    if (_uploading) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 92,
    );
    if (picked == null || !mounted) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 88,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop photo',
          toolbarColor: AppTheme.brandRed,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop photo',
          aspectRatioLockEnabled: true,
        ),
      ],
    );
    if (cropped == null || !mounted) return;

    setState(() => _uploading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final updated = await SupabaseAuthService.uploadAvatarJpeg(cropped.path);
      if (!mounted) return;
      if (updated != null) {
        await ref.read(authProvider.notifier).signIn(updated);
        messenger.showSnackBar(
          const SnackBar(content: Text('Profile photo updated')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(_friendlyError(e))),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _onRemovePhoto() async {
    if (!_canSyncAvatarPhoto) return;
    if (_uploading) return;
    final user = ref.read(authProvider);
    if (user == null) return;
    final url = user.avatarUrl?.trim();
    if (url == null || url.isEmpty) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove profile photo?'),
        content: const Text('Your initials will show until you add a new photo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _uploading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final updated = await SupabaseAuthService.clearAvatar();
      if (!mounted) return;
      if (updated != null) {
        await ref.read(authProvider.notifier).signIn(updated);
        messenger.showSnackBar(
          const SnackBar(content: Text('Profile photo removed')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(_friendlyError(e))),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  String _friendlyError(Object e) {
    if (e is AuthException) return e.message;
    return 'Could not update photo. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final notificationsOn = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const Center(child: Text('Not signed in'))
          : Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    SessionUserHeroCard(
                      user: user,
                      showAvatar: true,
                      onAvatarTap: _uploading ? null : _onChangePhoto,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          TextButton(
                            onPressed: _uploading ? null : _onChangePhoto,
                            child: const Text('Change photo'),
                          ),
                          if (user.avatarUrl != null && user.avatarUrl!.trim().isNotEmpty)
                            TextButton(
                              onPressed: _uploading ? null : _onRemovePhoto,
                              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                              child: const Text('Remove photo'),
                            ),
                        ],
                      ),
                    ),
                    if (!_canSyncAvatarPhoto)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Profile photos are available when you sign in with your connected EBOMIM account.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    _sectionHeader(context, 'Account'),
                    Text(
                      'Most details are managed by your organization.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.business_outlined, color: AppTheme.brandRed.withValues(alpha: 0.9)),
                            title: Text(user.isStateCoordinator ? 'State' : 'Directorate'),
                            subtitle: Text(
                              user.isStateCoordinator
                                  ? (user.stateName ?? '—')
                                  : (user.directorateName ?? '—'),
                            ),
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
                              leading: const Icon(Icons.groups_outlined),
                              title: const Text('Assigned units'),
                              subtitle: Text(user.unitIds.join(', ')),
                            ),
                        ],
                      ),
                    ),
                    _sectionHeader(context, 'Preferences'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.notifications_outlined, color: AppTheme.brandRed.withValues(alpha: 0.9)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Notifications',
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Text(
                                          'Weekday reminders and inbox alerts on this device.',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                height: 1.35,
                                              ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: TextButton(
                                            onPressed: () => _showNotificationLearnMore(context),
                                            child: const Text('Learn more'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: notificationsOn,
                                    onChanged: (v) => _onNotificationsChanged(context, ref, v),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _sectionHeader(context, 'Support'),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: const Text('Using the app'),
                        subtitle: const Text(
                          'Workflow tips and where to use the web portal for analytics.',
                        ),
                        onTap: () => _showSupportDialog(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final router = GoRouter.of(context);
                        await ref.read(authProvider.notifier).signOut();
                        if (!mounted) return;
                        router.go('/login');
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign out'),
                    ),
                  ],
                ),
                if (_uploading)
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: LinearProgressIndicator(minHeight: 3),
                  ),
              ],
            ),
    );
  }

  static Widget _sectionHeader(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
      ),
    );
  }

  static void _showSupportDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Using the app'),
        content: const SingleChildScrollView(
          child: Text(
            'Use Inbox, Submit, and History from the bottom bar for day-to-day reporting workflow.\n\n'
            'Analytics and executive dashboards are available on the IMS web portal.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
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
      final messenger = ScaffoldMessenger.of(context);
      final ok = await LocalNotificationService.requestPermissions();
      if (!ok) {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Notification permission is required for alerts and reminders.'),
          ),
        );
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
