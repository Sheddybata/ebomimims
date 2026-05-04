import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/directorates.dart';
import '../data/seed_units.dart';
import '../data/reference_states.dart';
import '../models/app_role.dart';
import '../models/directorate.dart';
import '../models/session_user.dart';
import '../persistence/member_onboarding_storage.dart';
import '../providers/auth_provider.dart';
import '../services/access_code_service.dart';
import '../services/supabase_auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/onboarding_validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  /// 0 = sign in / create account. 1 = local role selection until Supabase profiles are connected.
  int _step = 0;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _codeController = TextEditingController();
  bool _step0Busy = false;
  bool _creatingAccount = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  AppRole _role = AppRole.unitHead;
  String _directorateId = kDirectorates.first.id;
  String? _unitId;
  String _stateName = kNigerianStates.first;

  @override
  void initState() {
    super.initState();
    _syncUnit();
    _prefillKnownEmail();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _prefillKnownEmail() async {
    final p = await MemberOnboardingStorage.load();
    if (!mounted || p == null) return;
    _emailController.text = p.email;
  }

  void _syncUnit() {
    final units = unitsForDirectorate(_directorateId);
    _unitId = units.isEmpty ? null : units.first.id;
  }

  Directorate? get _directorate => directorateById(_directorateId);

  String _roleDisplay(AppRole r) => r.label;

  String _directorateDisplay(String id) => directorateById(id)?.name ?? id;

  String _unitDisplay(String? id) {
    if (id == null) return 'Select unit';
    final u = unitsForDirectorate(
      _directorateId,
    ).where((e) => e.id == id).firstOrNull;
    return u?.name ?? id;
  }

  Future<void> _pickRole() async {
    final picked = await _showOptionSheet<AppRole>(
      title: 'Your role',
      subtitle: 'Who are you signing in as?',
      icon: Icons.badge_outlined,
      children: AppRole.values
          .map(
            (r) => _SheetTile<AppRole>(
              value: r,
              label: r.label,
              description: _roleHint(r),
              selected: _role == r,
            ),
          )
          .toList(),
    );
    if (picked != null && mounted) setState(() => _role = picked);
  }

  String _roleHint(AppRole r) => switch (r) {
    AppRole.unitHead => 'Submit reports from your unit',
    AppRole.manager => 'Review units and forward to director',
    AppRole.director => 'Review and send to Administration',
    AppRole.stateCoordinator => 'Submit state-wide reports directly to Administration',
  };

  Future<void> _pickDirectorate() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DirectorateSheet(
        directorates: kDirectorates,
        selectedId: _directorateId,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _directorateId = picked;
        _syncUnit();
      });
    }
  }

  Future<void> _pickState() async {
    final picked = await _showOptionSheet<String>(
      title: 'Your State',
      subtitle: 'Select your state or FCT',
      icon: Icons.map_outlined,
      children: kNigerianStates
          .map(
            (s) => _SheetTile<String>(
              value: s,
              label: s,
              selected: _stateName == s,
            ),
          )
          .toList(),
    );
    if (picked != null && mounted) setState(() => _stateName = picked);
  }

  Future<void> _pickUnit() async {
    final units = unitsForDirectorate(_directorateId);
    if (units.isEmpty) return;
    final picked = await _showOptionSheet<String>(
      title: 'Your unit',
      subtitle: _directorate?.name ?? 'Directorate',
      icon: Icons.groups_outlined,
      children: units
          .map(
            (u) => _SheetTile<String>(
              value: u.id,
              label: u.name,
              selected: _unitId == u.id,
            ),
          )
          .toList(),
    );
    if (picked != null && mounted) setState(() => _unitId = picked);
  }

  Future<T?> _showOptionSheet<T>({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<_SheetTile<T>> children,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottom = MediaQuery.paddingOf(ctx).bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.72,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 24,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SheetGrabber(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.brandRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: AppTheme.brandRed, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(ctx).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1C1917),
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: Theme.of(ctx).textTheme.bodySmall
                                  ?.copyWith(
                                    color: const Color(0xFF78716C),
                                    height: 1.35,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                    children: children
                        .map(
                          (t) => ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            selected: t.selected,
                            selectedTileColor: AppTheme.brandRed.withValues(
                              alpha: 0.08,
                            ),
                            leading: t.selected
                                ? Icon(
                                    Icons.check_circle,
                                    color: AppTheme.brandRed,
                                  )
                                : Icon(
                                    Icons.circle_outlined,
                                    color: Colors.grey.shade400,
                                  ),
                            title: Text(
                              t.label,
                              style: TextStyle(
                                fontWeight: t.selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: const Color(0xFF1C1917),
                              ),
                            ),
                            subtitle: t.description != null
                                ? Text(
                                    t.description!,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  )
                                : null,
                            onTap: () => Navigator.pop(ctx, t.value),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editMyDetails() async {
    final p = await MemberOnboardingStorage.load();
    if (!mounted) return;
    setState(() {
      _step = 0;
      _creatingAccount = true;
      if (p != null) {
        _nameController.text = p.displayName;
        _phoneController.text = p.phone;
        _emailController.text = p.email;
      }
    });
  }

  Future<void> _onboardingNext() async {
    final emailErr = OnboardingValidators.emailError(_emailController.text);
    final password = _passwordController.text;
    if (emailErr != null || password.length < 6) {
      final msg = emailErr ?? 'Enter a password with at least 6 characters.';
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
      return;
    }

    if (!_creatingAccount) {
      setState(() => _step0Busy = true);
      try {
        final result = await SupabaseAuthService.signIn(
          email: _emailController.text,
          password: password,
        );
        if (!mounted) return;
        if (result.status == MobileAuthStatus.signedIn && result.user != null) {
          await ref.read(authProvider.notifier).signIn(result.user!);
          if (mounted) context.go('/home');
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result.message)));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_friendlyAuthError(e))));
        }
      } finally {
        if (mounted) setState(() => _step0Busy = false);
      }
      return;
    }

    final nameErr = OnboardingValidators.nameError(_nameController.text);
    final phoneErr = OnboardingValidators.phoneError(_phoneController.text);
    if (nameErr != null || phoneErr != null) {
      final msg = nameErr ?? phoneErr!;
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
      return;
    }
    if (_confirmPasswordController.text != password) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }

    setState(() => _step0Busy = true);
    final result = await AccessCodeService.validate(_codeController.text);
    if (!mounted) return;
    if (result.ok) {
      await MemberOnboardingStorage.save(
        MemberOnboardingProfile(
          displayName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
        ),
      );
      setState(() {
        _step = 1;
        _step0Busy = false;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message ?? 'Invalid code')));
      setState(() => _step0Busy = false);
    }
  }

  String _friendlyAuthError(Object error) {
    final message = error.toString();
    if (message.contains('Invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (message.contains('User already registered')) {
      return 'This email already has an account. Use Sign in instead.';
    }
    if (message.contains('Email not confirmed')) {
      return 'Please confirm your email before signing in.';
    }
    return 'Authentication failed. Please try again.';
  }

  InputDecoration _detailFieldDecoration(
    String label,
    String hint, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint.isEmpty ? null : hint,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFFAFAF9),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.brandRed, width: 2),
      ),
    );
  }

  Future<void> _signIn() async {
    final d = directorateById(_directorateId);
    final units = unitsForDirectorate(_directorateId);
    final isStateCoordinator = _role == AppRole.stateCoordinator;

    if (!isStateCoordinator) {
      if (d == null) return;
      if (_role == AppRole.unitHead && units.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This directorate has no units. Sign in as Manager or Director, or choose another directorate.',
            ),
          ),
        );
        return;
      }
    }

    final unitIds = units.map((u) => u.id).toList();

    final profile = await MemberOnboardingStorage.load();
    final onboardName = profile?.displayName.trim() ?? '';
    String? cleanContact(String? s) {
      final t = s?.trim();
      if (t == null || t.isEmpty) return null;
      return t;
    }

    final phone = cleanContact(profile?.phone);
    final email = cleanContact(profile?.email);

    String displayNameFor(AppRole r) {
      if (onboardName.isNotEmpty) return onboardName;
      if (r == AppRole.stateCoordinator) {
        return 'State Coordinator ($_stateName)';
      }
      final short = d?.name.split(',').first ?? '';
      return switch (r) {
        AppRole.unitHead => 'Unit head ($short)',
        AppRole.manager => 'Manager ($short)',
        AppRole.director => 'Director ($short)',
        _ => 'User',
      };
    }

    if (_creatingAccount) {
      setState(() => _step0Busy = true);
      try {
        final result = await SupabaseAuthService.signUpWithProfile(
          fullName: displayNameFor(_role),
          phone: phone ?? '',
          email: email ?? _emailController.text,
          password: _passwordController.text,
          role: _role,
          directorateCode: isStateCoordinator ? null : d?.id,
          unitCode: _role == AppRole.unitHead
              ? (_unitId ?? (units.isNotEmpty ? units.first.id : null))
              : null,
          stateName: isStateCoordinator ? _stateName : null,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.message)));
        if (result.status == MobileAuthStatus.signedIn && result.user != null) {
          await ref.read(authProvider.notifier).signIn(result.user!);
          if (mounted) context.go('/home');
        } else {
          setState(() {
            _step = 0;
            _creatingAccount = false;
            _confirmPasswordController.clear();
            _codeController.clear();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_friendlyAuthError(e))));
        }
      } finally {
        if (mounted) setState(() => _step0Busy = false);
      }
      return;
    }

    late SessionUser user;
    switch (_role) {
      case AppRole.unitHead:
        user = SessionUser(
          id: 'uh_${_directorateId}_1',
          displayName: displayNameFor(AppRole.unitHead),
          role: AppRole.unitHead,
          directorateId: d!.id,
          directorateName: d.name,
          unitIds: _unitId != null ? [_unitId!] : unitIds.take(1).toList(),
          primaryUnitId: _unitId ?? (units.isNotEmpty ? units.first.id : null),
          phone: phone,
          email: email,
        );
      case AppRole.manager:
        user = SessionUser(
          id: 'mgr_${_directorateId}_1',
          displayName: displayNameFor(AppRole.manager),
          role: AppRole.manager,
          directorateId: d!.id,
          directorateName: d.name,
          unitIds: unitIds,
          phone: phone,
          email: email,
        );
      case AppRole.director:
        user = SessionUser(
          id: 'dir_${_directorateId}_1',
          displayName: displayNameFor(AppRole.director),
          role: AppRole.director,
          directorateId: d!.id,
          directorateName: d.name,
          phone: phone,
          email: email,
        );
      case AppRole.stateCoordinator:
        user = SessionUser(
          id: 'sc_${_stateName}_1',
          displayName: displayNameFor(AppRole.stateCoordinator),
          role: AppRole.stateCoordinator,
          stateName: _stateName,
          phone: phone,
          email: email,
        );
    }

    await ref.read(authProvider.notifier).signIn(user);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final units = unitsForDirectorate(_directorateId);
    final isStateCoordinator = _role == AppRole.stateCoordinator;
    final showUnit = _role == AppRole.unitHead && !isStateCoordinator;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppTheme.brandRedLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _LoginHeader()),
          if (_step == 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 28 + bottomInset),
                child: Material(
                  color: Colors.white,
                  elevation: 3,
                  shadowColor: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: 0.5,
                            minHeight: 4,
                            backgroundColor: Colors.grey.shade200,
                            color: AppTheme.brandRed,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Step 1 of 2 · Your details',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: const Color(0xFF78716C),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          _creatingAccount ? 'Create account' : 'Sign in',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: const Color(0xFF1C1917),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _creatingAccount
                              ? 'Use your normal email, name, phone, and password. The access code unlocks role setup.'
                              : 'Use the email and password for your IMS account.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: const Color(0xFF57534E),
                                height: 1.45,
                              ),
                        ),
                        const SizedBox(height: 20),
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment<bool>(
                              value: false,
                              label: Text('Sign in'),
                              icon: Icon(Icons.login),
                            ),
                            ButtonSegment<bool>(
                              value: true,
                              label: Text('Create'),
                              icon: Icon(Icons.person_add_alt_1),
                            ),
                          ],
                          selected: {_creatingAccount},
                          onSelectionChanged: (values) {
                            setState(() => _creatingAccount = values.first);
                          },
                        ),
                        const SizedBox(height: 18),
                        if (_creatingAccount) ...[
                          TextField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: _detailFieldDecoration(
                              'Full name',
                              'e.g. Sarah Musa',
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[\d+\s\-()]'),
                              ),
                            ],
                            decoration: _detailFieldDecoration(
                              'Phone number',
                              'e.g. 0803...',
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          decoration: _detailFieldDecoration(
                            'Email',
                            'name@example.com',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          autocorrect: false,
                          decoration: _detailFieldDecoration(
                            'Password',
                            'Enter your password',
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _onboardingNext(),
                        ),
                        if (_creatingAccount) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            autocorrect: false,
                            decoration: _detailFieldDecoration(
                              'Confirm password',
                              'Re-enter your password',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(
                                    () => _obscureConfirmPassword =
                                        !_obscureConfirmPassword,
                                  );
                                },
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            onSubmitted: (_) => _onboardingNext(),
                          ),
                          const SizedBox(height: 20),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          Text(
                            'Team access code',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _codeController,
                            textCapitalization: TextCapitalization.characters,
                            autocorrect: false,
                            decoration: _detailFieldDecoration(
                              'Access code',
                              '',
                            ),
                            onSubmitted: (_) => _onboardingNext(),
                          ),
                        ],
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _step0Busy ? null : _onboardingNext,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: AppTheme.brandRed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _step0Busy
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Material(
                  color: Colors.white,
                  elevation: 3,
                  shadowColor: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: const LinearProgressIndicator(
                            value: 1,
                            minHeight: 4,
                            backgroundColor: Color(0xFFE7E5E4),
                            color: AppTheme.brandRed,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Step 2 of 2 · Role setup',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: const Color(0xFF78716C),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Complete registration',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: const Color(0xFF1C1917),
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Your access code was accepted. Choose your assigned role to finish registration.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: const Color(0xFF78716C),
                                fontSize: 14,
                                height: 1.45,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton.icon(
                            onPressed: _editMyDetails,
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Edit my details'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _SelectionRow(
                          label: 'Role',
                          value: _roleDisplay(_role),
                          icon: Icons.badge_outlined,
                          onTap: _pickRole,
                        ),
                        const SizedBox(height: 14),
                        if (isStateCoordinator)
                          _SelectionRow(
                            label: 'State',
                            value: _stateName,
                            icon: Icons.map_outlined,
                            onTap: _pickState,
                            multiline: true,
                          )
                        else ...[
                          _SelectionRow(
                            label: 'Directorate',
                            value: _directorateDisplay(_directorateId),
                            icon: Icons.account_tree_outlined,
                            onTap: _pickDirectorate,
                            multiline: true,
                          ),
                          if (showUnit) ...[
                            const SizedBox(height: 14),
                            _SelectionRow(
                              label: 'Unit',
                              value: _unitDisplay(_unitId),
                              icon: Icons.groups_outlined,
                              onTap: _pickUnit,
                              enabled: units.isNotEmpty,
                            ),
                          ],
                        ],
                        const SizedBox(height: 26),
                        FilledButton(
                          onPressed: _step0Busy ? null : _signIn,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _step0Busy
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 32 + bottomInset),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFE4E6)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: AppTheme.brandRedDark,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Flow: Unit head → Manager → Director → Administration → Executive (web).',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: const Color(0xFF57534E),
                                height: 1.45,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, top + 20, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.brandRed, AppTheme.brandRedDark],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _EbomimLogo(),
          const SizedBox(height: 18),
          Text(
            'EBOMIM IMS',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Unified Ministry Operations and Integrated Governance Portal',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

/// App bar / login header logo
class _EbomimLogo extends StatelessWidget {
  static const String assetPath = 'assets/images/ebomilogo.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            return ColoredBox(
              color: Colors.grey.shade200,
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 40,
                color: Colors.grey.shade600,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SelectionRow extends StatelessWidget {
  const _SelectionRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.multiline = false,
    this.enabled = true,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final bool multiline;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: const Color(0xFF78716C),
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: enabled ? const Color(0xFFFAFAF9) : const Color(0xFFF5F5F4),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                crossAxisAlignment: multiline
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: enabled ? AppTheme.brandRed : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: multiline ? 14.5 : 16,
                        height: multiline ? 1.35 : 1.2,
                        fontWeight: FontWeight.w600,
                        color: enabled ? const Color(0xFF1C1917) : Colors.grey,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: enabled ? AppTheme.brandRed : Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetGrabber extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _SheetTile<T> {
  const _SheetTile({
    required this.value,
    required this.label,
    this.description,
    this.selected = false,
  });

  final T value;
  final String label;
  final String? description;
  final bool selected;
}

class _DirectorateSheet extends StatelessWidget {
  const _DirectorateSheet({
    required this.directorates,
    required this.selectedId,
  });

  final List<Directorate> directorates;
  final String selectedId;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.38,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              _SheetGrabber(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.brandRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_tree_outlined,
                        color: AppTheme.brandRed,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Directorate',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1C1917),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Scroll to find your directorate',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: const Color(0xFF78716C)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 16 + bottom),
                  itemCount: directorates.length,
                  itemBuilder: (context, i) {
                    final d = directorates[i];
                    final sel = d.id == selectedId;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      selected: sel,
                      selectedTileColor: AppTheme.brandRed.withValues(
                        alpha: 0.08,
                      ),
                      leading: Icon(
                        sel ? Icons.check_circle : Icons.circle_outlined,
                        color: sel ? AppTheme.brandRed : Colors.grey.shade400,
                      ),
                      title: Text(
                        d.name,
                        style: TextStyle(
                          fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                          color: const Color(0xFF1C1917),
                          height: 1.35,
                        ),
                      ),
                      subtitle: Text(
                        d.groupLabel,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () => Navigator.pop(context, d.id),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final i = iterator;
    if (!i.moveNext()) return null;
    return i.current;
  }
}
