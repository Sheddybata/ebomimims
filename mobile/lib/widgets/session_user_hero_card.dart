import 'package:flutter/material.dart';



import '../models/app_role.dart';

import '../models/session_user.dart';

import '../theme/app_theme.dart';



/// Identity block: optional photo / initials, name, role chip, org line.

/// When [user] is null, shows a loading skeleton.

class SessionUserHeroCard extends StatelessWidget {

  const SessionUserHeroCard({

    super.key,

    required this.user,

    this.footer,

    this.showAvatar = true,

    this.onAvatarTap,

  });



  final SessionUser? user;

  final Widget? footer;



  /// When false (e.g. Home), only name, role chip, and org — no photo column.

  final bool showAvatar;



  /// When set with [showAvatar], avatar is tappable (e.g. Profile → change photo).

  final VoidCallback? onAvatarTap;



  static String initialsFor(String displayName) {

    final parts = displayName.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty) return '?';

    if (parts.length == 1) {

      final p = parts[0];

      return p.isNotEmpty ? p[0].toUpperCase() : '?';

    }

    final a = parts[0].isNotEmpty ? parts[0][0] : '';

    final b = parts[parts.length - 1].isNotEmpty ? parts[parts.length - 1][0] : '';

    if (a.isEmpty && b.isEmpty) return '?';

    return '$a$b'.toUpperCase();

  }



  static String orgLine(SessionUser user) {

    if (user.isStateCoordinator) {

      return user.stateName ?? 'State assignment';

    }

    return user.directorateName ?? 'Directorate assignment';

  }



  @override

  Widget build(BuildContext context) {

    final scheme = Theme.of(context).colorScheme;



    final u = user;

    if (u == null) {

      return Card(

        clipBehavior: Clip.antiAlias,

        shape: RoundedRectangleBorder(

          borderRadius: BorderRadius.circular(16),

          side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),

        ),

        child: Padding(

          padding: const EdgeInsets.all(16),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              if (showAvatar)

                Row(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    _skeletonCircle(scheme),

                    const SizedBox(width: 16),

                    Expanded(child: _skeletonTextColumn(context)),

                  ],

                )

              else

                _skeletonTextColumn(context),

              const SizedBox(height: 16),

              ClipRRect(

                borderRadius: BorderRadius.circular(4),

                child: const LinearProgressIndicator(minHeight: 3),

              ),

            ],

          ),

        ),

      );

    }



    final initials = initialsFor(u.displayName);

    final org = orgLine(u);

    final identityColumn = Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          u.displayName,

          style: Theme.of(context).textTheme.titleLarge?.copyWith(

                fontWeight: FontWeight.w600,

              ),

        ),

        const SizedBox(height: 8),

        Align(

          alignment: Alignment.centerLeft,

          child: Chip(

            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

            visualDensity: VisualDensity.compact,

            padding: const EdgeInsets.symmetric(horizontal: 2),

            labelPadding: const EdgeInsets.symmetric(horizontal: 8),

            side: BorderSide.none,

            backgroundColor: AppTheme.brandRed.withValues(alpha: 0.12),

            label: Text(

              u.role.label,

              style: Theme.of(context).textTheme.labelLarge?.copyWith(

                    color: AppTheme.brandRedDark,

                    fontWeight: FontWeight.w600,

                  ),

            ),

          ),

        ),

        const SizedBox(height: 4),

        Text(

          org,

          style: Theme.of(context).textTheme.bodyMedium?.copyWith(

                color: scheme.onSurfaceVariant,

              ),

        ),

      ],

    );



    return Card(

      clipBehavior: Clip.antiAlias,

      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(16),

        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),

      ),

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            if (showAvatar)

              Row(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  _identityAvatar(

                    context,

                    initials: initials,

                    photoUrl: u.avatarUrl,

                    onTap: onAvatarTap,

                  ),

                  const SizedBox(width: 16),

                  Expanded(child: identityColumn),

                ],

              )

            else

              identityColumn,

            if (footer != null) ...[

              const SizedBox(height: 16),

              footer!,

            ],

          ],

        ),

      ),

    );

  }



  Widget _identityAvatar(

    BuildContext context, {

    required String initials,

    required String? photoUrl,

    VoidCallback? onTap,

  }) {

    final url = photoUrl?.trim();

    Widget avatar;

    if (url != null && url.isNotEmpty) {

      avatar = ClipOval(

        child: Image.network(

          url,

          width: 64,

          height: 64,

          fit: BoxFit.cover,

          errorBuilder: (context, error, stackTrace) {

            return CircleAvatar(

              radius: 32,

              backgroundColor: AppTheme.brandRed.withValues(alpha: 0.15),

              child: Text(

                initials,

                style: TextStyle(

                  fontSize: 22,

                  fontWeight: FontWeight.w700,

                  color: AppTheme.brandRedDark,

                ),

              ),

            );

          },

          loadingBuilder: (context, child, progress) {

            if (progress == null) return child;

            return SizedBox(

              width: 64,

              height: 64,

              child: Center(

                child: SizedBox(

                  width: 28,

                  height: 28,

                  child: CircularProgressIndicator(

                    strokeWidth: 2,

                    color: AppTheme.brandRed.withValues(alpha: 0.6),

                  ),

                ),

              ),

            );

          },

        ),

      );

    } else {

      avatar = CircleAvatar(

        radius: 32,

        backgroundColor: AppTheme.brandRed.withValues(alpha: 0.15),

        child: Text(

          initials,

          style: TextStyle(

            fontSize: 22,

            fontWeight: FontWeight.w700,

            color: AppTheme.brandRedDark,

          ),

        ),

      );

    }



    if (onTap == null) return avatar;



    return Material(

      color: Colors.transparent,

      child: InkWell(

        onTap: onTap,

        customBorder: const CircleBorder(),

        child: avatar,

      ),

    );

  }



  Widget _skeletonCircle(ColorScheme scheme) {

    return Container(

      width: 64,

      height: 64,

      decoration: BoxDecoration(

        color: scheme.surfaceContainerHighest,

        shape: BoxShape.circle,

      ),

    );

  }



  Widget _skeletonTextColumn(BuildContext context) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        _skeletonBar(context, widthFactor: 0.65, height: 20),

        const SizedBox(height: 12),

        _skeletonBar(context, widthFactor: 0.35, height: 28),

        const SizedBox(height: 10),

        _skeletonBar(context, widthFactor: 0.85, height: 14),

      ],

    );

  }



  Widget _skeletonBar(

    BuildContext context, {

    required double widthFactor,

    required double height,

  }) {

    final scheme = Theme.of(context).colorScheme;

    return FractionallySizedBox(

      widthFactor: widthFactor,

      alignment: Alignment.centerLeft,

      child: Container(

        height: height,

        decoration: BoxDecoration(

          color: scheme.surfaceContainerHighest,

          borderRadius: BorderRadius.circular(8),

        ),

      ),

    );

  }

}

